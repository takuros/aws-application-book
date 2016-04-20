package com.company.attendancemanagementapp;

import android.app.Application;
import android.util.Log;

import com.amazonaws.auth.CognitoCredentialsProvider;

import org.altbeacon.beacon.BeaconManager;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.Region;
import org.altbeacon.beacon.startup.BootstrapNotifier;
import org.altbeacon.beacon.startup.RegionBootstrap;

public class MyApplication extends Application implements BootstrapNotifier {

    private static final String CLASS_NAME = MyApplication.class.getSimpleName();

    // 検知するiBeaconの情報
    /** iBeaconのデータ形式 */
    private static final String IBEACON_LAYOUT = "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24";
    /** iBeaconに付けるユニークな識別子 */
    private static final String UNIQUE_ID = "社内のビーコン";
    /** iBeaconのUUID */
    private static final String UUID = "01234567-89AB-CDEF-0123-456789ABCDEF";
    /** iBeaconのMajor */
    private static final int MAJOR = 10;
    /** iBeaconのMinor */
    private static final int MINOR = 20;

    /** RegionBootstrapインスタンス */
    private RegionBootstrap regionBootstrap;

    @Override
    public void onCreate() {
        super.onCreate();

        // iBeaconを検知できるように設定
        BeaconManager beaconManager = BeaconManager.getInstanceForApplication(this);
        beaconManager.getBeaconParsers().add(new BeaconParser().setBeaconLayout(IBEACON_LAYOUT));

        // iBeaconの検知開始
        Region region = new Region(
                UNIQUE_ID,
                Identifier.parse(UUID),
                Identifier.fromInt(MAJOR),
                Identifier.fromInt(MINOR)
        );
        regionBootstrap = new RegionBootstrap(this, region);
    }

    /**
     * iBeaconのビーコン領域に入ったときに呼ばれるメソッドです。
     */
    @Override
    public void didEnterRegion(Region region) {
        Log.d(CLASS_NAME, "iBeaconのビーコン領域に入りました。");
        Log.d(CLASS_NAME, "region: " + region.toString());

        // 出社登録
        setAttendance();
    }

    /**
     * iBeaconのビーコン領域から出たときに呼ばれるメソッドです。
     */
    @Override
    public void didExitRegion(Region region) {
        Log.d(CLASS_NAME, "iBeaconのビーコン領域から出ました。");
        Log.d(CLASS_NAME, "region: " + region.toString());
    }

    /**
     * iBeaconのステータスが変化したときに呼ばれるメソッドです。
     */
    @Override
    public void didDetermineStateForRegion(int i, Region region) {
        Log.d(CLASS_NAME, "iBeaconのステータスが変化しました。");
        Log.d(CLASS_NAME, "i: " + i);
        Log.d(CLASS_NAME, "region: " + region.toString());
    }

    /**
     * 出社登録します。
     */
    private void setAttendance() {
        // 保存されているユーザーIDとパスワードを取得する
        final UserDataStore userDataStore = new UserDataStore(this);
        final String userId = userDataStore.getUserId();
        final String password = userDataStore.getPassword();
        // いずれかが保存されていない場合は処理を終了
        if (userId.isEmpty() || password.isEmpty()) {
            return;
        }

        // 認証後、出社登録する
        (new AuthTask(userId, password) {
            @Override
            protected void onPostExecute(CognitoCredentialsProvider credentialsProvider) {
                if (null != credentialsProvider) {
                    // 出社登録処理
                    (new SetAttendanceTask(userId, credentialsProvider) {
                        @Override
                        protected void onPostExecute(Boolean aBoolean) {
                            if (aBoolean) {
                                Log.d(CLASS_NAME, "iBeacon検知による出社登録成功");
                            } else {
                                Log.d(CLASS_NAME, "iBeacon検知による出社登録失敗");
                            }
                        }
                    }).execute();
                }
            }
        }).execute();
    }

}
