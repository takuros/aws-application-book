//
//  AppDelegate.swift
//  AttendanceManagementApp
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    // 検知するiBeaconの情報
    /// iBeaconに付けるユニークな識別子
    let BEACON_ID: String = "社内のビーコン"
    /// iBeaconのUUID
    let UUID: String = "01234567-89AB-CDEF-0123-456789ABCDEF"
    /// iBeaconのMajor
    let MAJOR: CLBeaconMajorValue = 10
    /// iBeaconのMinor
    let MINOR: CLBeaconMinorValue = 20

    /// CLLocationManagerインスタンス
    var clLocationManager: CLLocationManager?

    /// アプリケーション起動後に呼ばれるメソッドです。
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // LocationManagerの設定
        self.clLocationManager = CLLocationManager()
        self.clLocationManager?.delegate = self

        // 許可を得る
        self.clLocationManager?.requestAlwaysAuthorization()

        return true
    }

    /// LocationManagerへのアクセス許可状態が変化した時に呼ばれるメソッドです。
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 許可が得られたらiBeaconの受信設定をする
        if .AuthorizedAlways == status {
            let clBeaconRegion = CLBeaconRegion(
                proximityUUID: NSUUID(UUIDString: UUID)!,
                major: MAJOR,
                minor: MINOR,
                identifier: BEACON_ID
            )
            self.clLocationManager?.startMonitoringForRegion(clBeaconRegion)
        }
    }

    /// iBeaconのビーコン領域に入ったときに呼ばれるメソッドです。
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("iBeaconのビーコン領域に入りました（region: \(region.description)）")

        // 出社登録
        self.setAttendance()
    }

    /// iBeaconのビーコン領域から出たときに呼ばれるメソッドです。
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("iBeaconのビーコン領域から出ました（region: \(region.description)）")
    }

    /// 出社登録します。
    private func setAttendance() {
        // ログイン済みのユーザー情報が保存されているかどうかの確認
        let userData = UserDataStore.getUserData(NSUserDefaults.standardUserDefaults())
        if !userData.userId.isEmpty && !userData.password.isEmpty {
            // 出社登録のリクエスト設定
            let request = ATTENDANCEAPISetAttendanceRequest()
            request.userId = userData.userId

            // 出社登録
            let client = ATTENDANCEAPIAttendanceAPIClient.defaultClient()
            client.setAttendancePost(request).continueWithExecutor(
                AWSExecutor.mainThreadExecutor(),
                withBlock: { (task: AWSTask!) -> AnyObject! in
                    if nil == task.error {
                        print("iBeacon検知による出社登録成功")
                    } else {
                        print("iBeacon検知による出社登録失敗 - \(task.error?.description)")
                    }
                    return nil
                }
            )
        }
    }

}

