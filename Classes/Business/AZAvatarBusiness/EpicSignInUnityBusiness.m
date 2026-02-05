//
//  EpicSignInUnityBusiness.m
//  EpicUnityBridge
//
//  Unity sign-in business plugin. Handles Unity messages related to sign-in flow.
//

#import "EpicSignInUnityBusiness.h"
#import "EpicAvatarSetManager.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import <NTUnityIn/NTUSDKMessageCenter.h>
#import <EpicUnityAdapter/EpicUnityAdapterManager.h>
#import <EpicUnityAdapter/EUAAuthProvider.h>

@interface EpicSignInUnityBusiness () <NTUSDKPluginDelegate>

@end

@implementation EpicSignInUnityBusiness

#pragma mark - NTUSDKPluginDelegate

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.login.show.skinList",
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    NSLog(@"[EpicSignInUnityBusiness] receivedUnityMsgKey: %@", msgKey);

    if ([msgKey isEqualToString:@"app.login.show.skinList"]) {
        UIView *parentView = [NTUnityInSDK shareInstance].sceneContextView;
        [[EpicAvatarSetManager sharedInstance] showAvatarListViewInParentView:parentView];
    }
}

#pragma mark - Send Messages to Unity

+ (void)sendNickNameSetSuccessfulMsgToUnity {
    id<EUAAuthProvider> authProvider = [EpicUnityAdapterManager sharedInstance].authProvider;
    NSString *nickName = @"";

    if ([authProvider respondsToSelector:@selector(currentUserName)]) {
        nickName = [authProvider currentUserName] ?: @"";
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"name"] = nickName;

    NSString *msg = @"unity.login.completion";
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:msg params:params callback:nil];

    NSLog(@"[EpicSignInUnityBusiness] sendNickNameSetSuccessfulMsgToUnity: %@", nickName);
}

+ (void)sendToUnityChange2DHeadPic:(NSDictionary *)params {
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:@"unity.personal.changehead" params:params callback:nil];
    NSLog(@"[EpicSignInUnityBusiness] sendToUnityChange2DHeadPic: %@", params);
}

+ (void)sendToUnityChangeHead:(NSDictionary *)params {
    NSString *msg = @"unity.login.changeSkin";
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:msg params:params callback:nil];
    NSLog(@"[EpicSignInUnityBusiness] sendToUnityChangeHead: %@", params);
}

+ (void)sendToUnityChangeFace:(NSDictionary *)params {
    NSString *msg = @"unity.login.changeFace";
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:msg params:params callback:nil];
    NSLog(@"[EpicSignInUnityBusiness] sendToUnityChangeFace: %@", params);
}

+ (void)sendToUnityCloseChangePersonal {
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:@"unity.api.personal.hide" params:@{} callback:nil];
    NSLog(@"[EpicSignInUnityBusiness] sendToUnityCloseChangePersonal");
}

@end
