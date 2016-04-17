//
//  MainViewController.swift
//  CognitoSyncMemoApp
//

import UIKit

import AWSCore
import AWSCognito

import FBSDKCoreKit
import FBSDKLoginKit


class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    let REGION_TYPE = AWSRegionType.APNortheast1
    let IDENTITY_POOL_ID = "ap-northeast-1:01234567-0123-0123-0123-0123456789ab"
    let DATASET_NAME = "my-dataset"
    let MEMO_KEY = "memo"

    var myName: String? = nil
    var initialBottomConstraintConstant: CGFloat? = nil

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        let token = FBSDKAccessToken.currentAccessToken()  // Facebookのアクセストークンを取得する。
        if (nil != token) {
            FBSDKGraphRequest(
                graphPath: "me",
                parameters: ["fields": "name"]
                ).startWithCompletionHandler({ (connection, result, error) -> Void in
                    if (nil == error) {
                        self.myName = result.valueForKey("name") as? String
                        print("myName:", self.myName)

                        // CognitoによるFacebook認証処理。
                        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: self.REGION_TYPE, identityPoolId: self.IDENTITY_POOL_ID)
                        let configuration = AWSServiceConfiguration(region: self.REGION_TYPE, credentialsProvider: credentialsProvider)
                        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

                        credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token.tokenString]

                        // 認証できているかどうかの確認。
                        credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                            if (nil == task.error) {
                                // メモの取得と表示
                                let syncClient = AWSCognito.defaultCognito()
                                let dataset = syncClient.openOrCreateDataset(self.DATASET_NAME)
                                dataset.synchronize().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                                    let text: String! = dataset.stringForKey(self.MEMO_KEY)  // メモを取り出す
                                    if nil != text {
                                        NSOperationQueue.mainQueue().addOperationWithBlock {
                                            self.textView.text = text
                                            print("synced. - \(text)")
                                        }
                                    }
                                    return nil
                                }
                            } else {
                                print("Error:", task.error?.localizedDescription)
                                // 前の画面に戻る。
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                            return nil
                        }
                    } else {
                        print("Error:", error.localizedDescription)
                        // 前の画面に戻る。
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
        } else {
            // トークンが取得できなかった場合は前の画面に戻る。
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // 画面下部のマージンを取得する
        if nil == self.initialBottomConstraintConstant {
            self.initialBottomConstraintConstant = self.bottomConstraint.constant
        }

        // ソフトウェアキーボードの開閉状態の監視を開始する
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // ソフトウェアキーボードの開閉状態の監視をやめる
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self, name: "keyboardWillShow:", object: nil)
        nc.removeObserver(self, name: "keyboardWillHide:", object: nil)
    }

    /// ソフトウェアキーボードが開くときに呼ばれるメソッドです
    func keyboardWillShow(notification: NSNotification) {
        if let height: CGFloat = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height,
               initialConst = self.initialBottomConstraintConstant
        {
            // キーボードの高さに合わせてサイズを変更する
            self.bottomConstraint.constant = initialConst + height
            self.view.layoutIfNeeded()
        }
    }

    /// ソフトウェアキーボードが閉じるときに呼ばれるメソッドです
    func keyboardWillHide(notification: NSNotification) {
        if let initialConst = self.initialBottomConstraintConstant {
            // サイズを元に戻す
            self.bottomConstraint.constant = initialConst
            self.view.layoutIfNeeded()
        }
    }

    // 「閉じる」ボタンが押されたときに呼ばれるメソッドです
    @IBAction func touchCloseButton(sender: UIButton) {
        // 入力中の場合は入力を終了してメモを保存する。
        // そうでない場合はログアウトして前の画面に戻る。
        if self.textView.isFirstResponder() {
            self.textView.resignFirstResponder()

            // メモの保存
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset(self.DATASET_NAME)
            dataset.setString(self.textView.text, forKey: self.MEMO_KEY)
            dataset.synchronize().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                print("synced.")
                return nil
            }
        } else {
            FBSDKLoginManager().logOut()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
