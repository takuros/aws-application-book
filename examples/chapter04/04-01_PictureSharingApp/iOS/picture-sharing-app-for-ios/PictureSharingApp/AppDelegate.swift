//
//  AppDelegate.swift
//  PictureSharingApp
//

import UIKit

import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// デバイストークンを保持しておくための変数です。
    var deviceToken: String?

    /// アプリケーション起動時に呼ばれるメソッドです。
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Facebookの初期設定
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        // プッシュ通知の設定
        application.unregisterForRemoteNotifications()
        application.registerForRemoteNotifications()
        let mySettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(mySettings)

        return true
    }

    /// URLスキームで起動したときに呼ばれるメソッドです。
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // FacebookアプリやSafariを使ったSSOを利用するための設定
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    /// デバイストークンの取得に成功したときに呼ばれるメソッドです。
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // デバイストークンを加工して保持する
        self.deviceToken = deviceToken.description
            .stringByReplacingOccurrencesOfString(" ", withString: "")
            .stringByReplacingOccurrencesOfString("<", withString: "")
            .stringByReplacingOccurrencesOfString(">", withString: "")
        print("デバイストークンの取得に成功しました。（\(self.deviceToken)）")
    }

    /// デバイストークンの取得に失敗したときに呼ばれるメソッドです。
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("デバイストークンの取得に失敗しました。（\(error.description)）")
    }

    /// プッシュ通知受信時に呼ばれるメソッドです。
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("プッシュ通知を受信しました。（\(userInfo)）")
        if let message = userInfo["aps"]?["alert"] as? String {
            print("メッセージ: \(message)")

            // アプリ内通知
            let notification = NSNotification(name: "message", object: nil, userInfo: userInfo)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }

        completionHandler(.NoData)
    }

}

