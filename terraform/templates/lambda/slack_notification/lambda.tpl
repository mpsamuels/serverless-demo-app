import boto3
import json
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ssm = boto3.client('ssm')

def handler(event, context):
        slack_message = { 'text' : (event['detail']['object']['type'])+' '+(event['detail']['object']['key'])+' uploaded. \n \n'+ json.dumps(event['getLabelDetectionOutput']['Labels'])}

        webhook_url = ssm.get_parameter(Name='${ssm_secret}', WithDecryption=True)
        req = Request(webhook_url['Parameter']['Value'],
                        json.dumps(slack_message).encode('utf-8'))
        response = urlopen(req)
        response.read()
        print('Message posted to Slack')