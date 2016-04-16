// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

var params = {
  // テーブル名
  TableName : 'Music',
  // itemのattribute
  Item: {
     Artist: 'Artist1',
     SongTitle: 'Song1',
     ReleaseDate: 20160110,
     Category: 'CategoryA',
     Rank: 10
  }
};

// DocumentClientを利用
var docClient = new AWS.DynamoDB.DocumentClient();
// データを挿入
docClient.put(params, function(err, data) {
  if (err) console.log(err);
  else console.log(data);
});
