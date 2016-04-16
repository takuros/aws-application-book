var request = require('request');
exports.dynamodb = function(event, context) {
  price_api_url = 'https://pricing.us-east-1.amazonaws.com';
  dynamodb_price_list_path = '/offers/v1.0/aws/AmazonDynamoDB/current/index.json';
  request(price_api_url + dynamodb_price_list_path, function (error, response, body) {
    if (!error && response.statusCode == 200) {
      res_to_json = JSON.parse(body);
      tokyo_ondemand_price = res_to_json.terms.OnDemand.QS5WYUWZHW5DU5CA;
      context.succeed(tokyo_ondemand_price);
    } else {
      context.fail('Something went wrong');
    }
  });
};
