//
//  ThirdPartyService+AlipayService.h
//  Test
//
//  Created by macmini on 2022/9/17.
//
//  @ThirdPartyService

#import <UIKit/UIKit.h>
#import "ThirdPartyService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AlipayService <NSObject>

@optional

+ (void)alipayLogin:(NSString *)appid universalLink:(NSString *)universalLink callback:(LoginCallback)callback;

//appdelegate回调处理
+ (BOOL)ap_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> * _Nullable)options;

+ (BOOL)ap_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler;

//以下两个iOS9以上过时
+ (BOOL)ap_application:(UIApplication *)application handleOpenURL:(NSURL *)url;

+ (BOOL)ap_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

@end

@interface ThirdPartyService (AlipayService) <AlipayService>

@end

NS_ASSUME_NONNULL_END
