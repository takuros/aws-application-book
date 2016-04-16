const fs       = require('fs');
const http     = require('http');
const socketIO = require('socket.io');
const server   = http.createServer();
const io       = socketIO.listen(server);

const consumer = require('./consumer');
const STREAM_ARN = "<DynamoDBStreamのARN>";

// index ページを表示させる
server.on('request', (req, res) => {
  if(!res.finished){
    res.writeHead(200, {'Content-Type' : 'text/html'});
    res.end(fs.readFileSync('index.html'));
  }
});

server.listen(8000);

consumer(STREAM_ARN, (emitter) =>{
  // DynamoDBStreamsに接続
  io.sockets.on('connection', (socket) => {
    // Socket接続後DynamoDBからメッセージを受信
    emitter.on('records', (records) => {
      records.map((record) => {
        // DynamoDBの追加イベントのみを処理
        if(record.eventName !== 'INSERT') return;
        const rec = record.dynamodb.NewImage;
        // DynamoDB形式のデータを通常のオブジェクトに変換
        const words = rec.Words.L.map((w) => {
          return {
            word  : w.M.word.S,
            count : parseInt(w.M.count.N)
          };
        });
        const trends = {
          DateTime : parseInt(rec.DateTime.N),
          Words    : words
        };
        //socket.ioでデータを流す
        socket.emit('record', trends);
      });
    });
  });
});
