package com.company.attendancemanagementapp;

import android.os.AsyncTask;

import com.amazonaws.auth.CognitoCredentialsProvider;
import com.amazonaws.mobileconnectors.apigateway.ApiClientFactory;

import java.util.List;

import com.company.attendancemanagementapp.model.GetAttendancesResult;
import com.company.attendancemanagementapp.model.GetAttendancesResultItemsItem;

/**
 * 出社状況取得のためのタスククラスです。
 */
public class GetAttendancesTask extends AsyncTask<Void, Void, List<GetAttendancesResultItemsItem>> {

    private CognitoCredentialsProvider credentialsProvider;

    public GetAttendancesTask(CognitoCredentialsProvider credentialsProvider) {
        this.credentialsProvider = credentialsProvider;
    }

    @Override
    protected List<GetAttendancesResultItemsItem> doInBackground(Void... params) {
        if (null != credentialsProvider) {
            // ユーザー一覧を取得する
            try {
                // ApiClientの生成
                ApiClientFactory factory = (new ApiClientFactory()).credentialsProvider(credentialsProvider);
                AttendanceAPIClient client = factory.build(AttendanceAPIClient.class);

                // ユーザー一覧取得
                GetAttendancesResult result = client.getAttendancesGet();
                return result.getItems();
            } catch (Exception e) {
                return null;
            }

        }
        return null;
    }
}
