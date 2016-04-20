package com.company.picturesharingapp;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

public class ImageViewActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_image_view);

        // 閉じるボタン
        final Button closeButton = (Button) findViewById(R.id.button_close);
        closeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        // 画像を表示する
        final ImageView imageView = (ImageView) findViewById(R.id.imageView);
        File file = new File(getExternalCacheDir(), "tmp.jpg");
        try {
            InputStream is = new FileInputStream(file);
            Bitmap bm = BitmapFactory.decodeStream(is);
            imageView.setImageBitmap(bm);
        } catch (Exception e) {
            System.err.println("ファイル読み込みエラー");
            e.printStackTrace();
            finish();
        }
    }
}
