var AWS = require("aws-sdk");

var dynamoDB = new AWS.DynamoDB();

function getDateString(orgDate, timezone) {
    // タイムゾーンに合わせた日時の取得
    var date = new Date(
        orgDate.getTime() +
        (orgDate.getTimezoneOffset() * 60 * 1000) +
        (timezone * 60 * 60 * 1000)
    );

    var str; 
    return ("" +
        date.getFullYear() +
        (str = ("0" + (date.getMonth() + 1))).substr(str.length - 2, 2) +
        (str = ("0" +  date.getDate()      )).substr(str.length - 2, 2)
    );
}

exports.handler = function(event, context) {
    var userId = event.userId;
    
    // 今日の日付文字列（YYYYMMDD）を取得する（タイムゾーン：+0900）
    var dateString = getDateString(new Date(), +9);

    // 出社登録する
    dynamoDB.putItem({
        TableName: "Attendances",
        Item: {
            "UserId": { S: userId },
            "Date": { S: dateString }
        }
    }, function(err, data) {
        context.succeed({ status: "OK" });
    });
};
