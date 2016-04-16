/** kuromoji辞書ファイルのパス */
const KUROMOJI_DICT_PATH = "bower_components/kuromoji/dist/dict/";

chrome.runtime.onInstalled.addListener(() => {

  /** 記号除去関数 */
  const sanitize = (str) => {
    return (str || "").replace(/[!“”"#$%&'()\*\+\-\.,\/:;<=>?@\[\\\]^_`{|}~]/g, "");
  }

  /** トークナイザ */
  const tokenize = (tokenizer, str) => {
    if(!str) return [];
    return tokenizer.tokenize(str)
      .filter((token) => token.pos === '名詞' && token.surface_form.length > 1)
      .map((token) => sanitize(token.surface_form))
      .filter((word) => word.length > 1);
  };

  kuromoji.builder({ dicPath: KUROMOJI_DICT_PATH}).build((err, tokenizer) => {
    (($) => {
      chrome.runtime.onMessage.addListener((value, sender, callback) => {
        // ページ内スクリプトからメッセージを受信
        if(value.event == "callback.page_info"){
          // ページ情報をトークナイズ
          const result = {
            event: "callback.tokinized",
            page_info: {
              url         : value.page_info.url,
              title       : tokenize(tokenizer, value.page_info.title).join(" "),
              description : tokenize(tokenizer, value.page_info.description).join(" ")
            }
          }
          // ポップアップページへトークナイズしたページ情報を送信
          chrome.runtime.sendMessage(result, () => {});
        }
        callback();
      });
    })(jQuery);
  });

});
