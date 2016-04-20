var aws = require('aws-sdk');
aws.config.region = 'ap-northeast-1';
var cognitoidentity = new aws.CognitoIdentity();

var google = require('googleapis');
var plus = google.plus('v1');
var OAuth2 = google.auth.OAuth2;

var async = require('async');

exports.handler = function(event, context) {
  async.waterfall([
    function(callback){
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
            console.log("Cognito Registered : " + aws.config.credentials);
            callback(null)
          }
      });
    },
    function(callback){
      var oauth2Client = new OAuth2();
      oauth2Client.setCredentials({
        access_token: event.access_token
      });
      plus.people.get({ 'userId': 'me', 'auth': oauth2Client},
        function(err, response) {
          if (err) context.fail(err);
          else {
            console.log("UserInfo Save DynamoDB");
            callback(null,response)
          }
      });
    },
    function(user,callback){
      var docClient = new aws.DynamoDB.DocumentClient();
      var params = {
        TableName : 'UserInfo',
        Item: {
           id: user.id,
           Name: user.displayName,
           gender: user.gender,
           role: "Common"
        }
      };
      docClient.put(params, function(err, data) {
        if (err) context.fail(err);
        else {
          console.log(data);
          callback(null)
        }
      });
    }
  ],
  function(err, results){
      context.succeed("Register Process End")
  });
}
