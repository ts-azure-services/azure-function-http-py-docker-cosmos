install:
	#conda create -n functions-cosmos python=3.8 -y; conda activate functions-cosmos
	pip install azure-cosmos
	pip install azure-functions
	pip install wazoo

infra:
	./setup/create-resources.sh

function_setup:
	func init --worker-runtime python
	func new --name HttpCosmos --template "HTTP trigger" --authlevel anonymous

copy_artifacts:
	cp ./HttpCosmosOriginal/__init__.py ./HttpCosmos/__init__.py
	cp ./HttpCosmosOriginal/function.json ./HttpCosmos/function.json
