//
//  ThirdPartyService.h
//  Test
//
//  Created by macmini on 2022/9/16.
//
//  @ThirdPartyService

//  组件化的目标：每个组件只保留一个统一的对外交互入口，最好是把所有方法通过分类的方式集中到一个类上，第三方登录有点特殊，多个登录可以并存，这里单独搞了一个类

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LoginCallback)(int code, NSDictionary * _Nullable data, NSString * _Nullable msg);

typedef NS_ENUM(int, ThirdPartyLoginError) {
    ThirdPartyLoginErrorOK                  = 0,
    ThirdPartyLoginErrorUnknown             = 10000, //未知错误
    ThirdPartyLoginErrorInvalidParameter,
    ThirdPartyLoginErrorUserCancel,
    ThirdPartyLoginErrorAuthDenied,
    ThirdPartyLoginErrorAuthDuplex,
    ThirdPartyLoginErrorAuthNotInstalled,
    ThirdPartyLoginErrorAppSign,
    ThirdPartyLoginErrorAuthCSRF,
    ThirdPartyLoginErrorAppID,
};

@interface ThirdPartyService : NSObject

@property(nonatomic, copy) LoginCallback callback;

+ (instancetype)shared;

+ (NSString *)state;

+ (void)appleLogin API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
