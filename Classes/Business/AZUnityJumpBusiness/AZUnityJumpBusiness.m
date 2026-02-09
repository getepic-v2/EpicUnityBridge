//
//  AZUnityJumpBusiness.m
//  AZAppConfig
//
//  Created by wangyiyang on 2023/8/5.
//

#import "AZUnityJumpBusiness.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import "EpicUnitySceneConfig.h"
#import "EpicUnitySDKAgent.h"
#import "EpicUnityBridgeCore.h"

@interface AZUnityJumpBusiness () <NTUSDKPluginDelegate>

@end

@implementation AZUnityJumpBusiness

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.api.jump.scheme",
        @"app.api.jump.switch",
        @"app.api.version.update",
        @"api.app.exitlive",
        @"app.api.jump.openURL"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.api.jump.scheme"]) {
        NSString *scheme = [reqEntity.params wx_stringForKey:@"scheme"];
        if (![WXEmptyUtils isEmptyString:scheme]) {
//            [JumpUrlHandle jumpWithUrlString:scheme extraParams:nil];
        }
    } else if ([msgKey isEqualToString:@"app.api.jump.switch"])
    {
        [self switchModWithReqEntity:reqEntity];
    } else if ([msgKey isEqualToString:@"app.api.version.update"]) {
        // alert updata
        // NSString *tip = [reqEntity.params wx_stringForKey:@"updateHint" defaultValue:@"这个功能需要更新版本才能使用哦~"];
    }
    else if ([msgKey isEqualToString:@"api.app.exitlive"])
    {
        // 退出场景
        [[NTUnityInSDK shareInstance] exitScene];
    }else if ([msgKey isEqualToString:@"app.api.jump.openURL"])
    {
        NSString *url = [reqEntity.params wx_stringForKey:@"url" defaultValue:@""];
        if (url && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
        }
    }
}

- (void)switchModWithReqEntity:(NTUnityMsgEntity *)reqEntity
{
    NSString *planId = [reqEntity.params wx_stringForKey:@"planId"];
    NSDictionary *paramDic = [reqEntity.params wx_dictionaryForKey:@"paramDic"];
    NTUSceneConfig *config = [EpicUnitySceneConfig defaultConfig];
    config.backBtnShouldHidden = [NTUnityInSDK shareInstance].currentSceneConfig.backBtnShouldHidden;
    config.paramDic = paramDic;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[EpicUnityBridgeCore sharedInstance] loadSceneWithId:planId sceneConfig:config];
    });
}

@end
