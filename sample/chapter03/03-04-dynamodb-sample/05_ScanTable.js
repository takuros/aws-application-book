// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

var params = {
  // テーブル名
  TableName : 'Music',
  // フィルタリング
  FilterExpression : 'Artist = :artist',
  ExpressionAttributeValues : {':artist' : "Artist1"}
};

// DocumentClientを利用
var docClient = new AWS.DynamoDB.DocumentClient();
// スキャン実行
docClient.scan(params, function(err, data) {
   if (err) console.log(err);
   else console.log(data);
});
