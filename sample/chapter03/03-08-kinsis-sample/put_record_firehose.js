// SDKを読み込み
var AWS = require("aws-sdk");
// リージョンを設定
AWS.config.region = 'us-west-2';

var firehose = new AWS.Firehose();

function sendTemperatureData(count) {
  // タイムスタンプ
  var timestamp = (new Date).getTime();
  // ランダムに温度データを生成
  var temperature = Number((Math.random() * 20).toFixed(2)) + 10
  // CSV レコードを作成
  var data = '"' + temperature + '","' + timestamp + '"\n';

  var params = {
    Record: {
      // データレコードBLOB
      Data: new Buffer(data)
    },
    // デリバリーストリーム名
    DeliveryStreamName: "TemperatureSensorFirehose"
  };

  firehose.putRecord(params, function(err, data) {
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
