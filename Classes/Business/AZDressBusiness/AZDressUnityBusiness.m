//
//  AZDressUnityBusiness.m
//  AZCommonBusiness
//
//  Created by leev on 2023/8/1.
//

#import "AZDressUnityBusiness.h"
#import "AZDressManager.h"
#import <NTUnityIn/NTUnityInSDK.h>

@interface AZDressUnityBusiness () <NTUSDKPluginDelegate>

@end

@implementation AZDressUnityBusiness

#pragma mark - NTUBridgeBusinessDispatchDelegate

+ (NSArray<NSString *> *)unityToNativeMsgKeys
{
    return @[
        @"app.mod.show.skinList",
        @"app.mod.close.skinList"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity
{
    if ([msgKey isEqualToString:@"app.mod.show.skinList"])
    {
        UIView *parentView = [NTUnityInSDK shareInstance].sceneContextView;
        [[AZDressManager sharedInstance] showDressListViewInParentView:parentView];
        
//        [WXLog show:@"dress_home_show" params:nil];
    }
    else if ([msgKey isEqualToString:@"app.mod.close.skinList"])
    {
        [[AZDressManager sharedInstance] removeDressListView];
        
        // 关闭时，清一下SDWebImage的cache
        [[SDImageCache sharedImageCache] clearMemory];
    }
}


#pragma mark - Public Method

// 通知Unity换套装
+ (void)sendToUnityChangeSuit:(NSDictionary *)params
{
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:@"unity.mod.changeSuit" params:params callback:nil];
}

// 通知Unity换装扮, 单装扮换肤
+ (void)sendToUnityChangeDress:(NSDictionary *)params
{
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:@"unity.mod.changeSkin" params:params callback:nil];
}

@end
