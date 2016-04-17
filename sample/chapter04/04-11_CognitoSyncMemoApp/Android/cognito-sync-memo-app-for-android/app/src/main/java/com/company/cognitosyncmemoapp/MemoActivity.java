package com.company.cognitosyncmemoapp;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

import com.amazonaws.auth.CognitoCachingCredentialsProvider;
import com.amazonaws.mobileconnectors.cognito.CognitoSyncManager;
import com.amazonaws.mobileconnectors.cognito.Dataset;
import com.amazonaws.mobileconnectors.cognito.DefaultSyncCallback;
import com.amazonaws.mobileconnectors.cognito.Record;
import com.amazonaws.regions.Regions;
import com.facebook.AccessToken;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginManager;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MemoActivity extends AppCompatActivity {

    private static final Regions REGION_TYPE = Regions.AP_NORTHEAST_1;
    private static final String IDENTITY_POOL_ID = "＜Identity Pool ID＞";
    private static final String DATASET_NAME = "my-dataset";
    private static final String MEMO_KEY = "memo";

    private CognitoCachingCredentialsProvider credentialsProvider;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_memo);

        final AccessToken token = AccessToken.getCurrentAccessToken(); // Facebookのアクセストークンを取得する。
        if (null != token) {
            // Facebookのユーザー情報を取得する処理。
            GraphRequest request = GraphRequest.newMeRequest(
                    token,
                    new GraphRequest.GraphJSONObjectCallback() {
                        @Override
                        public void onCompleted(JSONObject object, GraphResponse response) {
                            // CognitoによるFacebook認証処理。
                            credentialsProvider = new CognitoCachingCredentialsProvider(
                                    getApplicationContext(),
                                    IDENTITY_POOL_ID,
                                    REGION_TYPE
                            );

                            Map<String, String> logins = new HashMap<>();
                            logins.put("graph.facebook.com", token.getToken());
                            credentialsProvider.setLogins(logins);

                            final Handler handler = new Handler();
                            (new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    String identityId = credentialsProvider.getIdentityId();
                                    System.out.println("Cognito identity id:" + identityId);

                                    // メモの取得
                                    CognitoSyncManager syncClient = new CognitoSyncManager(
                                            getApplicationContext(),
                                            Regions.AP_NORTHEAST_1,
                                            credentialsProvider
                                    );
                                    Dataset dataset = syncClient.openOrCreateDataset(DATASET_NAME);
                                    dataset.synchronize(new DefaultSyncCallback() {
                                        @Override
                                        public void onSuccess(Dataset dataset, List<Record> updatedRecords) {
                                            final String memo = dataset.get(MEMO_KEY);
                                            if (null != memo) {
                                                handler.post(new Runnable() {
                                                    @Override
                                                    public void run() {
                                                        final EditText editText = (EditText) findViewById(R.id.editText);
                                                        editText.setText(memo);
                                                    }
                                                });
                                            }
                                        }
                                    });
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

        // 入力エリア
        final EditText editText = (EditText) findViewById(R.id.editText);

        // 閉じるボタン
        final Button closeButton = (Button) findViewById(R.id.button_close);
        closeButton.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.hideSoftInputFromWindow(v.getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);

                    // メモの保存
                    CognitoSyncManager syncClient = new CognitoSyncManager(
                            getApplicationContext(),
                            Regions.AP_NORTHEAST_1,
                            credentialsProvider
                    );
                    Dataset dataset = syncClient.openOrCreateDataset(DATASET_NAME);
                    dataset.put(MEMO_KEY, editText.getText().toString());
                    dataset.synchronize(new DefaultSyncCallback() {
                        @Override
                        public void onSuccess(Dataset dataset, List<Record> updatedRecords) {
                            super.onSuccess(dataset, updatedRecords);
                            System.out.println("synced!(put)");
                        }
                    });
                }
            }
        });
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 閉じるボタンが押されたときの処理。
                LoginManager.getInstance().logOut();
                finish();
            }
        });
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (KeyEvent.ACTION_DOWN == event.getAction() && KeyEvent.KEYCODE_BACK == event.getKeyCode()) {
            return true;
        }
        return super.dispatchKeyEvent(event);
    }
}
