// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

var params = {
  QueueUrl: "http://sqs.us-east-1.amazonaws.com/123456789012/queueABC",
  MaxNumberOfMessages: 1,
  VisibilityTimeout: 0,
  WaitTimeSeconds: 0,
  MessageAttributeNames: ["Name","Age"]
};

var sqs = new AWS.SQS();
sqs.receiveMessage(params, function(err, data) {
  if (err) console.log(err, err.stack);
  else {
    data.Messages.forEach(function(msg) {
      console.log(msg.Body);
      console.log(msg.MessageAttributes);
    });
  }
});
