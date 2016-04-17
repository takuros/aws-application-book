package com.company.picturesharingapp;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;

import com.amazonaws.auth.CognitoCachingCredentialsProvider;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferListener;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferObserver;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferState;
import com.amazonaws.mobileconnectors.s3.transferutility.TransferUtility;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.sns.AmazonSNSClient;
import com.amazonaws.services.sns.model.CreatePlatformEndpointRequest;
import com.amazonaws.services.sns.model.CreatePlatformEndpointResult;
import com.amazonaws.services.sns.model.PublishRequest;
import com.amazonaws.services.sns.model.PublishResult;
import com.amazonaws.services.sns.model.SubscribeRequest;
import com.amazonaws.services.sns.model.SubscribeResult;
import com.facebook.AccessToken;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginManager;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class SharingActivity extends AppCompatActivity {

    private static final Regions REGION_TYPE = Regions.AP_NORTHEAST_1;
    private static final String IDENTITY_POOL_ID = "＜Identity Pool ID＞";
    private static final String PROJECT_NUMBER = "＜Project Number＞";
    private static final String PLATFORM_APPLICATION_ARN = "＜Platform Application ARN＞";
    private static final String TOPIC_ARN = "＜Topic ARN＞";
    private static final String BUCKET_NAME = "＜Bucket Name＞";

    private static final int RESULT_CODE_CAPTURE = 123;

    private String myName;

    private CognitoCachingCredentialsProvider credentialsProvider;

    private AmazonSNSClient snsClient;

    private String receivedMessage;

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        receivedMessage = intent.getStringExtra("message");

        System.out.println("onNewIntent()! @SharingActivity");
        System.out.println("message:" + receivedMessage);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_sharing);

        final AccessToken token = AccessToken.getCurrentAccessToken(); // Facebookのアクセストークンを取得する。
        if (null != token) {
            // Facebookのユーザー情報を取得する処理。
            GraphRequest request = GraphRequest.newMeRequest(
                    token,
                    new GraphRequest.GraphJSONObjectCallback() {
                        @Override
                        public void onCompleted(JSONObject object, GraphResponse response) {
                            try {
                                myName = object.getString("name");
                            } catch (JSONException e) {
                                LoginManager.getInstance().logOut();
                                finish();
                                return;
                            }
                            System.out.println("myName: " + myName);

                            // CognitoによるFacebook認証処理。
                            credentialsProvider = new CognitoCachingCredentialsProvider(
                                    getApplicationContext(),
                                    IDENTITY_POOL_ID,
                                    REGION_TYPE
                            );

                            Map<String, String> logins = new HashMap<>();
                            logins.put("graph.facebook.com", token.getToken());
                            credentialsProvider.setLogins(logins);

                            // 認証できているかどうかの確認。
                            (new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    String identityId = credentialsProvider.getIdentityId();
                                    System.out.println("Cognito identity id:" + identityId);

                                    // レジストレーションIDの取得
                                    InstanceID instanceID = InstanceID.getInstance(getApplicationContext());
                                    String regId = null;
                                    try {
                                        regId = instanceID.getToken(PROJECT_NUMBER, GoogleCloudMessaging.INSTANCE_ID_SCOPE);
                                    } catch (Exception e) {
                                        System.out.println("トークン取得失敗。");
                                        System.out.println(e.getLocalizedMessage());
                                    }
                                    if (null != regId) {
                                        System.out.println("regId: " + regId);

                                        // エンドポイントの登録
                                        snsClient = new AmazonSNSClient(credentialsProvider.getCredentials());
                                        snsClient.setRegion(Region.getRegion(REGION_TYPE));
                                        CreatePlatformEndpointRequest endpointRequest = new CreatePlatformEndpointRequest();
                                        endpointRequest.setToken(regId);
                                        endpointRequest.setPlatformApplicationArn(PLATFORM_APPLICATION_ARN);
                                        CreatePlatformEndpointResult endpointResult = snsClient.createPlatformEndpoint(endpointRequest);

                                        // トピックの購読
                                        if (null != endpointResult.getEndpointArn()) {
                                            System.out.println("エンドポイント登録成功。");
                                            SubscribeRequest subscribeRequest = new SubscribeRequest();
                                            subscribeRequest.setTopicArn(TOPIC_ARN);
                                            subscribeRequest.setEndpoint(endpointResult.getEndpointArn());
                                            subscribeRequest.setProtocol("Application");
                                            SubscribeResult subscribeResult = snsClient.subscribe(subscribeRequest);
                                            if (null != subscribeResult.getSubscriptionArn()) {
                                                System.out.println("トピック購読成功。");
                                            }
                                        }
                                    }
                                }
                            })).start();
                        }
                    }
            );
            Bundle parameters = new Bundle();
            parameters.putString("fields", "id, name");
            request.setParameters(parameters);
            request.executeAsync(); // リクエスト開始。
        } else {
            // トークンが取得できなかった場合は前の画面に戻る。
            finish();
        }

        // 閉じるボタン
        final Button closeButton = (Button) findViewById(R.id.button_close);
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 閉じるボタンが押されたときの処理。
                LoginManager.getInstance().logOut();
                finish();
            }
        });

        // 写真共有ボタン
        final Button shareButton = (Button) findViewById(R.id.button_sharing);
        shareButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 写真共有ボタンが押されたときの処理。
                if (null != credentialsProvider) {
                    // 撮影設定とアクティビティの開始
                    File outputFile = new File(getExternalCacheDir(), "tmp.jpg"); // 写真の保存先
                    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                    intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(outputFile));
                    startActivityForResult(intent, RESULT_CODE_CAPTURE);
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (null != receivedMessage) {
            // 画像表示
            String[] splittedMessage = receivedMessage.split("\\(");
            String last = splittedMessage[splittedMessage.length - 1];
            String filename = last.substring(0, last.length() - 1);
            System.out.println("ダウンロードするファイル名:" + filename);

            File imageFile = new File(getExternalCacheDir(), "tmp.jpg"); // 写真の保存先
            TransferUtility transferUtility = new TransferUtility(new AmazonS3Client(credentialsProvider), getApplicationContext());
            TransferObserver observer = transferUtility.download(
                    BUCKET_NAME,
                    filename,
                    imageFile
            );

            // ダウンロード実行
            observer.setTransferListener(new TransferListener() {
                @Override
                public void onStateChanged(int id, TransferState state) {
                    if (TransferState.COMPLETED == state) {
                        // ダウンロードに成功したときの処理。
                        System.out.println("ダウンロード成功");

                        // 写真を表示するアクティビティを起動する。
                        goToImageViewActivity();
                    }
                }

                @Override
                public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                    // ダウンロードの進捗状況が変化したときの処理。
                }

                @Override
                public void onError(int id, Exception ex) {
                    // ダウンロード中にエラーが発生したときの処理。
                    System.out.println("ダウンロードエラー: " + ex.getLocalizedMessage());
                }
            });
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // 撮影完了
        if (RESULT_CODE_CAPTURE == requestCode && Activity.RESULT_OK == resultCode) {
            if (null != credentialsProvider) {

                // アップロード設定
                File imageFile = new File(getExternalCacheDir(), "tmp.jpg"); // 写真の保存先
                final String uploadFileName = UUID.randomUUID().toString() + ".jpg"; // S3上でのファイル名
                TransferUtility transferUtility = new TransferUtility(new AmazonS3Client(credentialsProvider), getApplicationContext());
                TransferObserver observer = transferUtility.upload(
                        BUCKET_NAME,
                        uploadFileName,
                        imageFile
                );

                // アップロード実行
                observer.setTransferListener(new TransferListener() {
                    @Override
                    public void onStateChanged(int id, TransferState state) {
                        if (TransferState.COMPLETED == state) {
                            // アップロードに成功したときの処理。
                            System.out.println("アップロード成功");

                            // プッシュ通知を送る処理。
                            (new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    PublishRequest publishRequest = new PublishRequest();
                                    publishRequest.setTopicArn(TOPIC_ARN);
                                    publishRequest.setMessage(myName + "さんが写真をアップロードしました(" + uploadFileName + ")");
                                    PublishResult publishResult = snsClient.publish(publishRequest);
                                    if (null != publishResult.getMessageId()) {
                                        System.out.println("プッシュ通知送信完了。");
                                    }
                                }
                            })).start();
                        }
                    }

                    @Override
                    public void onProgressChanged(int id, long bytesCurrent, long bytesTotal) {
                        // アップロードの進捗が変わったときの処理。
                    }

                    @Override
                    public void onError(int id, Exception ex) {
                        // アップロード中にエラーが発生したときの処理。
                        System.out.println("アップロードエラー: " + ex.getLocalizedMessage());
                    }
                });
            }
        }
    }

    private void goToImageViewActivity() {
        receivedMessage = null;

        Intent intent = new Intent(this, ImageViewActivity.class);
        startActivity(intent);
    }
}
