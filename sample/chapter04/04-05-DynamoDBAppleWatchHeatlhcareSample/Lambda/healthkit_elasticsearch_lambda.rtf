{\rtf1\ansi\ansicpg1252\cocoartf1404\cocoasubrtf460
{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset128 HiraginoSans-W3;}
{\colortbl;\red255\green255\blue255;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 /* == Imports == */\
var AWS = require('aws-sdk');\
var path = require('path');\
\
/* == Globals == */\
var esDomain = \{\
    region: 'ap-northeast-1',\
    endpoint: 'search-healthkitsearch-XXXXXXXXXXX.ap-northeast-1.es.amazonaws.com',\
    index: 'healthkitindex',\
    doctype: 'healthkittype'\
\};\
var endpoint = new AWS.Endpoint(esDomain.endpoint);\
var creds = new AWS.EnvironmentCredentials('AWS');\
\
\
/* Lambda "main": Execution begins here */\
exports.handler = function(event, context) \{\
    event.Records.forEach(function(record) \{\
        console.log(record.eventID);\
        console.log(record.eventName);\
        console.log('DynamoDB Record: %j', record.dynamodb);\
        if(record.eventName==="INSERT")\
        \{\
        	// JSON
\f1 \'90\'b6\'90\'ac
\f0 \
            var jsonData = \{\};\
            jsonData.date =record.dynamodb.NewImage.date.S;\
            jsonData.heartrate = Number(record.dynamodb.NewImage.heartrate.S);\
            console.log(JSON.stringify(jsonData)); \
    	    // ES
\f1 \'82\'c9\'91\'97\'82\'e9
\f0 \
    	    postToES(JSON.stringify(jsonData), context);\
        \}\
        else\
        \{\
        	context.succeed('
\f1 \'92\'c7\'89\'c1\'82\'c5\'82\'cd\'82\'c8\'82\'a2\'82\'cc\'82\'c5\'8f\'49\'97\'b9
\f0  ' + record.eventName);\
        \}\
\
    \});\
\}\
\
\
/*\
 * Post the given document to Elasticsearch\
 */\
function postToES(doc, context) \{\
    var req = new AWS.HttpRequest(endpoint);\
    req.method = 'POST';\
    req.path = path.join('/', esDomain.index, esDomain.doctype);\
    req.region = esDomain.region;\
    req.headers['presigned-expires'] = false;\
    req.headers['Host'] = endpoint.host;\
    req.body = doc;\
\
    var signer = new AWS.Signers.V4(req , 'es');  // es: service code\
    signer.addAuthorization(creds, new Date());\
\
    var send = new AWS.NodeHttpClient();\
    send.handleRequest(req, null, function(httpResp) \{\
        var respBody = '';\
        httpResp.on('data', function (chunk) \{\
            respBody += chunk;\
        \});\
        httpResp.on('end', function (chunk) \{\
            console.log('Response: ' + respBody);\
            context.succeed('Lambda added document ' + doc);\
        \});\
    \}, function(err) \{\
        console.log('Error: ' + err);\
        context.fail('Lambda failed with error ' + err);\
    \});\
\}}