//
//  AppDelegate.swift
//  awstest
//
//  Created by s-takayanagi2 on 2/20/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import UIKit
import FBSDKCoreKit

//TODO Identiferの設定変更
//TODO Code signingの設定変更
//TODO プロビジョニングの設定変更
//TODO Constants.swiftのidentityPoolIdをAWS Cognitoで作成したものに変更
//TODO Info.plistのFacebookappを実際の値に修正

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // iOSハンドラー
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Cognitoの初期設定を実施する
        LoginManager.sharedInstance
        
        // iOS ローカル通知を削除
        UIApplication.sharedApplication().cancelAllLocalNotifications();
        
        // iOS ローカル通知用　及び Push Sync用のリモートプッシュ通知の設定をする
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.identityDidChange(_:)), name: AWSCognitoIdentityIdChangedNotification, object: nil)
        return true
    }
    
    // iOSハンドラー Push Sync AWS SNS用 プッシュ通知設定
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        // 明示的にリモートプッシュ通知を有効にする
        application.registerForRemoteNotifications()
    }
    
    // iOSハンドラー Push Sync AWS SNS プッシュ通知設定用のDeviceToken取得
    func application( application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken:NSData ) {
        NSLog("devicetoken : %@", deviceToken)
        #if DEBUG
            //Debugビルドの時はAPNS_SANDBOXを指定する Releaseビルドの場合は未指定(APNS)を利用する
            AWSCognito.setPushPlatform(AWSCognitoSyncPlatform.ApnsSandbox)
        #endif
        let syncClient = AWSCognito.defaultCognito()
        
        syncClient.registerDevice(deviceToken).continueWithBlock { (task: AWSTask!) -> AnyObject? in
            if (task.error != nil) {
                print("Unable to register device: " + task.error!.localizedDescription)
                self.localNotification("Push通知登録失敗", body: "Unable to register device: " + task.error!.localizedDescription)
            } else {
                print("Successfully registered device with id: \(task.result)")
                self.localNotification("Push通知登録完了", body: " \(task.result)")
            }
            return nil
        }
    }
    
    // iOSハンドラー Push Sync AWS SNS Push通知のデータ受信
    func application(application: UIApplication,didReceiveRemoteNotification userInfo: [NSObject :AnyObject],fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        // ここにデータが受信
        // データの処理
        ReceivePushSyncManager.didReceivePushSync(userInfo) { result in
            if result {
                completionHandler(UIBackgroundFetchResult.NewData)
            }else{
                completionHandler(UIBackgroundFetchResult.NoData)
            }
        }
    }
    
    // ローカル通知を実施
    func localNotification(title:String, body:String){
        let localNotification = UILocalNotification()
        localNotification.alertTitle = title
        localNotification.alertBody = body
        localNotification.alertAction = "OK"
        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
    }
    
    // ローカル通知をフォアグラウンド状態で受信した場合の処理
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let alertController = UIAlertController(title: notification.alertTitle, message: notification.alertBody, preferredStyle: .ActionSheet)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            print("alert ok")
        }
        alertController.addAction(okAction)
        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    // CognitoのIdentityが変更された時のハンドラー
    func identityDidChange(notification: NSNotification!) {
        if let userInfo = notification.userInfo as? [String: AnyObject] {
            print("identity changed from: \(userInfo[AWSCognitoNotificationPreviousId]) to: \(userInfo[AWSCognitoNotificationNewId])")
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {

    }


}

