package com.company.attendancemanagementapp;

import android.os.AsyncTask;

import com.amazonaws.auth.CognitoCredentialsProvider;
import com.amazonaws.mobileconnectors.apigateway.ApiClientFactory;

import com.company.attendancemanagementapp.model.SetAttendanceRequest;

/**
 * 出社登録のためのタスククラスです。
 */
public class SetAttendanceTask extends AsyncTask<Void, Void, Boolean> {

    private String userId;
    private CognitoCredentialsProvider credentialsProvider;

    public SetAttendanceTask(String userId, CognitoCredentialsProvider credentialsProvider) {
        this.userId = userId;
        this.credentialsProvider = credentialsProvider;
    }

    @Override
    protected Boolean doInBackground(Void... params) {
        if (null != credentialsProvider) {
            // 出社登録する
            try {
                // API Clientの生成
                ApiClientFactory factory = (new ApiClientFactory()).credentialsProvider(credentialsProvider);
                AttendanceAPIClient client = factory.build(AttendanceAPIClient.class);

                // 出社登録のパラメータ生成
                SetAttendanceRequest request = new SetAttendanceRequest();
                request.setUserId(userId);

                // 出社登録
                client.setAttendancePost(request);
                return true;
            } catch (Exception e) {
                return false;
            }
        }
        return false;
    }
}
