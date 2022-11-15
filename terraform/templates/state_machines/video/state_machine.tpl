{
  "Comment": "A State Machine that process a video file",
  "StartAt": "StartLabelDetection",
  "States": {
    "StartLabelDetection": {
      "Type": "Task",
      "Next": "Wait",
      "Parameters": {
        "Video": {
          "S3Object": {
            "Bucket": "${source_bucket}",
            "Name.$": "$.detail.object.key"
          }
        }
      },
      "Resource": "arn:aws:states:${region}:${account}:aws-sdk:rekognition:startLabelDetection",
      "ResultPath": "$.startLabelDetectionOutput"
    },
    "Wait": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "GetLabelDetection"
    },
    "GetLabelDetection": {
      "Type": "Task",
      "Parameters": {
        "JobId.$": "$.startLabelDetectionOutput.JobId",
        "MaxResults": 50
      },
      "Resource": "arn:aws:states:${region}:${account}:aws-sdk:rekognition:getLabelDetection",
      "ResultPath": "$.getLabelDetectionOutput",
      "Next": "Choice"
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.getLabelDetectionOutput.JobStatus",
          "StringMatches": "IN_PROGRESS",
          "Next": "Wait"
        }
      ],
      "Default": "Parallel"
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
                        "S.$": "$.Label.Name"
                      }
                    },
                    "UpdateExpression": "set Confidence=:o",
                    "ExpressionAttributeValues": {
                      ":o": {
                        "S.$": "States.Format($.Label.Confidence)"
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
      "ResultPath": null,
      "Next": "Pass"
    },
    "Pass": {
      "Type": "Pass",
      "End": true,
      "InputPath": "$.getLabelDetectionOutput.Labels",
      "Result": {},
      "ResultPath": null
    }
  }
}
