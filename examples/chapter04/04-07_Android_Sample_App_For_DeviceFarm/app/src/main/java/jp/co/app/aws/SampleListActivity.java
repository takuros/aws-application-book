package jp.co.app.aws;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.android.volley.Response;
import com.android.volley.VolleyError;

public class SampleListActivity extends AppCompatActivity {

    private SampleListType listData;
    private SwipeRefreshLayout mSwipeRefreshLayout;
    private int throwCnt = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sample_list);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        // SwipeRefreshLayoutの設定
        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.refresh);
        mSwipeRefreshLayout.setOnRefreshListener(mOnRefreshListener);
        mSwipeRefreshLayout.setRefreshing(true);

        sendRequest();
    }

    private void viewList(){
        ListView listView = (ListView)findViewById(R.id.listView);
        SampleListAdapter adapter = new SampleListAdapter(getApplicationContext());
        adapter.setListData(listData);
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(getApplication(), SampleDetailActivity.class);
                intent.putExtra("ItemID", id);
                startActivity(intent);

                if(id == 12){
                    SampleApplication.getInstance().throwException("ItemIDが12のアイテム押下時");
                }

                throwCnt += 1;
                if(throwCnt == 10){
                    SampleApplication.getInstance().throwException("リストアイテム10回押下時");
                }
            }
        });
    }

    private void sendRequest(){
        SampleApplication.getInstance().addToRequestQueue(new SampleListRequest(new SampleListRequest.SampleRequestResponseListener() {
            @Override
            public void onResponse(SampleListType response) {
                mSwipeRefreshLayout.setRefreshing(false);
                listData = response;
                viewList();
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                mSwipeRefreshLayout.setRefreshing(false);
                SampleApplication.getInstance().throwException("エラーレスポンスの時");
            }
        }));
    }

    private SwipeRefreshLayout.OnRefreshListener mOnRefreshListener = new SwipeRefreshLayout.OnRefreshListener() {
        @Override
        public void onRefresh() {
            sendRequest();

            SampleApplication.getInstance().throwException("PullToRefresh時");
        }
    };
}
