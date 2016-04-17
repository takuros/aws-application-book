//
//  MyDeveloperAuthenticatedIdentityProvider.swift
//  AttendanceManagementApp
//

/// 独自認証のプロバイダークラスです。
class MyDeveloperAuthenticatedIdentityProvider: AWSAbstractCognitoIdentityProvider {

    /// 開発者のユーザーアカウント
    static let DEVELOPER_ACCOUNT_ID = "developer@example.com"
    /// CognitoのDeveloper provider name
    static let PROVIDER_NAME = "login.company.attendancemanagementapp"
    /// CognitoのIdentity pool id
    static let IDENTITY_POOL_ID = "ap-northeast-1:01234567-0123-0123-0123-0123456789ab"
    /// Cognitoのリージョン
    static let REGION = AWSRegionType.APNortheast1
    /// 未認証時のCognitoのロールARN
    static let ARN_UNAUTH_ROLE = "arn:aws:iam::XXXXXXXXXXXX:role/Cognito_AttendanceManagementIdentityPoolUnauth_Role"
    /// 認証後のCognitoのロールARN
    static let ARN_AUTH_ROLE = "arn:aws:iam::XXXXXXXXXXXX:role/Cognito_AttendanceManagementIdentityPoolAuth_Role"

    /// 匿名ユーザーとしてAPI Gatewayに接続する際に使用するAWSServiceConfigurationを格納する先のキー名
    static let REGISTER_KEY_ANONYMOUS_CONFIG = "AnonymousConfig"

    /// CognitoのDeveloper provider name
    private final var _providerName: String!
    override var providerName: String! {
        get { return _providerName }
        set { _providerName = newValue }
    }

    /// Cognitoのトークン
    private final var _token: String!
    override var token: String! {
        get { return _token }
        set { _token = newValue }
    }

    /// ユーザーID
    private let userId: String!
    /// パスワード
    private let password: String!

    /// イニシャライザ
    init(userId: String, password: String) {
        // プロパティの初期化
        self.userId = userId
        self.password = password

        // スーパークラスの初期化
        super.init(
            regionType: MyDeveloperAuthenticatedIdentityProvider.REGION,
            identityId: nil,
            accountId: MyDeveloperAuthenticatedIdentityProvider.DEVELOPER_ACCOUNT_ID,
            identityPoolId: MyDeveloperAuthenticatedIdentityProvider.IDENTITY_POOL_ID,
            logins: nil
        )
        self.providerName = MyDeveloperAuthenticatedIdentityProvider.PROVIDER_NAME
    }

    /// ユーザーのIdentity idとトークンを更新します。
    override func refresh() -> AWSTask! {
        return self.getTokenAndIdentityId().continueWithBlock { (task: AWSTask!) -> AWSTask! in
            if let response = task.result as? ATTENDANCEAPIGetTokenAndIdentityIdResult {
                self.identityId = response.identityId
                self.token = response.token
            }
            return AWSTask(result: self.identityId)
        }
    }

    /// ユーザーのIdentity idを取得します。
    override func getIdentityId() -> AWSTask! {
        if nil == self.identityId {
            return self.getTokenAndIdentityId().continueWithBlock { (task: AWSTask!) -> AWSTask! in
                if let response = task.result as? ATTENDANCEAPIGetTokenAndIdentityIdResult {
                    self.identityId = response.identityId
                }
                return AWSTask(result: self.identityId)
            }
        }
        return AWSTask(result: self.identityId)
    }

    /// ユーザーのIdentity idとトークンを取得します。
    private func getTokenAndIdentityId() -> AWSTask {
        // 匿名ユーザーとしてAPI Gatewayにアクセスするための設定
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: MyDeveloperAuthenticatedIdentityProvider.REGION,
            identityPoolId: MyDeveloperAuthenticatedIdentityProvider.IDENTITY_POOL_ID
        )
        let configuration = AWSServiceConfiguration(
            region: MyDeveloperAuthenticatedIdentityProvider.REGION,
            credentialsProvider: credentialsProvider
        )
        ATTENDANCEAPIAttendanceAPIClient.registerClientWithConfiguration(
            configuration,
            forKey: MyDeveloperAuthenticatedIdentityProvider.REGISTER_KEY_ANONYMOUS_CONFIG
        )

        // ユーザーIDに紐付くIdentity idとトークンの取得を開始
        let client = ATTENDANCEAPIAttendanceAPIClient(forKey: MyDeveloperAuthenticatedIdentityProvider.REGISTER_KEY_ANONYMOUS_CONFIG)
        return client.getTokenAndIdentityIdGet(self.userId, password: self.password)
    }

}
