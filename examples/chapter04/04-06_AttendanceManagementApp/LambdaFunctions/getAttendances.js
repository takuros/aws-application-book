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
    // 今日の日付文字列（YYYYMMDD）を取得する（タイムゾーン：+0900）
    var dateString = getDateString(new Date(), +9);

    // 出社状況一覧の取得
    dynamoDB.scan({
        TableName: "Users",
        Select: "ALL_ATTRIBUTES"
    }, function(err, data) {
        if (err) {
            context.fail(new Error("DynamoDB error. (Users)"));
        } else if (!data["Items"]) {
            context.succeed({
                items: []
            });
        } else {
            var users = data["Items"];
            
            // 当日分の勤怠情報一覧の取得
            dynamoDB.scan({
                TableName: "Attendances",
                Select: "ALL_ATTRIBUTES",
                ScanFilter: {
                    Date: {
                        AttributeValueList: [{ S: dateString }],
                        ComparisonOperator: "EQ"
                    }
                }
            }, function(err, data) {
                if (err) {
                    context.fail(new Error("DynamoDB error. (Attendances)"));
                } else {
                    var attendances = data["Items"];

                    // 結果の返却
                    var result = users.map(function(elm, index, arr) {
                        var userId = elm["UserId"].S;
                        var userName = elm["UserName"].S;
                        var attendance = !!attendances.filter(function(elm, index, arr) {
                            return userId === elm["UserId"].S;
                        }).length;
                        return {
                            userId: userId,
                            userName: userName,
                            attendance: attendance
                        };
                    });
                    context.succeed({ items: result });
                }
            });
        }
    });
};
