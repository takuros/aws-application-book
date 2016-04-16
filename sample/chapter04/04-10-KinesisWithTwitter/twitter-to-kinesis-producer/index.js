const Twitter = require('twitter');
const AWS = require('aws-sdk');

AWS.config.region = 'ap-northeast-1';

const kinesis = new AWS.Kinesis();

// 環境変数のTwitter認証情報を元にクライアントを初期化
const twitterClient = new Twitter({
  consumer_key        : process.env.TWITTER_CONSUMER_KEY,
  consumer_secret     : process.env.TWITTER_CONSUMER_SECRET,
  access_token_key    : process.env.TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret : process.env.TWITTER_ACCESS_TOKEN_SECRET
});

const buffer = [];
var last = new Date();

// 言語を日本語に絞ったランダムサンプリングStreamへ接続
twitterClient.stream('statuses/sample', {language : 'ja'}, function(stream) {
  stream.on('data', function(tweet) {

    if(tweet['created_at']){
      //ツイートの情報を減らしてバッファへ追加
      buffer.push(toSimpleRecord(tweet));
      const bufferSize = buffer.length;

      // 最後の送信から1000ms経過している場合に送信
      const now = new Date();
      if((now.getTime()) - (last.getTime()) > 1000){
        const params = {
          Records    : buffer.splice(0, bufferSize), //バッファから取得
          StreamName : 'twitter_stream'
        };

        kinesis.putRecords(params, function(err, data) {
            if (err) console.log(err, err.stack);
            else console.log(now + " :: sent " + data.Records.length + " tweets.");
        });
        // 最終送信時間を更新
        last = now;
      }
    }
  });

  stream.on('error', function(error) {
    console.warn(arguments);
    throw error;
  });
});

const toSimpleRecord = (json) => {
  const simple = {
    id     : json.id,
    id_str : json.id_str,
    text   : json.text,
    user   : {
      id          : json.user.id,
      id_str      : json.user.id_str,
      screen_name : json.user.screen_name,
      name        : json.user.name
    }
  };
  return {
    Data         : new Buffer(JSON.stringify(simple)),
    PartitionKey : json.id_str.split("").reverse().join("")
  };
};

// デーモン化
process.stdin.resume();
