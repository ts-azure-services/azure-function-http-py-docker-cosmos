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

# Load the data (manually)

# Testing the request
#query_count=1000
#make create_payload query_count=200
create_payload:
	python ./http-requests/postdata.py --count $(query_count) > ./http-requests/data/body1.json

test_payload:
	python ./http-requests/http_client.py
