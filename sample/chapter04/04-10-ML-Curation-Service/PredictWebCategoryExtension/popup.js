(($) => {
  const API = "https://<ランダム>.execute-api.ap-northeast-1.amazonaws.com/v1/categorize";
  const feedURL = (tag) => "http://b.hatena.ne.jp/search/tag?q=" + tag + "&mode=rss";
  // カテゴリ表示関数
  const displayCategory = (prediction, cached) => {
    const label   = prediction.predictedLabel;
    const percent = prediction.predictedScores[label] * 100;
    const cachedLabel = cached ? "[キャッシュ]" : "";
    $("#predicted").text(label + "("+ percent.toFixed(2) +"%)" + cachedLabel);
  };
  // 関連ページフィード読み込み関数
  const loadFeed = (prediction) => {
    $.get(feedURL(prediction.predictedLabel) )
    .done((data)=>{
      const $ul = $("#related_pages").empty();
      $(data).find("item:lt(10)").map((index, item) =>{
        const $item = $(item);
        const title = $item.find("title").text(),
              url   = $item.find("link").text();
        const $li = $('<li/>').append(
          $('<a/>').attr('href', url).attr('target', '_blank').html(title)
        );
        $ul.append($li);
      })
    })
  };
  chrome.runtime.onMessage.addListener((value, sender, callback) => {
    // バックグラウンドスクリプトからメッセージを受信
    if(value.event == "callback.tokinized"){
    const pageInfo = value.page_info;
    $("#title").text(pageInfo.title);
    $("#url").text(pageInfo.url);
    $("#summary").text(pageInfo.summary);

    // localStorageに予測済みデータがあるか確認
    if(localStorage["predicted_category__" + pageInfo.url]){
      // キャッシュされている場合はキャッシュを利用
      const prediction = JSON.parse(localStorage["predicted_category__" + pageInfo.url]);
      // カテゴリ情報を表示
      displayCategory(prediction, true);
      // 関連ページをロード
      loadFeed(prediction);
    }else{
      // キャッシュがない場合はAPIGatewayへAjax通信を行う
      $.ajax({
        url: API,
        method: "POST",
        dataType: "json",
        processData: false,
        data: JSON.stringify(pageInfo),
        contentType: "application/json"
      }).fail((xhr, status, error) => {
        console.warn(error);
      }).done((data) => {
        const prediction = data.Prediction;
        // 予測結果を localStorage にキャッシュ
        localStorage["predicted_category__" + pageInfo.url] = JSON.stringify(prediction);
        // カテゴリ情報を表示
        displayCategory(prediction, false);
        // 関連ページをロード
        loadFeed(prediction);
      });
    }

  }
  callback();
  });

  // ポップアップ表示時にアクティブなタブを抽出
  chrome.tabs.query({active:true}, function(tabs){
    tabs
    .filter((tab) => tab.highlighted)
    .map((tab) => {
      // 対象のタブにメッセージを送信
      chrome.tabs.sendMessage(tab.id, {"event": "click.popup"}, function(response){});
    });

  });
})(jQuery);
