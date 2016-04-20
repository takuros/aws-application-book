//
//  ViewController.swift
//  PictureSharingApp
//

import UIKit

import AWSCore
import AWSCognito
import AWSS3
import AWSSNS

import FBSDKCoreKit
import FBSDKLoginKit

/// ログイン画面のViewControllerです。
class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    /// ビューの読み込みが完了したときに呼ばれるメソッドです。
    override func viewDidLoad() {
        super.viewDidLoad()

        // 画面にFacebookログインボタンを設置する。
        let loginButton: FBSDKLoginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
    }

    /// ビューが表示された後に呼ばれるメソッドです。
    override func viewDidAppear(animated: Bool) {
        // すでにFacebookにログイン済みの場合はメイン画面に遷移する。
        if (nil != FBSDKAccessToken.currentAccessToken()) {
            self.performSegueWithIdentifier("showMainViewController", sender: self)
        }
    }

    /// Facebookログインボタンが押されたときに呼ばれるメソッドです。
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (nil == error && false == result.isCancelled) {
            // ログイン成功時の処理
            self.performSegueWithIdentifier("showMainViewController", sender: self)
        }
    }

    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }

}

