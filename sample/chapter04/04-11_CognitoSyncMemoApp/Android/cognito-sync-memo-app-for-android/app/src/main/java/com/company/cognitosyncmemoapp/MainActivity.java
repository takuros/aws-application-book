package com.company.cognitosyncmemoapp;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.login.LoginResult;
import com.facebook.login.widget.LoginButton;

public class MainActivity extends AppCompatActivity {

    private CallbackManager callbackManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        setContentView(R.layout.activity_main);

        // Facebookログインボタンの処理。
        callbackManager = CallbackManager.Factory.create();
        LoginButton loginButton = (LoginButton) findViewById(R.id.login_button);
        loginButton.registerCallback(callbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(final LoginResult loginResult) {
                // ログインに成功したときの処理。
                goToMemoActivity();
            }

            @Override
            public void onCancel() {
                // ログインをキャンセルしたときの処理。
            }

            @Override
            public void onError(FacebookException error) {
                // ログインエラーが発生したときの処理。
                System.out.println("error...");
                System.out.println(error);
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();

        AccessToken token = AccessToken.getCurrentAccessToken();
        if (null != token) {
            goToMemoActivity();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        callbackManager.onActivityResult(requestCode, resultCode, data);
    }

    private void goToMemoActivity() {
        startActivity(new Intent(this, MemoActivity.class));
    }

}
