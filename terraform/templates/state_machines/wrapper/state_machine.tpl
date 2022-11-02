{
  "StartAt": "Lambda Invoke",
  "States": {
    "Lambda Invoke": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${lambda}",
        "Payload": {
          "detail": {
            "object": {
              "key.$": "$.detail.object.key"
            }
          }
        }
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
      "Next": "Choice"
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Payload.Type",
          "StringEquals": "video",
          "Next": "Step Functions StartExecution"
        },
        {
          "Variable": "$.Payload.Type",
          "StringEquals": "image",
          "Next": "Step Functions StartExecution (1)"
        }
      ],
      "Default": "Lambda Invoke"
    },
    "Step Functions StartExecution": {
      "Type": "Task",
      "Resource": "arn:aws:states:::states:startExecution.sync:2",
      "Parameters": {
        "StateMachineArn": "${video_machine}",
        "Input": {
          "AWS_STEP_FUNCTIONS_STARTED_BY_EXECUTION_ID.$": "$$.Execution.Id",
          "detail": {
            "object": {
              "key.$": "$.Payload.FileName",
              "type.$": "$.Payload.Type"
            }
          }
        }
      },
      "End": true,
      "ResultPath": "$.output"
    },
    "Step Functions StartExecution (1)": {
      "Type": "Task",
      "Resource": "arn:aws:states:::states:startExecution.sync:2",
      "Parameters": {
        "StateMachineArn": "${image_machine}",
        "Input": {
          "AWS_STEP_FUNCTIONS_STARTED_BY_EXECUTION_ID.$": "$$.Execution.Id",
          "detail": {
            "object": {
              "key.$": "$.Payload.FileName",
              "type.$": "$.Payload.Type"
            }
          }
        }
      },
      "End": true,
      "ResultPath": "$.output"
    }
  }
}