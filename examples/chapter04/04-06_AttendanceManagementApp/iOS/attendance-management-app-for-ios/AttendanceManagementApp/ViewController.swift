//
//  ViewController.swift
//  AttendanceManagementApp
//

import UIKit

/// ログイン画面のViewControllerです。
class ViewController: UIViewController {

    /// ログインエラー表示
    @IBOutlet weak var loginErrorLabel: UILabel!
    /// ユーザーID入力エリア
    @IBOutlet weak var userIdTextField: UITextField!
    /// パスワード入力エリア
    @IBOutlet weak var passwordTextField: UITextField!

    /// ビューが表示された後に呼ばれるメソッドです。
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // ユーザーIDとパスワードを取得して表示する
        let userData = UserDataStore.getUserData(NSUserDefaults.standardUserDefaults())
        self.userIdTextField.text = userData.userId
        self.passwordTextField.text = userData.password

        // ユーザーIDとパスワードが保存されている場合はログインを試行して出社状況一覧画面へ遷移する
        if !userData.userId.isEmpty && !userData.password.isEmpty {
            self.login(userId: userData.userId, password: userData.password)
        }
    }

    /// ログインボタンが押されたときに呼ばれるメソッドです。
    @IBAction func onTouchUpLoginButton(sender: UIButton!) {
        // ログイン試行
        self.login(userId: self.userIdTextField.text, password: self.passwordTextField.text)
    }

    /// ログインを試行し、認証成功したら出社状況一覧画面に遷移します。
    private func login(userId userId: String?, password: String?) {
        if let userId: String = userId, let password: String = password
           where !userId.isEmpty && !password.isEmpty
        {
            // 認証の設定
            let identityProvider = MyDeveloperAuthenticatedIdentityProvider(
                userId: userId, password: password
            )
            let credentialsProvider = AWSCognitoCredentialsProvider(
                regionType: MyDeveloperAuthenticatedIdentityProvider.REGION,
                identityProvider: identityProvider,
                unauthRoleArn: MyDeveloperAuthenticatedIdentityProvider.ARN_UNAUTH_ROLE,
                authRoleArn: MyDeveloperAuthenticatedIdentityProvider.ARN_AUTH_ROLE
            )
            let configuration = AWSServiceConfiguration(
                region: MyDeveloperAuthenticatedIdentityProvider.REGION,
                credentialsProvider: credentialsProvider
            )
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

            // 認証処理
            credentialsProvider.clearKeychain()
            credentialsProvider.logins = [
                MyDeveloperAuthenticatedIdentityProvider.PROVIDER_NAME: MyDeveloperAuthenticatedIdentityProvider.DEVELOPER_ACCOUNT_ID
            ]
            credentialsProvider.refresh().continueWithExecutor(
                AWSExecutor.mainThreadExecutor(),
                withBlock: { (task: AWSTask!) -> AnyObject! in
                    if nil == task.error {
                        print("認証成功")

                        // ユーザーIDとパスワードを保存する
                        UserDataStore.setUserData(
                            NSUserDefaults.standardUserDefaults(),
                            userId: userId,
                            password: password
                        )

                        // ログインエラー表示を隠す
                        self.loginErrorLabel.hidden = true

                        // 出社状況一覧画面へ遷移
                        self.performSegueWithIdentifier("showAttendanceListViewController", sender: self)
                    } else {
                        print("認証失敗")

                        // ログインエラー表示
                        self.loginErrorLabel.hidden = false
                    }

                    return nil
                }
            )
        } else {
            // ログインエラー表示
            self.loginErrorLabel.hidden = false
        }
    }

}
