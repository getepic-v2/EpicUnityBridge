//
//  EpicUnitySceneConfig.m
//  EpicUnityBridge
//

#import "EpicUnitySceneConfig.h"

@implementation EpicUnitySceneConfig

+ (NTUSceneConfig *)defaultConfig {
    NTUSceneConfig *config = [[NTUSceneConfig alloc] init];
    config.sceneLoadTimeoutDuration = 45;
    config.backBtnShouldHidden = NO;
    config.backgroundLoad = NO;
    config.progressColor = [UIColor yellowColor];
    config.loadingBgImage = [UIImage imageNamed:@"az_common_bg_image.png"];
    config.progressImageFilePath = [[NSBundle mainBundle] pathForResource:@"az_duck_load_progress" ofType:@"gif"];
    config.errorImage = [UIImage imageNamed:@"common_error_icon"];
    
    return config;
}

@end
