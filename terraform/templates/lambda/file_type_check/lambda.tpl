const AWS = require('aws-sdk');
AWS.config.update({ region: process.env.REGION });
const s3 = new AWS.S3({region: '${region}', signatureVersion: 'v4'});

exports.handler = async (event) => {
  const result = await FileType(event)
  console.log('Result: ', result)
  return result
};

const FileType = async function(event, req, res) {
    console.log(event.queryStringParameters.file_name);
    let Key = event.queryStringParameters.file_name;
    // Get File Content-Type
    let params = {
        Bucket: `${bucket}`,
        Key: `$${Key}`
    };
    console.log(params);
    const metaData = await s3.headObject(params).promise();
    let type = metaData.ContentType.split("/")[0];
    console.log("File Type = "+ type);
    //return ({"FileName": Key , "Type": type});

    //If  Content-Type = Image
    if (type.includes('image')) { 
      console.log('image');
      console.log(`$${Key}`);
      var AWS = require('aws-sdk');
  
      var stepfunctions = new AWS.StepFunctions();
  
      let params = {
        stateMachineArn: '${image_state_machine}',
        input: JSON.stringify({
          "detail": {
            "object": {
              "type": `$${type}`,
              "key": `$${Key}`
            }
          }
        })
      };
      var execute = await stepfunctions.startExecution(params).promise();
      params = {executionArn: execute.executionArn};
      console.log(params);
      do {
        var sf_response = await stepfunctions.describeExecution(params).promise();
        var status = sf_response['status'] ;
        await new Promise(resolve => setTimeout(resolve, 1000));
        console.log(status)
      }
      while (status == 'RUNNING');
      let json = JSON.parse(sf_response.output);
      console.log(json['getLabelDetectionOutput']['Labels'])
      return new Promise((resolve, reject) => {
        resolve({
          "statusCode": 200,
          "isBase64Encoded": false,
          "headers": { "Access-Control-Allow-Origin": "https://www.${domain_name}" },
          "body": JSON.stringify(json['getLabelDetectionOutput']['Labels'])
        })
      })
    }

    //If  Content-Type = Video
    if (type.includes('video')) { 
      console.log('video');
      var AWS = require('aws-sdk');
  
      var stepfunctions = new AWS.StepFunctions();
  
      let params = {
        stateMachineArn: '${video_state_machine}',
        input: JSON.stringify({
          "detail": {
            "object": {
              "type": `$${type}`,
              "key": `$${Key}`
            }
          }
        })
      };
      var execute = await stepfunctions.startExecution(params).promise();
      params = {executionArn: execute.executionArn};
      console.log(params);
      do {
        var sf_response = await stepfunctions.describeExecution(params).promise();
        var status = sf_response['status'] ;
        await new Promise(resolve => setTimeout(resolve, 1000));
        console.log(status)
      }
      while (status == 'RUNNING');
      let json = JSON.parse(sf_response.output);
      console.log(json['getLabelDetectionOutput']['Labels'])
      return new Promise((resolve, reject) => {
        resolve({
          "statusCode": 200,
          "isBase64Encoded": false,
          "headers": { "Access-Control-Allow-Origin": "https://www.${domain_name}" },
          "body": JSON.stringify(json['getLabelDetectionOutput']['Labels'])
        })
      })
    }
};