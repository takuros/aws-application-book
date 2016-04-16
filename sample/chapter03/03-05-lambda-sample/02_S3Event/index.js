var aws = require('aws-sdk');
var s3 = new aws.S3({ apiVersion: '2006-03-01' });

exports.handler = function(event, context) {
  event.Records.forEach(function(record) {
    var bucket = record.s3.bucket.name;
    var key = decodeURIComponent(record.s3.object.key.replace(/\+/g, ' '));
    var params = {
        Bucket: bucket,
        Key: key
    };
    var s3stream =  s3.getObject(params).createReadStream();
    s3stream.on('data',function (data) {
        console.log(data.toString());
        context.succeed("Get this object -> " + key);
    });
  });
};
