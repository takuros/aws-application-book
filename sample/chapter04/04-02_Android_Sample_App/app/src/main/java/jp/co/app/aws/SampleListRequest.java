package jp.co.app.aws;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkResponse;
import com.android.volley.ParseError;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.HttpHeaderParser;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import java.io.UnsupportedEncodingException;
import java.util.Map;

public class SampleListRequest extends Request<SampleListType> {
    private final Gson gson = new Gson();
    private final Class<SampleListType> clazz;
    private final SampleRequestResponseListener listener;
    private String bodyJSON = null;

    /**
     * 独自データ型のレスポンスリスナーを実装
     */
    public interface SampleRequestResponseListener {
        public void onResponse(SampleListType response);
    }

    /**
     * リクエストのインスタンス取得
     * @param listener レスポンスリスナー
     * @param errorListener エラーリスナー
     * @return リクエストのインスタンス
     */
    public static SampleListRequest get(SampleRequestResponseListener listener,
                                    Response.ErrorListener errorListener) {

        SampleListRequest sampleRequest = new SampleListRequest(listener, errorListener);

        return sampleRequest;
    }

    /**
     * コンストラクタ
     * @param listener 正常終了時のネットワークレスポンス
     * @param errorListener 異常終了時のネットワークレスポンス
     */
    public SampleListRequest(SampleRequestResponseListener listener,
                         Response.ErrorListener errorListener) {

        //TODO Amazon API Gateway Item List URL
        super(Method.GET, "https://xxxxxxx", errorListener);

        // 正常時終了時に返却するクラス型セット
        this.clazz = SampleListType.class;

        // レスポンスリスナーセット
        this.listener = listener;
    }

    @Override
    protected Map<String, String> getParams() throws AuthFailureError {
        return null;
    }

    @Override
    public byte[] getBody() throws AuthFailureError {
        return bodyJSON.getBytes();
    }

    @Override
    protected void deliverResponse(SampleListType response) {
        // 成形したデータを返す
        // リスナーが存在すればレスポンスを返す
        if (this.listener != null) {
            this.listener.onResponse(response);
        } else {
            deliverError(new VolleyError("ResponseListener is Null."));
        }
    }

    @Override
    public void deliverError(VolleyError error) {
        // エラーレスポンス
        super.deliverError(error);
    }

    @Override
    protected Response<SampleListType> parseNetworkResponse(NetworkResponse response) {
        // データを成形する
        // 成功：deliverResponse
        // 失敗：deliverError
        try {
            String json = new String(
                    response.data,
                    HttpHeaderParser.parseCharset(response.headers));
            return Response.success(
                    gson.fromJson(json, clazz),
                    HttpHeaderParser.parseCacheHeaders(response));
        } catch (UnsupportedEncodingException e) {
            return Response.error(new ParseError(e));
        } catch (JsonSyntaxException e) {
            return Response.error(new ParseError(e));
        } catch (NullPointerException e) {
            return Response.error(new ParseError(e));
        }
    }
}