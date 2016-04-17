//
//  LoginManager.swift
//  awstest
//
//  Created by s-takayanagi2 on 3/28/16.
//  Copyright © 2016 s-takayanagi2. All rights reserved.
//

import Foundation
import FBSDKCoreKit

public class LoginManager {
    
    static let sharedInstance = LoginManager()
    
    private var mCredentialsProvider:AWSCognitoCredentialsProvider
    
    init() {
        // Cognito利用の初期設定を実施しておく
        mCredentialsProvider = AWSCognitoCredentialsProvider(regionType:.APNortheast1,
                                                                identityPoolId:Constants.CognitoPoolID.rawValue)
        
        // Facebookのアクセストークンを取得する。
        if let token = FBSDKAccessToken.currentAccessToken() {
            // tokenが存在している場合はFacebookログイン済みとしてcredentialsProviderのLoginsにtokenを設定する
            mCredentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token.tokenString]
        }
        
        let configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider:mCredentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        print("Cognito LoginManager初期化完了")
    }
    
    public func refreshCognito(){
        // Facebookのアクセストークンを取得する。
        if let token = FBSDKAccessToken.currentAccessToken() {
            // tokenが存在している場合はFacebookログイン済みとしてcredentialsProviderのLoginsにtokenを設定する
            mCredentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token.tokenString]
        }
        
        let configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider:mCredentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        mCredentialsProvider.refresh().continueWithBlock  { (task: AWSTask!) -> AnyObject? in
            if (task.error != nil) {
                print("認証refreshエラー: " + task.error!.localizedDescription)
            } else {
                print("認証refresh完了: \(task.result)")
            }
            return nil
            
        }
    }
}