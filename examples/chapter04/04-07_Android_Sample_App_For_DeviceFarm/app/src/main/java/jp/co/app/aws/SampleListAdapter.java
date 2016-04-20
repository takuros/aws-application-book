package jp.co.app.aws;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

public class SampleListAdapter extends BaseAdapter {

    Context context;
    LayoutInflater layoutInflater = null;
    SampleListType dataList;

    public SampleListAdapter(Context context) {
        this.context = context;
        this.layoutInflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    public void setListData(SampleListType dataList) {
        this.dataList = dataList;
    }

    @Override
    public int getCount() {
        if(dataList != null && dataList.Items != null) {
            return dataList.Items.size();
        }else{
            return 0;
        }
    }

    @Override
    public Object getItem(int position) {
        if(dataList != null && dataList.Items != null && dataList.Items.get(position) != null) {
            return dataList.Items.get(position);
        }else{
            return null;
        }
    }

    @Override
    public long getItemId(int position) {
        if(dataList != null && dataList.Items != null && dataList.Items.get(position) != null) {
            return dataList.Items.get(position).ItemID;
        }else{
            return 0;
        }
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        convertView = layoutInflater.inflate(R.layout.sample_row_item,parent,false);

        ((TextView)convertView.findViewById(R.id.name)).setText(dataList.Items.get(position).Name);
        ((TextView)convertView.findViewById(R.id.price)).setText("¥" + String.valueOf(dataList.Items.get(position).Price) + " - ");

        return convertView;
    }
}