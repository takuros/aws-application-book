chrome.runtime.onInstalled.addListener(() => {
  chrome.history.onVisited.addListener((history) => {
    const data = {
      UUID: UUID.generate(),
      url : history.url,
      timestamp : new Date().getTime()
    }
    $.ajax({
      url: "https://<ランダム>.execute-api.ap-northeast-1.amazonaws.com/v1/webhistories",
      method: "POST",
      dataType: "json",
      processData: false,
      data: JSON.stringify(data),
      contentType: "application/json"
    }).fail((xhr, status, error) => {
      console.warn("Error", error);
    }).done((data) => {
       console.log("Success", data);
    });
  });
});
