// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

var params = {
  // テーブル名
  TableName: 'Music',
  // 更新するitemのプライマリーキー
  Key: {
    Artist: 'Artist1',
    SongTitle: 'Song1'
  },
  // 更新内容
  AttributeUpdates: {
    Category: {
      Action: 'PUT',
      Value:  ["CategoryA","CategoryB"]
    },
    RecordLabel: {
      Action: 'PUT',
      Value:  'label A'
    },
    ReleaseDate: {
      Action: 'ADD',
      Value:  5
    },
    Rank: {
      Action: 'DELETE'
    }
  }
};

// DocumentClientを利用
var docClient = new AWS.DynamoDB.DocumentClient();
// データを更新
docClient.update(params, function(err, data) {
   if (err) console.log(err);
   else console.log(data);
});
