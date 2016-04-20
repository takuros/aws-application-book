//
//  AttendanceListViewController.swift
//  AttendanceManagementApp
//

import UIKit

/// 出社状況一覧画面のViewControllerです。
class AttendanceListViewController : UIViewController {

    /// 出社状況一覧を表示するTextView
    @IBOutlet weak var attendanceListTextView: UITextView!

    /// ビューが表示された後に呼ばれるメソッドです。
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // 出社状況一覧を取得して表示する
        self.showAttendances()
    }

    /// 出社登録ボタンが押されたときの処理
    @IBAction func onTouchUpSetAttendanceButton(sender: UIButton) {
        // 出社登録する
        self.setAttendance()
    }

    /// ログアウトボタンが押されたときの処理
    @IBAction func onTouchUpLogoutButton(sender: UIButton) {
        // ログアウトする
        self.logout()
    }

    /// 更新ボタンが押されたときの処理
    @IBAction func onTouchUpRefreshButton(sender: UIButton) {
        // 出社状況一覧を取得して表示する
        self.showAttendances()
    }

    /// 出社状況一覧を取得して表示します。
    private func showAttendances() {
        self.attendanceListTextView.text = "出社状況一覧取得中..."

        // 出社状況一覧取得
        let client = ATTENDANCEAPIAttendanceAPIClient.defaultClient()
        client.getAttendancesGet().continueWithExecutor(
            AWSExecutor.mainThreadExecutor(),
            withBlock: { (task: AWSTask!) -> AnyObject! in
                if let response = task.result as? ATTENDANCEAPIGetAttendancesResult,
                    let items = response.items as? [ATTENDANCEAPIGetAttendancesResult_items_item]
                {
                    print("出社状況一覧取得成功")

                    // 出社状況一覧の表示を更新
                    var text: String = ""
                    items.forEach { (item) in
                        text += "\(item.userName) : \(0 == item.attendance ? "未登録" : "出社済")\n"
                    }
                    self.attendanceListTextView.text = text
                } else {
                    print("出社状況一覧取得失敗 - \(task.error?.description)")

                    self.attendanceListTextView.text = "出社状況一覧取得失敗"
                }
                return nil
            }
        )
    }

    /// 出社登録します。登録に成功したら出社状況一覧を更新します。
    private func setAttendance() {
        self.attendanceListTextView.text = "出社登録中..."

        // 出社登録のリクエスト設定
        let request = ATTENDANCEAPISetAttendanceRequest()
        request.userId = UserDataStore.getUserData(NSUserDefaults.standardUserDefaults()).userId

        // 出社登録
        let client = ATTENDANCEAPIAttendanceAPIClient.defaultClient()
        client.setAttendancePost(request).continueWithExecutor(
            AWSExecutor.mainThreadExecutor(),
            withBlock: { (task: AWSTask!) -> AnyObject! in
                if nil == task.error {
                    print("出社登録成功")

                    // 出社状況一覧の更新
                    self.showAttendances()
                } else {
                    print("出社登録失敗 - \(task.error?.description)")

                    self.attendanceListTextView.text = "出社登録失敗"
                }
                return nil
            }
        )
    }

    /// ログアウトします。
    private func logout() {
        // 保存しているパスワードを破棄して前の画面に戻る
        UserDataStore.clearPassword(NSUserDefaults.standardUserDefaults())
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
