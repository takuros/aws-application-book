(function($){
  chrome.runtime.onMessage.addListener((value, sender, callback) => {
    // ポップアップ画面からメッセージを受信
    if(value.event === "click.popup"){
      // ページから情報を抽出
      const payload = {
        event : "callback.page_info",
        page_info: {
          url : location.href,
          title : $('title').text(),
          description : $('meta[name=description]').attr('content')
        }
      }
      // バックグラウンドスクリプトへメッセージを送信
      chrome.runtime.sendMessage(payload, () => {});
    }
    callback();
  });
})(jQuery);
