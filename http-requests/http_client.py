"""Usage:
  python http_client.py <function_url> <auth_secret> <body_json_file>
  python http_client.py https://cjoakimfunctions.azurewebsites.net/api/HttpCosmos ppqXXXXX postdata/body1.json
"""
import os
import json
import requests
from dotenv import load_dotenv

def load_variables():
    """Load authentication details"""
    env_var=load_dotenv('./variables.env')
    auth_dict = {
            "function_app_name":os.environ['FUNCTIONAPPNAME'],
            "function_app_secret":os.environ['FUNCTIONAPP_SECRET'],
            "function_url":os.environ['FUNCTIONAPP_URL'],
            }
    return auth_dict

def read_body_json_file(body_json_file):
    with open(body_json_file, 'rt') as f:
        return f.read()

if __name__ == "__main__":
    auth_var = load_variables()
    body_json_file = './postdata/body1.json'
    function_url, auth_secret = auth_var['function_url'], auth_var['function_app_secret'], 

    body = json.loads(read_body_json_file(body_json_file))

    print('function_url:   {}'.format(function_url))
    print('auth_secret:    {}'.format(auth_secret))
    print('body_json_file: {}'.format(body_json_file))
    print('body:')
    print(json.dumps(body, sort_keys=False, indent=2))

    headers = dict()
    headers['Content-Type'] = 'application/json'
    headers['Auth-Token'] = auth_secret
    print('headers:')
    print(json.dumps(headers, sort_keys=False, indent=2))
    print('---')
    print('response:')

    response = requests.post(function_url, headers=headers, json=body)
    print('response: {}'.format(response))

    try:
        #if response.status_code == 200:
        resp_obj = json.loads(response.text)
        print(json.dumps(resp_obj, sort_keys=False, indent=2))
    except Exception as e:
        print(e)
