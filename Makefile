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
	# Copy function app 1 artifacts
	cp ./function_app_1_artifacts/fa1_init.py ./fa1/__init__.py
	cp ./function_app_1_artifacts/fa1_function_json.sample ./fa1/function.json
