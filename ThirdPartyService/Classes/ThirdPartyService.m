//
//  ThirdPartyService.m
//  Test
//
//  Created by macmini on 2022/9/16.
//

#import "ThirdPartyService.h"
#import <AuthenticationServices/AuthenticationServices.h>

@implementation ThirdPartyService

static NSString *const kResultCode = @"code";
static NSString *const kResultUserId = @"channelId";
static NSString *const kNickname = @"nickname";

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static ThirdPartyService *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (NSString *)state
{
    Byte key[16];
    int result = SecRandomCopyBytes(kSecRandomDefault, sizeof(key), key);
    if (0 != result) {
        arc4random_buf(key, sizeof(key));//简单随机生成密钥
    }
    NSString *state = [[NSData dataWithBytes:key length:sizeof(key)] base64EncodedStringWithOptions:kNilOptions];
    state = [state stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"/=+"] invertedSet]];
    return state;
}

#pragma mark - Apple id登录
/**
 https://www.jianshu.com/p/483b998f2370
 在项目中的 Signing&Capabilities 中添加 sign in with apple。在开发者官网中也要添加
 */
static NSString *const kAppleUserID = @"AppleUserIDKey";
static NSString *const kAppleNickname = @"AppleNicknameKey";
static NSString *const kAppleToken = @"AppleTokenKey";
+ (void)appleLogin API_AVAILABLE(ios(13.0))
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:kAppleUserID];
    if (nil == userId) {
        [self appleAuthorizationAppleIDRequest];
        return;
    }
    ASAuthorizationAppleIDProvider *provider = [ASAuthorizationAppleIDProvider new];
    [provider getCredentialStateForUserID:userId completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
        if (credentialState != ASAuthorizationAppleIDProviderCredentialAuthorized) {
            [self appleAuthorizationAppleIDRequest];
            return;
        }
        ThirdPartyService *shared = [self shared];
        if (shared->_callback) {
            shared->_callback(ThirdPartyLoginErrorOK, @{
                kResultUserId : userId,
                kNickname : [[NSUserDefaults standardUserDefaults] stringForKey:kAppleNickname],
                kResultCode : [[NSUserDefaults standardUserDefaults] stringForKey:kAppleToken]
                                 }, nil);
            shared->_callback = nil;
        }
        switch (credentialState) {
            case ASAuthorizationAppleIDProviderCredentialRevoked:
                //用户收回了权限，跟自己服务器解绑
                break;
            case ASAuthorizationAppleIDProviderCredentialNotFound:
                //
                break;
            case ASAuthorizationAppleIDProviderCredentialTransferred:
                //
                break;
            default://
                break;
        }
    }];
}

+ (void)appleAuthorizationAppleIDRequest API_AVAILABLE(ios(13.0))
{
    ASAuthorizationAppleIDProvider *provider = [ASAuthorizationAppleIDProvider new];
    // 创建新的AppleID授权请求
    ASAuthorizationAppleIDRequest *request = [provider createRequest];
    // 在用户授权期间请求的联系信息
    request.requestedScopes = @[
        ASAuthorizationScopeEmail,//这个必须有，不然获取到FullName
        ASAuthorizationScopeFullName
    ];
    // 由 ASAuthorizationAppleIDProvider 创建的授权请求来管理 授权请求控制器
    ASAuthorizationController *authController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
    authController.delegate = [self shared];
    [authController performRequests];
}

