"use strict"; // ECMAScript6のclassを利用するためstrictモードを利用
const AWS           = require('aws-sdk');
AWS.config.region   = 'ap-northeast-1';
const EventEmitter  = require('events');

const kinesis = new AWS.Kinesis();

//シャードのメッセージを消化する関数
const consume = (streamName, shardId, emitter) => {
  console.log("consume shard : " + shardId);
  const params = {
    StreamName        : streamName,
    ShardId           : shardId,
    ShardIteratorType : 'LATEST'
  };
  // 初回シャードイテレータを取得
  kinesis.getShardIterator(params, (err, data) => {
    console.log("shard iterator : " + data.ShardIterator);
    if(err){
      throw err;
    } else {
      // getRecordsレスポンスのNextShardIteratorに対して処理を繰り返す
      (function recordConsumer(shard){
        const params = { ShardIterator : shard };
        kinesis.getRecords(params, (err, data) => {
          if(err) {
            throw err;
          } else {
            // レコードが存在していた場合にイベントを発報
            if(data.Records.length > 0){
              emitter.emit('records', data.Records);
            }
            if(data.NextShardIterator){
              recordConsumer(data.NextShardIterator);
            } else {
              console.log("empty next shard iterator");
            }
          }
        });
      })(data.ShardIterator);
    }
  });
};
// Streamの情報を取得する関数
const describe = (streamName, callback) => {
  console.log("describe : " + streamName);
  const params = { StreamName : streamName };
  kinesis.describeStream(params, (err, data) => {
    if(err){
      console.warn(err);
      throw err;
    } else {
      const description = data.StreamDescription;
      console.log("stream status : " + description.StreamStatus);
      // ステータスがACTIVEとなっている場合コールバックを実行
      if(description.StreamStatus === 'ACTIVE') {
        callback(description.Shards);
      }else{
        console.warn("stream status :: " + description.StreamStatus);
      }
    }
  });
};

class RecordsEmitter extends EventEmitter {}

module.exports = (streamName, callback) => {
  const emitter = new RecordsEmitter();
  describe(streamName, (shards) =>{
    // シャードごとにコンシューマを実行
    shards.map((shard) => {
      consume(streamName, shard.ShardId, emitter);
    });
    // レコードを受け取ったらコールバックを実行
    emitter.on('records', callback);
  });
};
