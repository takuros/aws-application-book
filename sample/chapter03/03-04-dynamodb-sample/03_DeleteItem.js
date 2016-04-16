// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

var params = {
  // テーブル名
  TableName: 'Music',
  // 削除するitemのプライマリーキー
  Key: {
    Artist: 'Artist1',
    SongTitle: 'Song1'
  }
};

// DocumentClientを利用
var docClient = new AWS.DynamoDB.DocumentClient();
// データを削除
docClient.delete(params, function(err, data) {
  if (err) console.log(err);
  else console.log(data);
});
