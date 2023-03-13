//
//  ThirdPartyService.m
//  Test
//
//  Created by macmini on 2022/9/16.
//

#import "ThirdPartyService+WechatService.h"
#import "WXApi.h"

@interface ThirdPartyService (WXApiDelegate) <WXApiDelegate>

@end

@implementation ThirdPartyService (WechatService)

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req
{
    
}



/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp 具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp*)resp
{
}

+ (void)wechatLogin:(NSString *)appid universalLink:(NSString *)universalLink callback:(LoginCallback)callback
{
    if (nil == appid || (id)kCFNull == appid || appid.length == 0) {
//        ThirdPartyService *shared = [self shared];
        if (nil != callback) {
//            callback(ThirdPartyLoginErrorAppID, nil, @"App ID == null");
//            callback = nil;
        }
        return;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXApi registerApp:appid universalLink:universalLink];
    });
    [WXApi stopLog];
    [ThirdPartyService shared].callback = callback;
    SendAuthReq *req = [SendAuthReq new];
    req.scope = @"snsapi_userinfo";//登录固定用这个
    req.state = [self state];//微信不要求base64
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req completion:nil];//必须在主线程调用，否则就非常慢
}

//appdelegate回调处理
+ (BOOL)wx_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> * _Nullable)options
{
    return [WXApi handleOpenURL:url delegate:[ThirdPartyService shared]];
}

+ (BOOL)wx_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler
{
    return [WXApi handleOpenUniversalLink:userActivity delegate:[ThirdPartyService shared]];
}

//以下两个iOS9以上过时
+ (BOOL)wx_application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self wx_application:application openURL:url options:nil];
}

+ (BOOL)wx_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self wx_application:application openURL:url options:nil];
}

@end
