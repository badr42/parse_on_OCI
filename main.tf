# Create datasource of images from the image list
data "oci_core_images" "images" {
  compartment_id = var.compartment_ocid
  operating_system = "Canonical Ubuntu"
  shape = var.instance_shape
  filter {
    name = "display_name"
    values = ["^Canonical-Ubuntu-22.04-([\\.0-9-]+)$"]
    regex = true
  }
}


# Create a compute instance with a public IP address using oci provider
resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_number].name
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_name
  shape               = var.instance_shape


  
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.images.images[var.AD_number].id
    boot_volume_size_in_gbs = 50
  }

  create_vnic_details {
    assign_public_ip = "true"
    subnet_id        = oci_core_subnet.subnet.id
  }


  # Add private key
  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(file("install.sh"))
  }
  shape_config {
        #Optional
        # memory_in_gbs = "16"
        memory_in_gbs = var.core_count*2 <16 ? 16 : var.core_count*2
        ocpus = var.core_count
  }


  connection {
    type        = "ssh"
    host        = "${self.public_ip}"
    user        = "ubuntu"
    private_key = "${file(var.ssh_private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      ">test.log",
      "wget https://raw.githubusercontent.com/badr42/parse_on_OCI/main/install.sh",
      "chmod 777 install.sh",
      "sudo sh install.sh ${var.Parse_pass}",
      //"wget -qO - 'https://raw.githubusercontent.com/badr42/parse_on_OCI/main/install.sh' | bash -s ${var.Parse_pass}",
    ]
  }
}

# Create datasource for availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.compartment_ocid
}

# Create internet gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.parse_vcn.id
  display_name   = "parse-internet-gateway"
}

# Create route table
resource "oci_core_route_table" "parse_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.parse_vcn.id
  display_name   = "parse-route-table"
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Create security list with ingress and egress rules
resource "oci_core_security_list" "parse_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.parse_vcn.id
  display_name   = "parse-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "0.0.0.0/0"
    description = "Allow all inbound traffic"
  }

  # ingress rule for ssh
    ingress_security_rules {
        protocol    = "6" # tcp
        source      = "0.0.0.0/0"
        description = "Allow ssh"
        tcp_options {
            max = 22
            min = 22
        }
    }
}

# Create a subnet
resource "oci_core_subnet" "subnet" {
  cidr_block        = var.subnet_cidr
  compartment_id    = var.compartment_ocid
  display_name      = "parse-subnet"
  vcn_id            = oci_core_virtual_network.parse_vcn.id
  route_table_id    = oci_core_route_table.parse_route_table.id
  security_list_ids = ["${oci_core_security_list.parse_security_list.id}"]
  dhcp_options_id   = oci_core_virtual_network.parse_vcn.default_dhcp_options_id
}

# Create a virtual network
resource "oci_core_virtual_network" "parse_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "parse-vcn"
}

output "instance_public_ip" {
  value = <<EOF
  
  Wait 5 minutes for the instance to be ready.

  Login into http://${oci_core_instance.instance.public_ip}:4040

  MQTT server can be connected to at ${oci_core_instance.instance.public_ip}:1883

  ssh -i server.key ubuntu@${oci_core_instance.instance.public_ip}
  

EOF
}