install:
	#conda create -n functions-cosmos python=3.8 -y; conda activate functions-cosmos
	pip install azure-cosmos
	pip install azure-functions
	pip install wazoo

hello:

infra:
	./setup/create-resources.sh

# Local config, to use REST APIs, and create cluster
update_netrc:
	./setup/update_netrc.sh

cluster_create:
	./setup/create-cluster.sh

# Configure Databricks CLI
# This saves settings in: cat ~/.databrickscfg
configure_cli:
	./setup/configure-db-cli.sh

# Use the Databricks CLI to upload file
# Ensure the DBFS File Browser is enabled
upload_data:
	./setup/upload-data.sh

############# In SQL warehouse ##############
# dbsqlcli -e "SELECT * FROM menu_nutrition_data"
query = "./sql-scripts/basic_query.sql"
execute_query:
	./sql-scripts/execute-query.sh $(query)

query = "./sql-scripts/normal_query.sql"
normal_operations_query:
	./sql-scripts/execute-query.sh $(query)

query = "./sql-scripts/adv_operators.sql"
advanced_operations_query:
	./sql-scripts/execute-query.sh $(query)
