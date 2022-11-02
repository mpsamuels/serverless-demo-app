{
  "Comment": "A State Machine that process a video file",
  "StartAt": "DetectLabels",
  "States": {
    "DetectLabels": {
      "Type": "Task",
      "Parameters": {
        "Image": {
          "S3Object": {
            "Bucket": "${source_bucket}",
            "Name.$": "$.detail.object.key"
          }
        },
        "MaxLabels": 10,
        "MinConfidence": 75
      },
      "Resource": "arn:aws:states:${region}:${account}:aws-sdk:rekognition:detectLabels",
      "Next": "Parallel",
      "ResultPath": "$.getLabelDetectionOutput"
    },
    "Parallel": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "Lambda Invoke",
          "States": {
            "Lambda Invoke": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "OutputPath": "$.Payload",
              "Parameters": {
                "Payload.$": "$",
                "FunctionName": "${lambda}"
              },
              "Retry": [
                {
                  "ErrorEquals": [
                    "Lambda.ServiceException",
                    "Lambda.AWSLambdaException",
                    "Lambda.SdkClientException"
                  ],
                  "IntervalSeconds": 2,
                  "MaxAttempts": 6,
                  "BackoffRate": 2
                }
              ],
              "End": true
            }
          }
        },
        {
          "StartAt": "Map",
          "States": {
            "Map": {
              "Type": "Map",
              "Iterator": {
                "StartAt": "DynamoDB UpdateItem",
                "States": {
                  "DynamoDB UpdateItem": {
                    "Type": "Task",
                    "Resource": "arn:aws:states:::dynamodb:updateItem",
                    "Parameters": {
                      "TableName": "${db}",
                      "Key": {
                        "FileName": {
                          "S.$": "$$.Execution.Input.detail.object.key"
                        },
                        "Label": {
                          "S.$": "$.Name"
                        }
                      },
                      "UpdateExpression": "set Confidence=:o",
                      "ExpressionAttributeValues": {
                        ":o": {
                          "S.$": "States.Format($.Confidence)"
                        }
                      }
                    },
                    "End": true
                  }
                }
              },
              "ItemsPath": "$.getLabelDetectionOutput.Labels",
              "End": true,
              "ResultPath": "$.output.map"
            }
          }
        }
      ],
      "End": true
    }
  }
}
