//
//  WechatService.h
//  Test
//
//  Created by macmini on 2022/9/16.
//
//  @ThirdPartyService

#import <UIKit/UIKit.h>
#import "ThirdPartyService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WechatService <NSObject>

+ (void)wechatLogin:(NSString *)appid universalLink:(NSString *)universalLink callback:(LoginCallback)callback;

//appdelegate回调处理
+ (BOOL)wx_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> * _Nullable)options;

+ (BOOL)wx_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler;

//以下两个iOS9以上过时
+ (BOOL)wx_application:(UIApplication *)application handleOpenURL:(NSURL *)url;

+ (BOOL)wx_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end

@interface ThirdPartyService (WechatService) <WechatService>

@end

NS_ASSUME_NONNULL_END
