//
//  EpicUnitySceneConfig.m
//  EpicUnityBridge
//

#import "EpicUnitySceneConfig.h"

@implementation EpicUnitySceneConfig

+ (NTUSceneConfig *)defaultConfig {
    NTUSceneConfig *config = [[NTUSceneConfig alloc] init];
    config.sceneLoadTimeoutDuration = 45;
    config.backBtnShouldHidden = YES;
    config.backgroundLoad = NO;
    return config;
}

@end
