// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

// 検索する値
searchArtist = "Artist1";
searchReleaseDate = 20160101;

var params = {
  // テーブル名
  TableName : 'Music',
  // インデックス名
  IndexName : 'Artist-ReleaseDate-index',
  // 検索条件（セカンダリインデックスのプライマリーキー）
  KeyConditionExpression: 'Artist = :partitionKey and ReleaseDate > :sortKey',
  ExpressionAttributeValues: {
    ':partitionKey': searchArtist,
    ':sortKey': searchReleaseDate
  }
};

// DocumentClientを利用
var docClient = new AWS.DynamoDB.DocumentClient();
// クエリ実行
docClient.query(params, function(err, data) {
   if (err) console.log(err);
   else console.log(data);
});
