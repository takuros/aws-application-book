//
//  AppDelegate.swift
//  awstest
//
//  Created by s-takayanagi2 on 2/20/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import UIKit
import WatchConnectivity
import HealthKit

//TODO Identiferの設定変更(WKCompanionAppBundleIdentifierやWKCompanionAppBundleIdentifierも含む)
//TODO Code signingの設定変更
//TODO プロビジョニングの設定変更
//TODO HealthKitの有効化


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var wcSession = WCSession.defaultSession()
    let healthStore = HKHealthStore()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // AppleWatch初期化
        if WCSession.isSupported() {
            wcSession.delegate = self
            wcSession.activateSession()
        }
        return true
    }
    
    // AppleWatchからHealthKitの利用承認
    func applicationShouldRequestHealthAuthorization(application: UIApplication) {
        self.healthStore.handleAuthorizationForExtensionWithCompletion { success, error in
            print("applicationShouldRequestHealthAuthorization: \(success)")
        }
    }
    // AppleWatchからのデータ
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        print("AppleWatchからのメッセージ")
//        if let name = message["name"] as? String {
//            print(name)
//            if name == "XXのAppleWatch"{
//                //特定の端末の場合を送信することが可能です
//            }
//
//        }
        
        let heartrate = message["heartRate"] as? String
        let date = message["date"] as? String
        
        //Requestを生成する
        let request = Request()
        request.requestAPI(heartrate!, date: date!) { (result) -> Void in
            if result == "success"{
                //AppleWatchにデータ送信できたことを通知
                self.sendSuccessMessage()
            }else{
                //AppleWatchにデータ送信できたことを通知
                self.sendErrorMessage()
            }
        }
    }
    
    // send message to watch
    func sendSuccessMessage() {
        // 成功をwatchに転送する
        let message = ["Parent":"success"]
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
    }
    
    // send message to watch
    func sendErrorMessage() {
        // エラーをwatchに転送する
        let message = ["Parent":"error"]
        wcSession.sendMessage(message, replyHandler: { replyDict in }, errorHandler: { error in })
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }


}

