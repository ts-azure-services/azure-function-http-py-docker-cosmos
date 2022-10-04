#!/bin/bash
grn=$'\e[1;32m'
end=$'\e[0m'

# Start of script
SECONDS=0
printf "${grn}Get function app URL...${end}\n"

## Source subscription ID, and prep config file
#source sub.env
#sub_id=$SUB_ID
#
## Set the default subscription 
#az account set -s $sub_id
# Get pre-existing variables
source variables.env
resourcegroup=$RESOURCE_GROUP
functionappname=$FUNCTIONAPPNAME

printf "${grn}Get function app URL...${end}\n"
functionappurl=$(az functionapp function show --name $functionappname \
	--function-name "HttpCosmos" \
	-g $resourcegroup \
	--query "invokeUrlTemplate")
printf "Result of function app URL:\n $functionappurl \n"
sleep 3

functionappurl=$(sed -e 's/^"//' -e 's/"$//' <<<"$functionappurl")

# Adding to environment file 
printf "${grn}WRITING OUT ENVIRONMENT VARIABLES...${end}\n"
configFile='variables.env'
printf "FUNCTIONAPP_URL=$functionappurl \n" >> $configFile
