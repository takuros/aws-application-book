//
//  UserDataStore.swift
//  AttendanceManagementApp
//

/// ユーザー情報（ユーザーID、パスワード）を管理するクラスです。
class UserDataStore {

    /// ユーザーIDの登録先キー
    private static let KEY_USER_ID = "user-id"
    /// パスワードの登録先キー
    private static let KEY_PASSWORD = "password"

    /// 端末内に保存しているユーザー情報を取得します。
    class func getUserData(userDefaults: NSUserDefaults) -> (userId: String, password: String) {
        if let userId = userDefaults.stringForKey(KEY_USER_ID) where !userId.isEmpty {
            if let password = userDefaults.stringForKey(KEY_PASSWORD) where !password.isEmpty {
                return (userId, password)
            }
            return (userId, "")
        }
        return ("", "")
    }

    /// 端末内にユーザー情報を保存します。
    class func setUserData(userDefaults: NSUserDefaults, userId: String, password: String) {
        userDefaults.setObject(userId, forKey: KEY_USER_ID)
        userDefaults.setObject(password, forKey: KEY_PASSWORD)
    }

    /// 端末内に保存しているパスワードを消去します。
    class func clearPassword(userDefaults: NSUserDefaults) {
        userDefaults.removeObjectForKey(KEY_PASSWORD)
    }

}