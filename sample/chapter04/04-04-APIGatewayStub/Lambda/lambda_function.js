console.log('Loading function');

var aws = require('aws-sdk');
var s3 = new aws.S3({ apiVersion: '2006-03-01' });

exports.handler = function(event, context) {
          //console.log('Received event:', JSON.stringify(event, null, 2));
          //eventからバケット名とファイル名を取得
          var bucket = event.Bucket;
          var key = event.Key;
          var params = {
              Bucket: bucket,
              Key: key
          };
          console.log('S3 params:', params);
          //s3からデータを取得
          s3.getObject(params, function(err, data) {
              if (err) {
                  console.log(err);
                  var message = "Error getting object " + key + " from bucket " + bucket +
                      ". Make sure they exist and your bucket is in the same region as this function.";
                  console.log(message);
                  context.fail(message);
              } else {
                  console.log('CONTENT TYPE:', data.ContentType);
                  try{
                      var response = JSON.parse(data.Body.toString());
                      console.log('DATA:',response);
                      context.succeed(response);
                   }catch(err){
                      console.log(err);
                      var message = "JSON parse Error getting object " + key + " from bucket " + bucket;
                      console.log(message);                       
                      context.fail(err); 
                }
              }
          });
};
