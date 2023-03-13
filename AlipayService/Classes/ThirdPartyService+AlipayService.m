//
//  ThirdPartyService+AlipayService.m
//  Test
//
//  Created by macmini on 2022/9/17.
//

#import "ThirdPartyService+AlipayService.h"
#import "AlipaySDK/AlipaySDK.h"

@implementation ThirdPartyService (AlipayService)

+ (void)alipayLogin:(nonnull NSString *)appid universalLink:(nonnull NSString *)universalLink callback:(nonnull LoginCallback)callback {
}

+ (BOOL)ap_application:(nonnull UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    return YES;
}

+ (BOOL)ap_application:(nonnull UIApplication *)application openURL:(nonnull NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> * _Nullable)options
{
    return YES;
}

+ (BOOL)ap_application:(nonnull UIApplication *)application handleOpenURL:(nonnull NSURL *)url
{
    return [self ap_application:application openURL:url options:nil];
}

+ (BOOL)ap_application:(nonnull UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nonnull NSString *)sourceApplication annotation:(nonnull id)annotation
{
    return [self ap_application:application openURL:url options:nil];
}

@end
