//
//  ViewController.swift
//  awstest
//
//  Created by s-takayanagi2 on 2/20/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController,FBSDKLoginButtonDelegate {

    @IBOutlet weak var syncDataText: UITextField!
    @IBOutlet weak var getDataText: UILabel!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewController viewDidLoad")
        // データをCognitoSyncから取得する
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("myDataset")
        self.getDataText.text = dataset.stringForKey("myKey")
        
        // 認証ユーザになるためのFacebookログインボタン
        self.loginButton.center = self.view.center
        self.loginButton.delegate = self
        self.view.addSubview(self.loginButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Push Sync用のNotification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:#selector(ViewController.refreshText(_:)),
            name:"refreshText",
            object:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: "refreshText",
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // AWS Syncにデータを同期
    @IBAction func syncData(sender: AnyObject) {
        self.view .endEditing(true)
        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.defaultCognito()
        
        // Create a record in a dataset and synchronize with the server
        let dataset = syncClient.openOrCreateDataset("myDataset")
        dataset.setString(self.syncDataText.text, forKey:"myKey")
        dataset.synchronize().continueWithBlock {(task: AWSTask!) -> AnyObject! in
            // Your handler code here
            print(task)
            dispatch_async(dispatch_get_main_queue()) {
                if (task.error != nil) {
                    self.showAlert("データ追加失敗", body: "Error : \(task.error?.localizedDescription)")
                }else{
                    self.showAlert("データ追加完了", body: "Success")
                }
            }
            return nil
        }
    }
    
    // AWS Syncからデータを取得
    @IBAction func getData(sender: AnyObject) {
        // Labelを読込中に変更
        self.getDataText.text = "読込中"

        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.defaultCognito()
        
        // Create a record in a dataset and synchronize with the server
        let dataset = syncClient.openOrCreateDataset("myDataset")
        
        [dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
            dispatch_async(dispatch_get_main_queue()) {
                if task.cancelled {
                    // Task cancelled.
                    self.getDataText.text = "キャンセル"
                } else if task.error != nil {
                    // Error while executing task
                    self.getDataText.text = "エラー"
                } else {
                    // Task succeeded. The data was saved in the sync store.
                    self.getDataText.text = dataset.stringForKey("myKey")
                }
            }
            return nil
            }];
    }
    
    // Push syncでmyDatasetを購読する処理
    @IBAction func setPushSync(sender: AnyObject) {
        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.defaultCognito()
        
        // Enable Push Sync
        syncClient.openOrCreateDataset("myDataset").subscribe().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Unable to subscribe to dataset: " + task.error!.localizedDescription)
                self.showAlert("Push設定失敗", body: "Unable to subscribe to dataset: " + task.error!.localizedDescription)
            } else {
                print("Successfully subscribed to dataset: \(task.result)")
                self.showAlert("Push設定完了", body: "Successfully subscribed to dataset: \(task.result)")
            }
            return nil
        }
    }
    
    // 認証ユーザになるためのFacebookログインボタンのハンドラー
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (nil == error && false == result.isCancelled) {
            // ログイン成功時の処理
            LoginManager.sharedInstance.refreshCognito()
        }
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
    
    
    // アラートを表示する
    private func showAlert (title:String, body:String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: title, message: body, preferredStyle: .ActionSheet)
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                print("alert ok")
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Push syncでGetDataの下にあるLabelを更新する
    func refreshText(notification: NSNotification?){
        // Initialize the Cognito Sync client
        let syncClient = AWSCognito.defaultCognito()
        
        // Create a record in a dataset and synchronize with the server
        let dataset = syncClient.openOrCreateDataset("myDataset")
        
        // Set text
        dispatch_async(dispatch_get_main_queue()) {
            self.getDataText.text = dataset.stringForKey("myKey")
        }
    }
}

