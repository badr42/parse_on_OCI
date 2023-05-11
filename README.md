# parse_on_OCI
 terraform installation repo for running Parse backend on OCI


**Parse** 



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
export TF_VAR_Node_red_pass=<password>


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


**After applying, the service will be ready in about 5 minutes** (it will install OS dependencies, as well as the packages needed to get openMPI to work)

## Post configuration

You can use MQTTBox chrome client to test MQTT
