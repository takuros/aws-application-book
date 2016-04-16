var aws = require('aws-sdk');
aws.config.region = 'ap-northeast-1';
var cognitoidentity = new aws.CognitoIdentity();

exports.handler = function(event, context) {
    var params = {
        AccountId: <アカウントID>,
        RoleArn: <認証時に付与するロール>,
        IdentityPoolId: <作成したCognitoのidentity pool>,
        Logins: {
          'accounts.google.com':event.id_token
        }
    };

    aws.config.credentials = new aws.CognitoIdentityCredentials(params);
    aws.config.credentials.get(function(err) {
        if (err) context.fail(err);
        else {
            console.log(aws.config.credentials);
            context.succeed("Registered");
        }
    });
}
