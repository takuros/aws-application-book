//
//  Request.swift
//  awstest
//
//  Created by s-takayanagi2 on 2/29/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import UIKit

class Request: NSObject {
    
    // APIリクエスト
    func requestAPI(heartrate: String,date: String,completion:(result: String) -> Void){
        let session = NSURLSession.sharedSession()
        //TODO URLを変更
        let urlString = "https://khqn3yihnb.execute-api.ap-northeast-1.amazonaws.com/test/"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //TODO APIkeyを変更
        request.addValue("SAX4qXwllH2BkHf2Gvzbz45Xuv4jtJmY8lMNSAc7", forHTTPHeaderField: "x-api-key")
        
        // set the request-body(JSON)
        let params = ["heartrate":heartrate,"date":date] as Dictionary<String, String>
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options:[])
            //リクエスト生成
            let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
                if (error == nil) {
                    let string = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    NSLog("%@", string!)
                    completion(result: "success")
                }else{
                    completion(result: "error")
                }
            })
            //実行
            task.resume()
        } catch  {
            // エラー
            completion(result: "error")
        }
    }
}
