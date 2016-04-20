package com.company.attendancemanagementapp;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.amazonaws.auth.CognitoCredentialsProvider;
import com.company.attendancemanagementapp.model.GetAttendancesResultItemsItem;

import java.util.List;

/**
 * 出社状況一覧画面のアクティビティクラスです。
 */
public class AttendanceListActivity extends AppCompatActivity {

    private static final String CLASS_NAME = AttendanceListActivity.class.getSimpleName();

    /** CognitoCredentialsProviderインスタンス */
    private CognitoCredentialsProvider credentialsProvider;

    /** ユーザー情報管理インスタンス */
    private UserDataStore userDataStore;

    /** ユーザーID */
    private String userId;
    /** パスワード */
    private String password;

    /** 出社登録ボタン */
    private Button setAttendanceButton;
    /** 出社状況一覧を表示するTextView */
    private TextView attendanceListTextView;
    /** 更新ボタン */
    private Button refreshButton;
    /** ログアウトボタン */
    private Button logoutButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_attendance_list);

        // ユーザー情報管理インスタンスの生成
        userDataStore = new UserDataStore(this);

        // ビューの取得
        setAttendanceButton = (Button) findViewById(R.id.btn_set_attendance);
        attendanceListTextView = (TextView) findViewById(R.id.text_attendance_list);
        refreshButton = (Button) findViewById(R.id.btn_refresh);
        logoutButton = (Button) findViewById(R.id.btn_logout);

        // イベント設定
        setViewEvents();
    }

    @Override
    protected void onResume() {
        super.onResume();

        // 端末に保存されているユーザーIDとパスワードを取得する
        userId = userDataStore.getUserId();
        password = userDataStore.getPassword();

        // CognitoCredentialsProviderの取得と出社状況一覧の初期表示
        attendanceListTextView.setText("認証中...");
        (new AuthTask(userId, password) {
            @Override
            protected void onPostExecute(CognitoCredentialsProvider credentialsProvider) {
                if (null != credentialsProvider) {
                    Log.d(CLASS_NAME, "認証成功");

                    // CognitoCredentialsProviderをセット
                    AttendanceListActivity.this.credentialsProvider = credentialsProvider;

                    // 出社状況一覧を取得して表示する
                    showAttendances();
                } else {
                    Log.d(CLASS_NAME, "認証失敗");

                    attendanceListTextView.setText("認証失敗");
                }
            }
        }).execute();
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        // バックキーを無効にする
        if (KeyEvent.ACTION_DOWN == event.getAction() && KeyEvent.KEYCODE_BACK == event.getKeyCode()) {
            return true;
        }
        return super.dispatchKeyEvent(event);
    }

    /**
     * ビューのイベントを割り当てます。
     */
    private void setViewEvents() {
        // 出社登録ボタンが押されたときの処理
        setAttendanceButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 出社登録する
                setAttendance();
            }
        });

        // 更新ボタンが押されたときの処理
        refreshButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 出社状況一覧を取得して表示する
                showAttendances();
            }
        });

        // ログアウトボタンが押されたときの処理
        logoutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                logout();
            }
        });
    }

    /**
     * 出社状況一覧を取得して表示します。
     */
    private void showAttendances() {
        if (null == credentialsProvider) {
            attendanceListTextView.setText("認証処理未完了");
        } else {
            attendanceListTextView.setText("出社状況一覧取得中...");

            // 出社状況一覧の取得・表示
            (new GetAttendancesTask(credentialsProvider) {
                @Override
                protected void onPostExecute(List<GetAttendancesResultItemsItem> items) {
                    if (null != items) {
                        Log.d(CLASS_NAME, "出社状況一覧取得成功");

                        // 出社状況一覧を表示する
                        String LINE_SEPARATOR = System.getProperty("line.separator");
                        String itemListString = "";
                        for (GetAttendancesResultItemsItem item : items) {
                            itemListString += item.getUserName();
                            itemListString += " : ";
                            itemListString += (item.getAttendance() ? "出社済" : "未登録");
                            itemListString += LINE_SEPARATOR;
                        }
                        attendanceListTextView.setText(itemListString);
                    } else {
                        Log.d(CLASS_NAME, "出社状況一覧取得失敗");

                        attendanceListTextView.setText("出社状況一覧取得失敗");
                    }
                }
            }).execute();
        }
    }

    /**
     * 出社登録します。登録に成功したら出社状況一覧を更新します。
     */
    private void setAttendance() {
        if (null == credentialsProvider) {
            attendanceListTextView.setText("認証処理未完了");
        } else {
            attendanceListTextView.setText("出社登録中...");

            (new SetAttendanceTask(userId, credentialsProvider) {
                @Override
                protected void onPostExecute(Boolean aBoolean) {
                    if (aBoolean) {
                        Log.d(CLASS_NAME, "出社登録成功");

                        // 出社状況一覧の更新
                        showAttendances();
                    } else {
                        Log.d(CLASS_NAME, "出社登録失敗");

                        attendanceListTextView.setText("出社登録失敗");
                    }
                }
            }).execute();
        }
    }

    /**
     * ログアウトします。
     */
    private void logout() {
        // 保存しているパスワードを破棄して前の画面に戻る
        userDataStore.clearPassword();
        finish();
    }

}
