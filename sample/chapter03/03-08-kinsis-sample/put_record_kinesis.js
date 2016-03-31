// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'ap-northeast-1';

// Kinesis クライアント
var kinesis = new AWS.Kinesis();

function sendTemperatureData(count) {
  var now = (new Date).getTime();

  // データレコード
  var data = {
    // ランダムに温度データを生成
    temperature : Number((Math.random() * 20).toFixed(2)) + 10,
    timestamp   : now
  };

  // パーティションキーを生成
  var partitionKey = now.toString().split("").reverse().join("");

  // Putパラメータ
  var params = {
    Data         : new Buffer(JSON.stringify(data)), // データレコードBLOB
    PartitionKey : partitionKey,                     // パーティションキー
    StreamName   : "TemperatureSensorStream"         // ストリーム名
  };

  kinesis.putRecord(params, function(err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else console.log(count + " : " + JSON.stringify(data));
  });

}

(function loop(count) {
    // ランダムな間隔で送信
    var rand = Math.round(Math.random() * (1000 - 500)) + 500;
    setTimeout(function() {
      sendTemperatureData(count);
      loop(count + 1);
    }, rand);
}(0));

process.stdin.resume();
console.log("started. press Ctrl+C to stop.");
