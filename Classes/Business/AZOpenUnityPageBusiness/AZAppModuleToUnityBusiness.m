//
//  AZAppModuleToUnityBusiness.m
//  AZUnityBusiness
//
//  Created by 蔡永浩 on 2023/11/6.
//

#import "AZAppModuleToUnityBusiness.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import "EpicUnityBusinessData.h"
#import "AZAppModuleToUnityMQ.h"
#import "AZAppModuleToUnityMQ+BusinessPrivate.h"

@interface AZAppModuleToUnityBusiness () <NTUSDKPluginDelegate>

@end

@implementation AZAppModuleToUnityBusiness

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"sys.sceneDidLoad"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if([msgKey isEqualToString:@"sys.sceneDidLoad"]){
        [self sendPramasToUnity];
    }
}

// 场景即将恢复回调
- (void)sceneWillResume {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendPramasToUnity];
    });
}

- (void)sendPramasToUnity{
    for (NSDictionary *info in AZAppModuleToUnityMQ.shareInstance.queque) {
        for (NSString *key in info.allKeys) {
            [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:key params:info[key] callback:NULL];
        }
    }
    [AZAppModuleToUnityMQ.shareInstance clear];
}

@end
