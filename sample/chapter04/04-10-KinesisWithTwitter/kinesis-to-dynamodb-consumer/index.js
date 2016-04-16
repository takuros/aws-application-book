const AWS         = require('aws-sdk');
AWS.config.region = 'ap-northeast-1';
const doc         = require('dynamodb-doc');
const kuromoji    = require('kuromoji');

// コンシューマをインクルード
const kinesisStreamConsumer = require('./consumer');

const dynamoDB = new doc.DynamoDB();

// 除外する品詞細分類1
const ignoreDetails = ['代名詞', '数', '接尾', '非自立'];

const filter = (str) => str
    .replace(/https?:\/\/[^\s]+/g, '')  // URLを除去
    .replace(/[wｗ]{2,}/g, '')          // 笑いを表す"w"を除去
    .replace(/@[A-z0-9_]+/g, '')        // @から始まるTwitterユーザー名を除去
    .replace(/RT/g, '')                 // リツイートを表す"RT"を除去
    .replace(/(#([^\s]+))/g, '$2');     // ハッシュタグの"#"を除去

//
const tokenFilter = (tokens) => tokens.filter((p) => {
  return p.word_type === 'KNOWN'               // 辞書に登録されているもの
  && (p.pos == '名詞')                         // 名詞に限定
  && ignoreDetails.indexOf(p.pos_detail_1) < 0 // 除外する品詞細分類1で無いこと
  && !/^[0-9+]$/.test(p.basic_form);           // 数字を除外
});

kuromoji.builder({ dicPath : 'node_modules/kuromoji/dist/dict' }).build((err, tokenizer) => {
  console.log("tokenizer is ready");
  var lastSubmission = new Date();
  const words = [];
  kinesisStreamConsumer('twitter_stream', (records) => {
    const pathes = records.map((record) => {
      const json = JSON.parse(new Buffer(record.Data, 'base64').toString('utf-8'));
      const tokens = tokenFilter(tokenizer.tokenize(filter(json.text)));
      return tokens.map((w) => w.basic_form);
    });
    const tmp = Array.prototype.concat.apply([], pathes); //flatten
    Array.prototype.push.apply(words, tmp);

    const now = new Date();

    // 10秒ごとに単語数を集約しDynamoDBに送信
    if((now.getTime() - lastSubmission.getTime()) > (10 * 1000)){
      const size = words.length;
      const copy = words.splice(0, size);
      lastSubmission = now;
      //{単語 : カウント} 形式のMapへ集約
      const wordCountMap = copy.reduce((map, word) => {
        map[word] = (map[word] || 0 ) + 1;
        return map;
      }, Object.create(null));
      // [{word: 単語, count: カウント}] 形式の配列へ変換
      const wordCountList = Object.keys(wordCountMap).map((word) => {
        return {
          word  : word,
          count : wordCountMap[word]
        };
      });
      // 出現回数が2回以上のものを出現回数が多い順番に30個取得
      const top30 = wordCountList
        .filter((w) => w.count >= 2)
        .sort((a, b) => a.count < b.count ? 1 : -1)
        .splice(0, 30);

      const request = {
        TableName : "TweetWords",
        Item      : {
          DateTime : (new Date().getTime()),
          Words    : top30
        }
      };
      // DynamoDBへ格納
      dynamoDB.putItem(request, (err) => {
        if(err) console.warn(err, err.stack);
        else console.log(new Date() +" :: DynamoDB.putItem success");
      });
    }
  });
});
// デーモン化
process.stdin.resume();
