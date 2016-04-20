package com.company.attendancemanagementapp;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.amazonaws.auth.CognitoCredentialsProvider;

/**
 * ログイン画面のアクティビティクラスです。
 */
public class MainActivity extends AppCompatActivity {

    private static final String CLASS_NAME = MainActivity.class.getSimpleName();

    /** ユーザー情報管理インスタンス */
    private UserDataStore userDataStore;

    /** ログインエラー表示 */
    private TextView loginErrorText;
    /** ユーザーID入力エリア */
    private EditText userIdEditText;
    /** パスワード入力エリア */
    private EditText passwordEditText;
    /** ログインボタン */
    private Button loginButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // ユーザー情報管理インスタンスの生成
        userDataStore = new UserDataStore(this);

        // ビューの取得
        loginErrorText = (TextView) findViewById(R.id.text_login_error);
        userIdEditText = (EditText) findViewById(R.id.edit_user_id);
        passwordEditText = (EditText) findViewById(R.id.edit_password);
        loginButton = (Button) findViewById(R.id.btn_login);

        // イベント設定
        setViewEvents();
    }

    @Override
    protected void onResume() {
        super.onResume();

        // 端末に保存されているユーザーIDとパスワードを取得する
        final String userId = userDataStore.getUserId();
        final String password = userDataStore.getPassword();

        // 入力エリアにユーザーIDとパスワードを表示しておく
        userIdEditText.setText(userId);
        passwordEditText.setText(password);

        // ユーザーIDとパスワードが保存されている場合はログインを試行して出社状況一覧画面へ遷移する
        if (!userId.isEmpty() && !password.isEmpty()) {
            (new AuthTask(userId, password) {
                @Override
                protected void onPostExecute(CognitoCredentialsProvider credentialsProvider) {
                    if (null != credentialsProvider) {
                        // 出社状況一覧画面へ遷移
                        startActivity(new Intent(getApplicationContext(), AttendanceListActivity.class));
                    }
                }
            }).execute();
        }
    }

    /**
     * ビューのイベントを割り当てます。
     */
    private void setViewEvents() {
        // ログインボタンが押されたときにログインを試行して出社状況一覧画面へ遷移する
        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 入力されているユーザーIDとパスワードを取得する
                final String userId = userIdEditText.getText().toString();
                final String password = passwordEditText.getText().toString();

                // ユーザーIDとパスワードの入力チェック
                if (userId.isEmpty() || password.isEmpty()) {
                    loginErrorText.setVisibility(View.VISIBLE);
                    return;
                }

                // 認証処理
                (new AuthTask(userId, password) {
                    @Override
                    protected void onPostExecute(CognitoCredentialsProvider credentialsProvider) {
                        if (null != credentialsProvider) {
                            Log.d(CLASS_NAME, "認証成功");

                            // ユーザーIDとパスワードを保存する
                            userDataStore.setUserData(userId, password);

                            // ログインエラー表示を隠す
                            loginErrorText.setVisibility(View.GONE);

                            // 出社状況一覧画面へ遷移
                            startActivity(new Intent(getApplicationContext(), AttendanceListActivity.class));
                        } else {
                            Log.d(CLASS_NAME, "認証失敗");

                            // ログインエラー表示
                            loginErrorText.setVisibility(View.VISIBLE);
                        }
                    }
                }).execute();
            }
        });
    }

}
