package com.company.attendancemanagementapp;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * ユーザー情報（ユーザーID、パスワード）を管理するクラスです。
 */
public class UserDataStore {

    /** SharedPreferencesの名前 */
    private static final String SP_NAME = "id-pass";
    /** ユーザーIDの登録キー */
    private static final String SP_KEY_USER_ID = "user-id";
    /** パスワードの登録キー */
    private static final String SP_KEY_PASSWORD = "password";

    private SharedPreferences sharedPreferences;

    public UserDataStore(Context context) {
        sharedPreferences = context.getSharedPreferences(SP_NAME, Context.MODE_PRIVATE);
    }

    /**
     * 端末内に保存しているユーザーIDを取得します。
     */
    public String getUserId() {
        return sharedPreferences.getString(SP_KEY_USER_ID, "");
    }

    /**
     * 端末内に保存しているパスワードを取得します。
     */
    public String getPassword() {
        return sharedPreferences.getString(SP_KEY_PASSWORD, "");
    }

    /**
     * 端末内にユーザーIDとパスワードを保存します。
     */
    public void setUserData(String userId, String password) {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(SP_KEY_USER_ID, userId);
        editor.putString(SP_KEY_PASSWORD, password);
        editor.apply();
    }

    /**
     * 端末内に保存しているパスワードを消去します。
     */
    public void clearPassword() {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.remove(SP_KEY_PASSWORD);
        editor.apply();
    }

}
