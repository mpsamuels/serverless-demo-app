const AWS = require('aws-sdk')
AWS.config.update({ region: process.env.REGION })
const s3 = new AWS.S3({region: '${region}', signatureVersion: 'v4'});
const uploadBucket = '${bucket}'
exports.handler = async (event) => {
  let file_extension = event.queryStringParameters.file_extension;
  let content_type = event.queryStringParameters.content_type;
  
  const result = await getUploadURL(file_extension, content_type)
  console.log('Result: ', result)
  return result
};

const getUploadURL = async function(file_extension, content_type) {
  console.log('getUploadURL started')
  let actionId = Date.now()
  let key = `$${actionId}.$${file_extension}`

  var s3Params = {
    Bucket: uploadBucket,
    Key:  `$${key}`,
    ContentType:  `$${content_type}`
  };

  return new Promise((resolve, reject) => {
    // Get signed URL
    let uploadURL = s3.getSignedUrl('putObject', s3Params)
    resolve({
      "statusCode": 200,
      "isBase64Encoded": false,
      "headers": { "Access-Control-Allow-Origin": "https://www.${domain_name}" },
      "body": JSON.stringify({
          "uploadURL": uploadURL,
          "Filename": `$${key}`,
          "ContentType": `$${content_type}`
      })
    })
  })
}