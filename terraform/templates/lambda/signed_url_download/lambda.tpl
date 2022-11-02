const AWS = require('aws-sdk')
AWS.config.update({ region: process.env.REGION })
const s3 = new AWS.S3({region: '${region}', signatureVersion: 'v4'});
const uploadBucket = '${bucket}'

exports.handler = async (event) => {
  let file_name = event.queryStringParameters.file_name;
  
  const result = await getUploadURL(file_name)
  console.log('Result: ', result)
  return result
};

const getUploadURL = async function(file_name) {
  console.log('getUploadURL started')
  let key = `$${file_name}`

  var s3Params = {
    Bucket: uploadBucket,
    Key:  `$${key}`,
  };

  return new Promise((resolve, reject) => {
    // Get signed URL
    let downloadURL = s3.getSignedUrl('getObject', s3Params)
    resolve({
      "statusCode": 200,
      "isBase64Encoded": false,
      "headers": { "Access-Control-Allow-Origin": "https://www.${domain_name}" },
      "body": JSON.stringify({
          "downloadURL": downloadURL,
          "Filename": `$${key}`,
      })
    })
  })
}