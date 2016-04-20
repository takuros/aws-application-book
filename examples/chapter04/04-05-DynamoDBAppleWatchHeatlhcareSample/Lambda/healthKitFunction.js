console.log('Loading function');
var doc = require('dynamodb-doc');
var dynamo = new doc.DynamoDB();

exports.handler = function(event, context) {
    var request = {
        "TableName":"HealthKit",
        "Item":{
            "date":event.date,
            "heartrate":event.heartrate
        }
    };
    dynamo.putItem(request, function (err, data) {
    if (err) {
        console.log(err, err.stack);
        context.succeed('error');
    } else {
        console.log(data);
        context.succeed('success');
    }});
};}
