//
//  ReceivePushSyncManager.swift
//  awstest
//
//  Created by s-takayanagi2 on 3/28/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import Foundation
import FBSDKCoreKit

class ReceivePushSyncManager:NSObject {
    
    class func didReceivePushSync(notification: [NSObject :AnyObject],completionHandler:(Bool) -> Void) {
        // identityIdを取得
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APNortheast1,
                                                                identityPoolId:Constants.CognitoPoolID.rawValue)
        
        // Facebookのアクセストークンを取得する。
        if let token = FBSDKAccessToken.currentAccessToken() {
            // tokenが存在している場合はFacebookログイン済みとしてcredentialsProviderのLoginsにtokenを設定する
            credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token.tokenString]
        }
        
        let configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        credentialsProvider.getIdentityId().continueWithBlock { (AWSTask) -> AnyObject? in
            print(credentialsProvider.identityId)
            
            // Initialize the Cognito Sync client
            let syncClient = AWSCognito.defaultCognito()
            
            // Create a record in a dataset and synchronize with the server
            let dataset = syncClient.openOrCreateDataset("myDataset")
            if let data = notification["data"] as? [NSObject: AnyObject] {
                let identityId = data["identityId"] as! String
                let datasetName = data["datasetName"] as! String
                if dataset.name == datasetName && credentialsProvider.identityId == identityId {
                    dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                        if task.error == nil {
                            print("Successfully synced dataset")
                            // NSNotificationでデータ更新完了したことを伝える
                            NSNotificationCenter.defaultCenter().postNotificationName("refreshText", object: nil)
                            // ローカル通知でデータ更新完了したことを伝える
                            let localNotification = UILocalNotification()
                            localNotification.alertTitle = "更新完了"
                            localNotification.alertBody = datasetName+"の"+"myKeyを"+dataset.stringForKey("myKey")+"に更新しました"
                            localNotification.alertAction = "OK"
                            UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
                            
                            completionHandler(true)
                        }else{
                            completionHandler(false)
                        }
                        return nil
                    }
                }else{
                    completionHandler(false)
                }
            }else{
                completionHandler(false)
            }
            return nil
        }
        
    }
}