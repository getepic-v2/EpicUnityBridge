//
//  EpicUserInfoPlugin.m
//  EpicUnityBridge
//

#import "EpicUserInfoPlugin.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import <EpicUnityAdapter/EpicUnityAdapterManager.h>

@interface EpicUserInfoPlugin () <NTUSDKPluginDelegate>

@end

@implementation EpicUserInfoPlugin

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.api.user.updatevipstatus"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.api.user.updatevipstatus"]) {
        // In Epic app, VIP status is managed by PurchaseManager / AppAccount.
        // Log the event for now; implement if Unity scenes need to update subscription status.
        id<EUAAnalyticsProvider> analytics = [EpicUnityAdapterManager sharedInstance].analyticsProvider;
        [analytics trackEvent:@"unity_update_vip_status" params:reqEntity.params];
    }
}

@end
