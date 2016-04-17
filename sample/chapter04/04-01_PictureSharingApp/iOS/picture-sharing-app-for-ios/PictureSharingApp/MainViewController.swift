//
//  MainViewController.swift
//  PictureSharingApp
//

import UIKit

import AWSCore
import AWSCognito
import AWSS3
import AWSSNS

import FBSDKCoreKit
import FBSDKLoginKit


class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let REGION_TYPE = AWSRegionType.APNortheast1
    let IDENTITY_POOL_ID = "＜Identity Pool ID＞"
    let PLATFORM_APPLICATION_ARN = "＜Platform Application ARN＞"
    let TOPIC_ARN = "＜トピックのARN＞"
    let BUCKET_NAME = "＜バケット名＞"

    var myName: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let token = FBSDKAccessToken.currentAccessToken()  // Facebookのアクセストークンを取得する。
        if (nil != token) {
            // Facebookのユーザー情報を取得する処理。
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
                                print("Cognito identity id:", task.result)

                                // SNS設定
                                if let deviceToken = (UIApplication.sharedApplication().delegate as? AppDelegate)?.deviceToken {
                                    let sns = AWSSNS.defaultSNS()

                                    // エンドポイントの登録
                                    let request = AWSSNSCreatePlatformEndpointInput()
                                    request.token = deviceToken
                                    request.platformApplicationArn = self.PLATFORM_APPLICATION_ARN
                                    sns.createPlatformEndpoint(request).continueWithBlock { (task: AWSTask!) -> AnyObject! in
                                        print("エンドポイント登録成功。")
                                        if let endpointArn = (task.result as? AWSSNSCreateEndpointResponse)?.endpointArn
                                           where nil == task.error
                                        {
                                            // トピックへの登録
                                            let request = AWSSNSSubscribeInput()
                                            request.topicArn = self.TOPIC_ARN
                                            request.endpoint = endpointArn
                                            request.protocols = "Application"
                                            sns.subscribe(request).continueWithBlock { (task: AWSTask!) -> AnyObject! in
                                                print("トピック登録成功。")
                                                return nil
                                            }
                                        }

                                        return nil
                                    }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "push:", name: "message", object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func push(notification: NSNotification) {
        if let message = notification.userInfo?["aps"]?["alert"] as? String {
            let splittedMessage = message.componentsSeparatedByString("(")
            let last = splittedMessage[splittedMessage.count - 1]
            let filename = last.substringToIndex(last.endIndex.advancedBy(-1))
            print("filename: \(filename)")

            // ダウンロードする
            let downloadRequest = AWSS3TransferManagerDownloadRequest()
            downloadRequest.bucket = self.BUCKET_NAME
            downloadRequest.key = filename
            downloadRequest.downloadingFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("tmp.jpg")
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            transferManager.download(downloadRequest).continueWithBlock({ (task: AWSTask) -> AnyObject! in
                if nil == task.error {
                    print("ダウンロード成功。")
                    self.performSegueWithIdentifier("showImageViewController", sender: self)
                } else {
                    print("ダウンロード失敗。\(task.error?.description)")
                }
                return nil
            })
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let targetDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first
        {
            // 撮影した画像を保存してS3上にアップロードする。
            let path = targetDir.stringByAppendingString("/tmp.jpg")
            if let imageData = UIImageJPEGRepresentation(image, 0.8) {
                if imageData.writeToFile(path, atomically: true) {
                    // アップロード設定
                    let uploadFileName = NSUUID().UUIDString.stringByAppendingString(".jpg") // S3上でのファイル名
                    let uploadRequest = AWSS3TransferManagerUploadRequest()
                    uploadRequest.bucket = self.BUCKET_NAME
                    uploadRequest.key = uploadFileName
                    uploadRequest.body = NSURL(fileURLWithPath: path)

                    // アップロード実行
                    let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                    transferManager.upload(uploadRequest).continueWithExecutor(
                        AWSExecutor.mainThreadExecutor(),
                        withBlock: { (task: AWSTask) -> AnyObject! in
                            if let result = task.result {
                                // アップロードに成功したときの処理。
                                print("アップロード成功:", result)

                                // プッシュ通知を送る処理。
                                let sns = AWSSNS.defaultSNS()
                                let request = AWSSNSPublishInput()
                                request.topicArn = self.TOPIC_ARN
                                request.message = "\(self.myName!)さんが写真をアップロードしました(\(uploadFileName))"
                                sns.publish(request).continueWithBlock({ (task: AWSTask!) -> AnyObject! in
                                    if nil == task.error {
                                        print("プッシュ通知送信完了。")
                                    }
                                    return nil
                                })
                            }

                            if let error = task.error {
                                // アップロード中にエラーが発生したときの処理。
                                print("アップロードエラー:", error)
                            }

                            return nil
                        }
                    )
                }
            }

            // カメラ撮影画面を閉じる
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func touchSharingButton(sender: UIButton) {
        // 「写真を共有する」ボタンが押されたときの処理
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func touchCloseButton(sender: UIButton) {
        // 「閉じる」ボタンが押されたときの処理
        FBSDKLoginManager().logOut()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
