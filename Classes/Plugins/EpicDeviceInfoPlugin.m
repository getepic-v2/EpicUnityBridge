//
//  EpicDeviceInfoPlugin.m
//  EpicUnityBridge
//

#import "EpicDeviceInfoPlugin.h"
#import <NTUnityIn/NTUnityInSDK.h>

@interface EpicDeviceInfoPlugin () <NTUSDKPluginDelegate>

@end

@implementation EpicDeviceInfoPlugin

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.api.device.installList"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.api.device.installList"]) {
        // Epic app doesn't need Chinese app detection.
        // Return empty result; extend as needed for Epic-specific apps.
        [reqEntity callback:^NSDictionary * _Nonnull{
            return @{};
        }];
    }
}

@end
