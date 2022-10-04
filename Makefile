install:
	#conda create -n functions-cosmos python=3.8 -y; conda activate functions-cosmos
	pip install azure-cosmos
	pip install azure-functions

infra:
	./admin/create-resources.sh

cleanup:
	./admin/cleanup.sh

function_setup:
	func init --worker-runtime python
	func new --name HttpCosmos --template "HTTP trigger" --authlevel anonymous

copy_artifacts:
	cp ./function_app_files/__init__.py ./HttpCosmos/__init__.py
	cp ./function_app_files/function.json ./HttpCosmos/function.json

publish_app:
	. variables.env;\
		func azure functionapp publish $${FUNCTIONAPPNAME}

