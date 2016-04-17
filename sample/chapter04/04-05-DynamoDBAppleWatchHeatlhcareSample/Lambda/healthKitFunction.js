{\rtf1\ansi\ansicpg1252\cocoartf1404\cocoasubrtf460
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 console.log('Loading function');\
\
var doc = require('dynamodb-doc');\
var dynamo = new doc.DynamoDB();\
\
exports.handler = function(event, context) \{\
    var request = \{\
        "TableName":"HealthKit",\
        "Item":\{\
            "date":event.date,\
            "heartrate":event.heartrate\
        \}\
    \};\
    dynamo.putItem(request, function (err, data) \{\
    if (err) \{\
        console.log(err, err.stack);\
        context.succeed('error');\
    \} else \{\
        console.log(data);\
        context.succeed('success');\
    \}\});\
\};}