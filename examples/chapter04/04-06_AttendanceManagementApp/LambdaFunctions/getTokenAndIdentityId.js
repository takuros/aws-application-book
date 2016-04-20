var AWS = require("aws-sdk");

var dynamoDB = new AWS.DynamoDB();
var cognitoIdentity = new AWS.CognitoIdentity();

var IDENTITY_POOL_ID = "＜Identity pool id＞";
var DEVELOPER_PROVIDER_NAME = "＜Developer provider name＞";

exports.handler = function(event, context) {
    var userId = event.userId;
    var password = event.password;
    
    // ユーザー情報の取得
    dynamoDB.getItem({
        TableName: "Users",
        Key: {
            UserId: { S: userId },
            Password: { S: password }
        }
    }, function(err, data) {
        if (err || !data["Item"]) {
            context.fail(new Error("Login failed."));
        } else {
            // パラメータの設定
            var param = {
                IdentityPoolId: IDENTITY_POOL_ID,
                Logins: {}
            };
            param.Logins[DEVELOPER_PROVIDER_NAME] = userId;
    
            // トークンの取得
            cognitoIdentity.getOpenIdTokenForDeveloperIdentity(
                param,
                function(err, data) {
                    if (err) {
                        context.fail(new Error("Cognito error."));
                    } else {
                        context.succeed({
                            identityId: data.IdentityId,
                            token: data.Token
                        });
                    }
                }
            )
        }
    });
};
