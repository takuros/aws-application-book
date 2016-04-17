{\rtf1\ansi\ansicpg1252\cocoartf1404\cocoasubrtf460
{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fnil\fcharset128 HiraginoSans-W3;}
{\colortbl;\red255\green255\blue255;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 console.log('Loading function');\
\
var aws = require('aws-sdk');\
var s3 = new aws.S3(\{ apiVersion: '2006-03-01' \});\
\
exports.handler = function(event, context) \{\
          //console.log('Received event:', JSON.stringify(event, null, 2));\
          //event
\f1 \'82\'a9\'82\'e7\'83\'6f\'83\'50\'83\'62\'83\'67\'96\'bc\'82\'c6\'83\'74\'83\'40\'83\'43\'83\'8b\'96\'bc\'82\'f0\'8e\'e6\'93\'be
\f0 \
          var bucket = event.Bucket;\
          var key = event.Key;\
          var params = \{\
              Bucket: bucket,\
              Key: key\
          \};\
          console.log('S3 params:', params);\
          //s3
\f1 \'82\'a9\'82\'e7\'83\'66\'81\'5b\'83\'5e\'82\'f0\'8e\'e6\'93\'be
\f0 \
          s3.getObject(params, function(err, data) \{\
              if (err) \{\
                  console.log(err);\
                  var message = "Error getting object " + key + " from bucket " + bucket +\
                      ". Make sure they exist and your bucket is in the same region as this function.";\
                  console.log(message);\
                  context.fail(message);\
              \} else \{\
                  console.log('CONTENT TYPE:', data.ContentType);\
                  try\{\
                      var response = JSON.parse(data.Body.toString());\
                      console.log('DATA:',response);\
                      context.succeed(response);\
                   \}catch(err)\{\
                      console.log(err);\
                      var message = "JSON parse Error getting object " + key + " from bucket " + bucket;\
                      console.log(message);                       \
                      context.fail(err); \
                \}\
              \}\
          \});\
\};}