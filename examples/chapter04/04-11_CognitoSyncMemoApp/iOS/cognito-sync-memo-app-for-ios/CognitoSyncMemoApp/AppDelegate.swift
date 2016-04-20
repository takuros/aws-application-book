//
//  AppDelegate.swift
//  CognitoSyncMemoApp
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

        return true
    }

    /// URLスキームで起動したときに呼ばれるメソッドです。
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // FacebookアプリやSafariを使ったSSOを利用するための設定
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

}

