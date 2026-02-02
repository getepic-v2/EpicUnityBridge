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

@end
