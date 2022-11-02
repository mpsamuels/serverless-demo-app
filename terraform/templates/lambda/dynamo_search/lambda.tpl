from cProfile import label
import boto3
import json
from boto3.dynamodb.conditions import Key, Attr
dynamodb = boto3.resource('dynamodb', region_name='${region}')
table = dynamodb.Table('${dynamo_table}')

def handler (event, context):
        file_name = event['queryStringParameters']['file_name']
        if '.' in file_name:
                response = (table.query(
                        KeyConditionExpression=Key('FileName').eq(file_name)))
                label_list = []
                for x, items in enumerate(response["Items"]):
                        print(str(response["Items"]))
                        label_list.append(response["Items"][x]["Label"])
                        print(response["Items"][x]["Label"])
                result = {
                    "isBase64Encoded": 'false',
                    "statusCode": 200,
                    "headers": {
                        "Access-Control-Allow-Origin": "https://www.${domain_name}"
                    },
                    "body": json.dumps({ "File Names": [(file_name)], "Labels": (label_list)})
                    }
                return (result)
        else:
                response = (table.query(
                        IndexName='Labels',
                        KeyConditionExpression=Key('Label').eq(file_name)))
                file_list = []
                for x, items in enumerate(response["Items"]):
                        print(str(response["Items"]))
                        file_list.append(response["Items"][x]["FileName"])
                        print(response["Items"][x]["FileName"])
                result = {
                    "isBase64Encoded": 'false',
                    "statusCode": 200,
                    "headers": {
                        "Access-Control-Allow-Origin": "https://www.${domain_name}"
                    },
                    "body": json.dumps({ "File Names": (file_list), "Labels": [(file_name)]})
                    }
                return (result)