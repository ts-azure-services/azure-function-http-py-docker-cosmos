#!/bin/bash
grn=$'\e[1;32m'
end=$'\e[0m'

# Start of script
SECONDS=0
printf "${grn}Starting creation of resources...${end}\n"

# Source subscription ID, and prep config file
source sub.env
sub_id=$SUB_ID

# Set the default subscription 
az account set -s $sub_id

# Source unique name for RG, workspace creation
#random_name_generator='/random_name.py'
#unique_name=$(python $PWD$random_name_generator)
unique_name='albatross'
number=$[ ( $RANDOM % 10000 ) + 1 ]
resourcegroup=$unique_name$number
storagename=$unique_name$number'storageacct'
cosmosdbaccount='sqlapi'$number'account'
cosmosdbcontainer='sqlapi'$number'container'
cosmosdbdatabase='sqlapi'$number'database'
appinsightsname=$unique_name$number'appinsights'
functionappname=$unique_name$number'functionapp'
functionapppw=$(uuidgen)
location='westus'

# Create a resource group
printf "${grn}Starting creation of resource group...${end}\n"
rg_create=$(az group create --name $resourcegroup --location $location)
printf "Result of resource group create:\n $rg_create \n"

# Create storage account
printf "${grn}Starting creation of storage account...${end}\n"
result=$(az storage account create \
	--name $storagename \
	--location $location \
	--resource-group $resourcegroup \
	--sku 'Standard_LRS')
printf "Result of storage account create:\n $result \n"
sleep 20

# Get storage account connection string
printf "${grn}Getting storage account connection string...${end}\n"
storageaccountkey=$(az storage account show-connection-string \
	-g $resourcegroup \
	-n $storagename)

# Capture credentials for 'jq' parsing
credFile='cred.json'
printf "$storageaccountkey" > $credFile
sakey=$(cat $credFile | jq '.connectionString')
rm $credFile

## Create a CosmosDB account
printf "${grn}Creating the CosmosDB account...${end}\n"
cosmosDBAccount=$(az cosmosdb create --name $cosmosdbaccount \
	-g $resourcegroup)
printf "Result of CosmosDB Account create:\n $cosmosDBAccount \n"

### Create a CosmosDB container in the account
#printf "${grn}Creating the CosmosDB container...${end}\n"
#cosmosDBContainer=$(az cosmosdb sql container create \
#	--account-name $cosmosdbaccount \
#	--database-name $cosmosdbdatabase \
#	--name $cosmosdbcontainer \
#	--partition-key-path "/my/path" \
#	-g $resourcegroup)
#printf "Result of CosmosDB container create:\n $cosmosDBContainer \n"

## Get the cosmosdb account primary master key
printf "${grn}Get Cosmosdb account primary master key...${end}\n"
primaryMasterKey=$(az cosmosdb keys list --name $cosmosdbaccount \
	-g $resourcegroup \
	--query "primaryMasterKey")
printf "Result of Cosmosdb account primary master key:\n $primaryMasterKey \n"

## Get the cosmosdb account primary connection string
printf "${grn}Get Cosmosdb account primary connection string...${end}\n"
primaryConnectionString=$(az cosmosdb keys list --name $cosmosdbaccount \
	-g $resourcegroup \
	--type "connection-strings" \
	--query "connectionStrings[0].connectionString")
printf "Result of Cosmosdb account primary master key:\n $primaryConnectionString \n"


# Create app insights
printf "${grn}Starting creation of app insights...${end}\n"
result=$(az monitor app-insights component create \
	--app $appinsightsname \
	--location $location \
	--resource-group $resourcegroup)
printf "Result of app insights create:\n $result \n"

# Create function app 
printf "${grn}Starting creation of function app...${end}\n"
result=$(az functionapp create \
	--name $functionappname \
	--storage-account $storagename \
	--app-insights $appinsightsname \
	--consumption-plan-location $location \
	--resource-group $resourcegroup \
	--os-type 'Linux' \
	--runtime 'python' \
	--runtime-version '3.8' \
	--functions-version 4)
printf "Result of function create:\n $result \n"
sleep 5

# Remove double quotes, editing before writing to configuration file
primaryMasterKey=$(sed -e 's/^"//' -e 's/"$//' <<<"$primaryMasterKey")
primaryConnectionString=$(sed -e 's/^"//' -e 's/"$//' <<<"$primaryConnectionString")
sakey=$(sed -e 's/^"//' -e 's/"$//' <<<"$sakey")

# Update function app settings
printf "${grn}Updating AzureWebJobsStorage...${end}\n"
result=$(az functionapp config appsettings set -n $functionappname -g $resourcegroup \
	--settings AzureWebJobsStorage=$sakey)
#printf "Result of function app setting changes:\n $result \n"

printf "${grn}Updating CosmosDB URI...${end}\n"
result=$(az functionapp config appsettings set -n $functionappname -g $resourcegroup \
	--settings AZURE_COSMOSDB_SQLDB_URI=$primaryConnectionString)
#printf "Result of function app setting changes:\n $result \n"

printf "${grn}Updating CosmosDB primary key...${end}\n"
result=$(az functionapp config appsettings set -n $functionappname -g $resourcegroup \
	--settings AZURE_COSMOSDB_SQLDB_KEY=$primaryMasterKey)
#printf "Result of function app setting changes:\n $result \n"

printf "${grn}Updating function secret...${end}\n"
result=$(az functionapp config appsettings set -n $functionappname -g $resourcegroup \
	--settings AZURE_FUNCTION_SECRET=$functionapppw)
#printf "Result of function app setting changes:\n $result \n"

printf "${grn}Updating function max queries...${end}\n"
result=$(az functionapp config appsettings set -n $functionappname -g $resourcegroup \
	--settings AZURE_FUNCTION_MAX_QUERIES=100)
# Show the last printf statement since it shows all settings
printf "Result of function app setting changes:\n $result \n"
sleep 5


# Create environment file 
printf "${grn}WRITING OUT ENVIRONMENT VARIABLES...${end}\n"
configFile='variables.env'
printf "RESOURCE_GROUP=$resourcegroup \n"> $configFile
printf "STORAGE_ACCT_NAME=$storagename \n" >> $configFile
printf "STORAGE_CONN_STRING=$sakey \n" >> $configFile
printf "FUNCTIONAPPNAME=$functionappname \n" >> $configFile
printf "FUNCTIONAPP_SECRET=$functionapppw \n" >> $configFile
printf "COSMOSDB_ACCOUNT=$cosmosdbaccount \n">> $configFile
printf "COSMOSDB_CONTAINER=$cosmosdbcontainer \n">> $configFile
printf "COSMOSDB_ACCT_PRIMARY_KEY=$primaryMasterKey \n">> $configFile
printf "COSMOSDB_ACCT_PRIMARY_CONN_STRING=$primaryConnectionString \n">> $configFile
sleep 5 # just to give time for artifacts to settle in the system, and be accessible
