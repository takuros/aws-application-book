//
//  InterfaceController.swift
//  applewatch Extension
//
//  Created by s-takayanagi2 on 2/29/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    let wcSession = WCSession.defaultSession()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // WCSessionの開始
        if WCSession.isSupported() {
            wcSession.delegate = self
            wcSession.activateSession()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // ボタンを押された時の動作
    @IBAction func sendHeartrate() {
        self.getHealthData()
    }
    
    // 端末がHealthKitに対応しているか・権限があるか確認する
    private func getHealthData(){
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("healthKitが有効ではありません");
            return
        }
        
        let heartRateType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let healthStore: HKHealthStore = HKHealthStore()
        
        let dataTypes = Set([heartRateType])
        
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -> Void in
            if success{
                print("有効です")
                self.getHealth()
            }else {
                print("Permissionが有効ではありません")
                return
            }
        }
    }
    
    // 心拍数を取得する
    private func getHealth(){
        let healthStore: HKHealthStore = HKHealthStore()
        let heartRateUnit = HKUnit(fromString: "count/min")
        
        // 現時刻を取得
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute] , fromDate:  now)
        
        //取得終了時間に現時刻を設定
        let endDate = calendar.dateFromComponents(components)
        
        //取得開始時間を現在から1時間前に設定
        let startDate = calendar.dateByAddingUnit(.Hour, value: -1, toDate: endDate!, options: NSCalendarOptions(rawValue: 0))
        
        //心拍数データを設定
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
        
        // クエリを設定
        let query = HKSampleQuery(sampleType: sampleType!, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
            query, results, error in
            // 結果を取得
            // エラー
            if (results == nil) {
                print("エラーが発生しました。");
                print(error?.localizedDescription)
                abort();
            }
            
            // HKQuantitySample
            let sample = results as! [HKQuantitySample]
            
            // 心拍数(直近一件)
            let value = sample.first!.quantity.doubleValueForUnit(heartRateUnit)
            let heartRate = String(UInt16(value))
            print(heartRate)
            
            // 心拍数を取得した端末名(直近一件)
            let name = sample.first!.sourceRevision.source.name
            print(name)
            
            
            // 取得した時間(直近一件)
            let date = sample.first!.endDate
            // 午前午後対策
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            
            
            // Stringで日本時間に合わせて出力
            let dateString:String = formatter.stringFromDate(date)
            print(dateString)
            
            dispatch_async(dispatch_get_main_queue()) {
                // データをまとめる
                let data = ["heartRate":heartRate , "name":name , "date":dateString]
                // iOSにデータを通知する
                // reachableの確認
                if self.wcSession.reachable {
                    print("reachable")
                    self.wcSession.sendMessage(data, replyHandler: { replyDict in }, errorHandler: { error in })
                }
                else{
                    print("not reachable")
                }
            }
        }
        healthStore.executeQuery(query)
    }
 
    // iOSから通知を受信します
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        
        // iOSからのデータを受け取る
        print("didReceiveMessage")
        if let parentMessage = message["Parent"] as? String {
            if (parentMessage=="success"){
                showAlertControllerWithStyle("送信しました",style: WKAlertControllerStyle.Alert)
            }else{
                showAlertControllerWithStyle("送信に失敗しました",style: WKAlertControllerStyle.Alert)
            }
            print(parentMessage)
        }
    }
    
    // AppleWatchでアラートを表示します
    private func showAlertControllerWithStyle(message:String ,style: WKAlertControllerStyle!) {
        let defaultAction = WKAlertAction(
            title: "OK",
            style: WKAlertActionStyle.Default) { () -> Void in
                print("OK")
        }
        let actions = [defaultAction]
        presentAlertControllerWithTitle(
            "連絡！",
            message: message,
            preferredStyle: style,
            actions: actions)
    }
}
