/* == Imports == */
var AWS = require('aws-sdk');
var path = require('path');

/* == Globals == */
var esDomain = {
    region: 'ap-northeast-1',
    endpoint: 'search-healthkitsearch-XXXXXXXXXXXXXXX.ap-northeast-1.es.amazonaws.com', //TODO修正
    index: 'healthkitindex',
    doctype: 'healthkittype'
};
var endpoint = new AWS.Endpoint(esDomain.endpoint);
var creds = new AWS.EnvironmentCredentials('AWS');


/* Lambda "main": Execution begins here */
exports.handler = function(event, context) {
    event.Records.forEach(function(record) {
        console.log(record.eventID);
        console.log(record.eventName);
        console.log('DynamoDB Record: %j', record.dynamodb);
        if(record.eventName==="INSERT")
        {
        	// JSON生成
            var jsonData = {};
            jsonData.date =record.dynamodb.NewImage.date.S;
            jsonData.heartrate = Number(record.dynamodb.NewImage.heartrate.S);
            console.log(JSON.stringify(jsonData)); 
    	    // ESに送る
    	    postToES(JSON.stringify(jsonData), context);
        }
        else
        {
        	context.succeed('追加ではないので終了 ' + record.eventName);
        }

    });
}


/*
 * Post the given document to Elasticsearch
 */
function postToES(doc, context) {
    var req = new AWS.HttpRequest(endpoint);
    req.method = 'POST';
    req.path = path.join('/', esDomain.index, esDomain.doctype);
    req.region = esDomain.region;
    req.headers['presigned-expires'] = false;
    req.headers['Host'] = endpoint.host;
    req.body = doc;

    var signer = new AWS.Signers.V4(req , 'es');  // es: service code
    signer.addAuthorization(creds, new Date());

    var send = new AWS.NodeHttpClient();
    send.handleRequest(req, null, function(httpResp) {
        var respBody = '';
        httpResp.on('data', function (chunk) {
            respBody += chunk;
        });
        httpResp.on('end', function (chunk) {
            console.log('Response: ' + respBody);
            context.succeed('Lambda added document ' + doc);
        });
    }, function(err) {
        console.log('Error: ' + err);
        context.fail('Lambda failed with error ' + err);
    });
}
