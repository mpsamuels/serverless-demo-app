const AWS = require('aws-sdk');
AWS.config.update({ region: process.env.REGION });
const s3 = new AWS.S3({region: '${region}', signatureVersion: 'v4'});

exports.handler = async (event) => {
    return(FileType(event));
};

const FileType = async function(event, req, res) {
    console.log(event.detail.object.key);
    let Key = event.detail.object.key;
    // Get File Content-Type
    let params = {
        Bucket: `${bucket}`,
        Key: `$${Key}`
    };
    console.log(params);
    const metaData = await s3.headObject(params).promise();
    let type = metaData.ContentType.split("/")[0];
    console.log("File Type = "+ type);
    return ({"FileName": Key , "Type": type});
};