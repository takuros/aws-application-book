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

public class SampleDetailRequest extends Request<SampleDetailType> {
    private final Gson gson = new Gson();
    private final Class<SampleDetailType> clazz;
    private final SampleDetailRequestResponseListener listener;
    private String bodyJSON = null;

    public interface SampleDetailRequestResponseListener {
        public void onResponse(SampleDetailType response);
    }

    public static SampleDetailRequest get(long itemId, SampleDetailRequestResponseListener listener,
                                          Response.ErrorListener errorListener) {

        SampleDetailRequest sampleRequest = new SampleDetailRequest(itemId, listener, errorListener);

        return sampleRequest;
    }

    public SampleDetailRequest(long itemId, SampleDetailRequestResponseListener listener,
                               Response.ErrorListener errorListener) {

        //TODO Amazon API Gateway Item Detail URL
        super(Method.POST, "https://xxxxxx", errorListener);

        // 正常時終了時に返却するクラス型セット
        this.clazz = SampleDetailType.class;

        // レスポンスリスナーセット
        this.listener = listener;

        // RequestBodyにJSONセット
        this.bodyJSON = "{\"ItemID\":"+ itemId +"}";
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
    protected void deliverResponse(SampleDetailType response) {
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
    protected Response<SampleDetailType> parseNetworkResponse(NetworkResponse response) {
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