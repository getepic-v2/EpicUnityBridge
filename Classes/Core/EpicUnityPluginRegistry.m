//
//  EpicUnityPluginRegistry.m
//  EpicUnityBridge
//

#import "EpicUnityPluginRegistry.h"
#import <NTUnityIn/NTUSDKMessageCenter.h>

// Plugins
#import "EpicDeviceInfoPlugin.h"
#import "EpicVibratePlugin.h"
#import "EpicUserDefaultsPlugin.h"
#import "EpicLoadingPlugin.h"
#import "EpicUserInfoPlugin.h"
#import "EpicInfoPlugin.h"

// SignIn Plugins
#import "EpicSignInUnityBusiness.h"


@implementation EpicUnityPluginRegistry

+ (void)registerPlugins {
    [[NTUSDKMessageCenter shareInstance] registerMsgPlugins:@[
        EpicDeviceInfoPlugin.class,
        EpicVibratePlugin.class,
        EpicUserDefaultsPlugin.class,
        EpicLoadingPlugin.class,
        EpicUserInfoPlugin.class,
        EpicInfoPlugin.class,
    ]];
}

+ (void)registerSignInPlugins {
    [[NTUSDKMessageCenter shareInstance] registerMsgPlugins:@[
        EpicSignInUnityBusiness.class,
    ]];
}
@end