/// Apple登录授权出错
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error API_AVAILABLE(ios(13.0))
{
    if (nil == _callback) {
        return;
    }
    if (error.code == ASAuthorizationErrorCanceled) {
        _callback(ThirdPartyLoginErrorUserCancel, nil, @"用户取消");
    } else {
        _callback(ThirdPartyLoginErrorUnknown, nil, error.localizedDescription);
    }
    _callback = nil;
    
    NSLog(@"Apple登录_错误信息: %@", error.localizedDescription);
    switch (error.code) {
        case ASAuthorizationErrorUnknown:// 授权请求未知错误
            NSLog(@"Apple登录_授权请求未知错误");
            break;
        case ASAuthorizationErrorCanceled:// 授权请求取消了
            NSLog(@"Apple登录_授权请求取消了");
            break;
        case ASAuthorizationErrorInvalidResponse:// 授权请求响应无效
            NSLog(@"Apple登录_授权请求响应无效");
            break;
        case ASAuthorizationErrorNotHandled:// 授权请求未能处理
            NSLog(@"Apple登录_授权请求未能处理");
            break;
        case ASAuthorizationErrorFailed:// 授权请求失败
            NSLog(@"Apple登录_授权请求失败");
            break;
    }
}

/// Apple登录授权成功
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0))
{
    if (nil == _callback) {
        return;
    }
    Class credentialClass = [authorization.credential class];
    if (credentialClass == [ASAuthorizationAppleIDCredential class]) {
        // 用户登录使用的是: ASAuthorizationAppleIDCredential,授权成功后可以取到苹果返回的全部数据,然后再与后台交互
        ASAuthorizationAppleIDCredential *credential = (ASAuthorizationAppleIDCredential *)authorization.credential;
        NSString *userID = credential.user;
        NSString *nickname = credential.fullName.nickname;
        if (!nickname || nickname.length == 0) {
            nickname = credential.fullName.givenName;
            if (!nickname || nickname.length == 0) {
                nickname = @"";
            }
        }
        NSString *token = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding] ?: @"";
        _callback(ThirdPartyLoginErrorOK, @{
            kResultUserId : userID,
            kNickname: nickname,
            kResultCode: token}, nil);
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:userID forKey:kAppleUserID];
        [ud setObject:nickname forKey:kAppleNickname];
        [ud setObject:token forKey:kAppleToken];
//        [ud synchronize];
        
//        NSString *state = credential.state;
//        NSArray<ASAuthorizationScope> *authorizedScopes = credential.authorizedScopes;
////         refresh_token
//        NSString *authorizationCode = [[NSString alloc] initWithData:credential.authorizationCode encoding:NSUTF8StringEncoding];
//        // access_token
//        NSString *identityToken = [[NSString alloc] initWithData:credential.identityToken encoding:NSUTF8StringEncoding];
//        NSString *email = credential.email;
//        NSPersonNameComponents *fullName = credential.fullName;
//        ASUserDetectionStatus realUserStatus = credential.realUserStatus;
////
//        NSLog(@"Apple登录_1_user: %@", userID);
//        NSLog(@"Apple登录_4_authorizationCode: %@", authorizationCode);
//        NSLog(@"Apple登录_5_identityToken: %@", identityToken);
//        NSLog(@"Apple登录_6_email: %@", email);
//        NSLog(@"Apple登录_7_fullName.givenName: %@", fullName.givenName);
//        NSLog(@"Apple登录_7_fullName.familyName: %@", fullName.familyName);
//        NSLog(@"Apple登录_7_fullName.namePrefix: %@", fullName.namePrefix);
//        NSLog(@"Apple登录_7_fullName.middleName: %@", fullName.middleName);
//        NSLog(@"Apple登录_7_fullName.nickname: %@", fullName.nickname);
//        NSLog(@"Apple登录_7_fullName.nickname: %@", fullName);
//        NSLog(@"Apple登录_8_realUserStatus: %ld", realUserStatus);
        //接下来就调用自己服务器接口
    } else if (credentialClass == [ASPasswordCredential class]) {
        _callback(ThirdPartyLoginErrorUnknown, nil, @"苹果账号未登录");
        // 用户登录使用的是: 现有密码凭证
//        ASPasswordCredential *credential = (ASPasswordCredential *)authorization.credential;
//        NSString *user = credential.user; // 密码凭证对象的用户标识(用户的唯一标识)
//        NSString *password = credential.password;
//        NSLog(@"Apple登录_现有密码凭证: %@, %@", user, password);
//        _callback(user, nil);
    }
    _callback = nil;
}

@end
