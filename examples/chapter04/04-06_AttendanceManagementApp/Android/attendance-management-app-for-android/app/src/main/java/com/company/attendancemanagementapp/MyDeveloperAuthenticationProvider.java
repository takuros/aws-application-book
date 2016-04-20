package com.company.attendancemanagementapp;

import android.util.Log;

import com.amazonaws.auth.AWSAbstractCognitoDeveloperIdentityProvider;
import com.amazonaws.auth.CognitoCredentialsProvider;
import com.amazonaws.mobileconnectors.apigateway.ApiClientFactory;
import com.amazonaws.regions.Regions;

import java.util.HashMap;

import com.company.attendancemanagementapp.model.GetTokenAndIdentityIdResult;

/**
 * 独自認証のプロバイダークラスです。
 */
public class MyDeveloperAuthenticationProvider extends AWSAbstractCognitoDeveloperIdentityProvider {

    private static final String CLASS_NAME = MyDeveloperAuthenticationProvider.class.getSimpleName();

    /** 開発者のユーザーアカウント */
    private static final String DEVELOPER_ACCOUNT_ID = "＜アカウント名＞";
    /** CognitoのDeveloper provider name */
    private static final String PROVIDER_NAME = "＜CognitoのDeveloper provider name＞";
    /** CognitoのIdentity pool id */
    private static final String IDENTITY_POOL_ID = "＜Identity Pool ID＞";
    /** Cognitoのリージョン */
    private static final Regions REGION = Regions.AP_NORTHEAST_1;
    /** 未認証時のCognitoのロールARN */
    private static final String ARN_UNAUTH_ROLE = "＜未認証時のロールARN＞";
    /** 認証後のCognitoのロールARN */
    private static final String ARN_AUTH_ROLE = "＜認証後のロールARN＞";

    /** ユーザーID */
    private String userId;
    /** パスワード */
    private String password;

    /**
     * コンストラクタ
     */
    public MyDeveloperAuthenticationProvider(String userId, String password) {
        super(DEVELOPER_ACCOUNT_ID, IDENTITY_POOL_ID, REGION);

        // フィールドの初期化
        this.userId = userId;
        this.password = password;
    }

    /**
     * Developer provider nameを取得します。
     */
    @Override
    public String getProviderName() {
        return PROVIDER_NAME;
    }

    /**
     * ユーザーのIdentity idとトークンを更新します。
     */
    @Override
    public String refresh() {
        // 現在のトークンを削除
        setToken(null);

        // トークンの取得
        GetTokenAndIdentityIdResult result = getTokenAndIdentityId();

        // Identity idとトークンの更新
        update(result.getIdentityId(), result.getToken());

        return token;
    }

    /**
     * ユーザーのIdentity idを取得します。
     */
    @Override
    public String getIdentityId() {
        if (null == identityId) {
            // Identity idを取得して設定する
            identityId = getTokenAndIdentityId().getIdentityId();

            return identityId;
        }
        return identityId;
    }

    /**
     * ユーザーのIdentity idとトークンを取得します。
     */
    private GetTokenAndIdentityIdResult getTokenAndIdentityId() {
        // 匿名ユーザーとしてAPI Gatewayにアクセスするための設定
        CognitoCredentialsProvider credentialsProvider = new CognitoCredentialsProvider(
                IDENTITY_POOL_ID,
                Regions.AP_NORTHEAST_1
        );
        ApiClientFactory factory = (new ApiClientFactory()).credentialsProvider(credentialsProvider);
        AttendanceAPIClient client = factory.build(AttendanceAPIClient.class);

        // ユーザーIDに紐付くIdentity idとトークンを取得して返却する
        return client.getTokenAndIdentityIdGet(userId, password);
    }

    /**
     * CognitoCredentialsProviderのインスタンスを取得します。
     */
    public static CognitoCredentialsProvider getCredentialsProvider(MyDeveloperAuthenticationProvider authenticationProvider) {
        // CredentialsProviderの生成
        CognitoCredentialsProvider credentialsProvider = new CognitoCredentialsProvider(
                authenticationProvider,
                ARN_UNAUTH_ROLE,
                ARN_AUTH_ROLE
        );

        // ログインマップの更新
        HashMap<String, String> loginsMap = new HashMap<>();
        loginsMap.put(authenticationProvider.getProviderName(), authenticationProvider.getAccountId());
        authenticationProvider.setLogins(loginsMap);
        authenticationProvider.refresh();

        // 認証成功したらCognitoCredentialsProviderを返す
        try {
            credentialsProvider.getCredentials();
            Log.d(CLASS_NAME, "認証成功");
            return credentialsProvider;
        } catch (Exception e) {
            Log.d(CLASS_NAME, "認証失敗 - " + e.getLocalizedMessage());
            return null;
        }
    }

}