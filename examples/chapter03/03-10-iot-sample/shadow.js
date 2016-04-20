const IoT = require('aws-iot-device-sdk');

const device  = 'my_first_iot_device';          // デバイスを設定
const certDir = '<ホームディレクトリへのパス>/awsCerts';         // 証明書を格納したディレクトリを設定
const callbacks = {};                           // 非同期コールバックを格納するオブジェクト

var state = { power : 'OFF' };                     // デバイスのスイッチの状態を保持
console.log("initial state:", state);

const shadow = IoT.thingShadow({
  keyPath  : certDir + '/private.pem.key',     // 秘密鍵
  certPath : certDir + '/certificate.pem.crt', // 証明書
  caPath   : certDir + '/root-CA.crt',         // ルート証明書
  clientId : device,                           // クライアントID
  region   : 'ap-northeast-1'                  // リージョン
});

/** 現在の状態をシャドウサービスへ送信する関数 */
const reportState = function(callback){
  const report = {state : {reported : state}};
  const callbackToken = shadow.update(device, report);

  if(callbackToken){
    callbacks[callbackToken] = callback || function(){
      console.log("report success", state);
    };
  }
};

shadow
  .on('connect', function() { // 接続成功コールバック
    shadow.register(device);      // シャドウを登録
    setTimeout(reportState, 500); // シャドウに初期状態を通知
  })
  .on('status', function(thingName, status, clientToken) {  // メッセージ受信時のコールバック
    callbacks[clientToken].apply(undefined, arguments); // コールバックを実行
    delete callbacks[clientToken]; // コールバックを開放
  })
  .on('delta', function(thingName, stateObject) { // 差分受信時のコールバック
    console.log('received delta', stateObject.state);
    state = stateObject.state; // スイッチの状態を反映
    setTimeout(reportState, 1000); // 差分反映後の状態を通知
  });
