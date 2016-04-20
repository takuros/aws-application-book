// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

// 検索する値
searchArtist = "Artist1";
searchSongTitle = "Song1";

var params = {
  // テーブル名
  TableName : 'Music',
  // 検索条件
  KeyConditionExpression: 'Artist = :partitionKey and SongTitle = :sortKey',
  ExpressionAttributeValues: {
    ':partitionKey': searchArtist,
    ':sortKey': searchSongTitle
  }
};

// DocumentClientを利用
var docClient = new AWS.DynamoDB.DocumentClient();
// クエリ実行
docClient.query(params, function(err, data) {
   if (err) console.log(err);
   else console.log(data);
});
