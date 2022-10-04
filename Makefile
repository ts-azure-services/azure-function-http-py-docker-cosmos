install:
	#conda create -n functions-cosmos python=3.8 -y; conda activate functions-cosmos
	pip install azure-cosmos
	pip install azure-functions
	pip install requests
	pip install python-dotenv

cleanup:
	./admin/cleanup.sh

infra:
	./admin/create-resources.sh

function_setup:
	func init --worker-runtime python
	func new --name HttpCosmos --template "HTTP trigger" --authlevel anonymous

copy_artifacts:
	cp ./function_app_files/fa_init.py ./HttpCosmos/__init__.py
	cp ./function_app_files/fa_function_json.sample ./HttpCosmos/function.json

publish:
	. variables.env;\
		func azure functionapp publish $${FUNCTIONAPPNAME}

get_url:
	./admin/get-url.sh
