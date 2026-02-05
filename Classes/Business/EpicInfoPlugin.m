//
//  EpicInfoPlugin.m
//  EpicUnityBridge
//

#import "EpicInfoPlugin.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import <EpicUnityAdapter/EpicUnityAdapterManager.h>

@interface EpicInfoPlugin () <NTUSDKPluginDelegate>

@end

@implementation EpicInfoPlugin

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.sys.appinfo",
        @"app.sys.userinfo",
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.sys.appinfo"]) {
        NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"] ?: @"";
        NSString *osVersion = [NSString stringWithFormat:@"iOS %@", UIDevice.currentDevice.systemVersion];
        NSString *deviceModel = UIDevice.currentDevice.model ?: @"";

        [reqEntity callback:^NSDictionary * _Nonnull{
            return @{
                @"appVersion": appVersion,
                @"os": osVersion,
                @"device": deviceModel,
            };
        }];

    } else if ([msgKey isEqualToString:@"app.sys.userinfo"]) {
        id<EUAAuthProvider> auth = [EpicUnityAdapterManager sharedInstance].authProvider;
        NSString *userId = [auth currentUserId] ?: @"";
        NSString *token = [auth authToken] ?: @"";
        NSString *userName = @"";
        if ([auth respondsToSelector:@selector(currentUserName)]) {
            userName = [auth currentUserName] ?: @"";
        }

        [reqEntity callback:^NSDictionary * _Nonnull{
            return @{
                @"userid": userId,
                @"nickname": userName,
                @"token": token,
                @"isVisitor": (userId.length > 0) ? @"0" : @"1",
            };
        }];
    }
}

@end
