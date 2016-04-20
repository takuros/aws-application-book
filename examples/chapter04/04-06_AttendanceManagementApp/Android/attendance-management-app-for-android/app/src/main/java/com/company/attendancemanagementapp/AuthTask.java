package com.company.attendancemanagementapp;

import android.os.AsyncTask;

import com.amazonaws.auth.CognitoCredentialsProvider;

/**
 * 認証処理のためのタスククラスです。
 */
public class AuthTask extends AsyncTask<Void, Void, CognitoCredentialsProvider> {

    private String userId;
    private String password;
    private CognitoCredentialsProvider credentialsProvider;

    public AuthTask(String userId, String password) {
        this.userId = userId;
        this.password = password;
    }

    @Override
    protected CognitoCredentialsProvider doInBackground(Void... params) {
        // 認証
        MyDeveloperAuthenticationProvider authProvider = new MyDeveloperAuthenticationProvider(userId, password);
        credentialsProvider = MyDeveloperAuthenticationProvider.getCredentialsProvider(authProvider);
        return credentialsProvider;
    }

}
