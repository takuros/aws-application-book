// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

var params = {
  QueueUrl: "http://sqs.us-east-1.amazonaws.com/123456789012/queueABC",
  MessageBody: 'Hellp SQS!!',
  MessageAttributes: {
    Name: {
      DataType: "String",
      StringValue: "SQS"
    },
    Age: {
      DataType: "Number",
      StringValue: "10"
    }
  },
  DelaySeconds: 0
};

var sqs = new AWS.SQS();
sqs.sendMessage(params, function(err, data) {
  if (err) console.log(err, err.stack);
  else     console.log(data);
});
