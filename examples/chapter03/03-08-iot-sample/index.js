const IoT = require('aws-iot-device-sdk');
const process = require("process");

const stdin = process.openStdin();

const clientId  = process.argv[2];               // 引数をMQTTのクライアントIDとする
const topic     = "chatroom";                    // publish/subscribe するトピック

const certDir = '<ホームディレクトリへのパス>/awsCerts';

const device = IoT.device({
    keyPath  : certDir + '/private.pem.key',     // 秘密鍵
    certPath : certDir + '/certificate.pem.crt', // 証明書
    caPath   : certDir + '/root-CA.crt',         // ルート証明書
    clientId : clientId,                         // クライアントID
    region   : 'ap-northeast-1'                  // リージョン
});

device
    .on('connect', function() {
        // 接続成功時のコールバック
        console.log('connected as ' + clientId + ', press Ctrl+C to exit.');

        //トピック "chatroom" を subscribe する
        device.subscribe(topic);

        // コンソールから入力された文字列を publish する
        stdin.addListener("data", function(d) {
            const payload = { user : clientId, message : d.toString().trim()};
            device.publish(topic, JSON.stringify(payload));
        });
    });

device
    .on('message', function(topic, payload) {
        // メッセージ受信時のコールバック
        const data = JSON.parse(payload);
        if(data.user != clientId){
            // 他デバイスからのメッセージをコンソールへ表示
            console.log(data.message, "<<<", data.user);
        }
    });
