from diagrams import Diagram, Cluster
from urllib.request import urlretrieve
from diagrams.custom import Custom

from diagrams.aws.storage import S3
from diagrams.aws.integration import Eventbridge
from diagrams.aws.integration import StepFunctions


from diagrams import Diagram, Cluster
from urllib.request import urlretrieve
from diagrams.custom import Custom

from diagrams.aws.storage import S3
from diagrams.aws.integration import Eventbridge
from diagrams.aws.integration import StepFunctions
from diagrams.aws.compute import LambdaFunction
from diagrams.aws.network import Route53HostedZone
from diagrams.aws.network import Route53
from diagrams.aws.network import CF
from diagrams.aws.network import APIGateway
from diagrams.aws.database import Dynamodb


with Diagram("S3 Upload Type Check", show=False, direction="TB"):
    upload_bucket = S3()
    event_bridge = Eventbridge()
    type_detection_lambda_function = LambdaFunction()
    image_step_function = StepFunctions()
    video_step_function = StepFunctions()
    user = Custom("","./images/account.png")
    gui = Custom("S3 Uploader Page", "./images/application-outline.png")
    url = Custom("Signed URL", "./images/file-sign.png")
    www_bucket = S3("www S3 bucket")
    root_bucket = S3("root S3 bucket")
    www_r53 = Route53("www r53 record")
    root_r53 = Route53("root r53 record")
    api_r53 = Route53("api r53 record")
    lmbda = LambdaFunction("Lambda signed URL generator")
    www_cf = CF("www Cloudfront")
    root_cf = CF("root Cloudfront")
    apigw = APIGateway("API Gateway")
    dynamo = Dynamodb('DynamoDB Table')

    www_cf >> www_bucket >> apigw >> lmbda >> upload_bucket >> event_bridge

    event_bridge >> type_detection_lambda_function >> image_step_function >> dynamo
    event_bridge >> type_detection_lambda_function >> video_step_function >> dynamo