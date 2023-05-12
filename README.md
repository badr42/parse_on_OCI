# parse_on_OCI
Terraform installation repo for running Parse backend on OCI


**Parse** 
Parse is an open-source mobile Backend as a Service (MBaaS) that simplifies backend development and allows developers to focus on building the frontend of their mobile applications. It provides developers with a cloud-based infrastructure that enables them to build scalable and feature-rich mobile applications without having to worry about the backend.


## Architecture

## Requirements

## Configuration

1. Log into cloud console 
2. Run the following 
```
git clone https://github.com/badr42/noderedOnOCI
cd noderedOnOCI
export TF_VAR_tenancy_ocid='<tenancy-ocid>'
export TF_VAR_compartment_ocid='<comparment-ocid>'
export TF_VAR_region='<home-region>'
export TF_VAR_Parse_pass=<password>


<optional>
# Select Availability Domain, zero based, if not set it defaults to 0
export TF_VAR_AD_number='0'
```

3. Execute the script generate-keys.sh to generate private key to access the instance
```
ssh-keygen -t rsa -b 2048 -N "" -f server.key
```


## Build
To build simply execute the next commands. 
```
terraform init
terraform plan
terraform apply
```
