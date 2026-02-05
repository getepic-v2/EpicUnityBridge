//
//  EpicUnityBridgeCore.m
//  EpicUnityBridge
//

#import "EpicUnityBridgeCore.h"
#import "EpicUnitySDKAgent.h"
#import "EpicUnitySceneConfig.h"
#import "EpicUnityBusinessData.h"
#import "EpicUnityPluginRegistry.h"
#import "EpicUnityLoadingManager.h"

#import <NTUnityIn/NTUZipArchive.h>
#import <NTUnityIn/NTUSDKMessageCenter.h>
#import <EpicUnityAdapter/EpicUnityAdapterManager.h>

@interface EpicUnityBridge ()

@property (nonatomic, strong, nullable) NSString *currentSceneId;

@end

@implementation EpicUnityBridge

+ (instancetype)sharedInstance {
    static EpicUnityBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EpicUnityBridge alloc] init];
    });
    return instance;
}

+ (void)setupUnitySDK {
    NTUnityInSDKConfig *config = [[NTUnityInSDKConfig alloc] init];

//    config.appId = @"50";
//    config.appSerect = @"2f4a6b8c0d2e4f6a8b0c2d4e6f8a0b2c4d6e8f0a2b4c5d6e7f8a9b0c1d2e3f4a";
//    config.envType = NTUSDKEnvTypeRelease;

    config.appId = @"20";
    config.appSerect = @"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    config.envType = NTUSDKEnvTypeTest;

    NTUnityInHostConfig *hostConfig = [[NTUnityInHostConfig alloc] init];
    hostConfig.host = @"https://math.chuangjing.com";
    hostConfig.hostTest = @"https://math-test.chuangjing.com";
    hostConfig.ircAppId = @"next20001";
    hostConfig.ircAppKey = @"ZjlmNjdlYjNhMjE3MDJiZg";
    hostConfig.ircAppIdTest = @"next10001";
    hostConfig.ircAppKeyTest = @"NjY1NTQzMjUyOWI5OTlkZg";

    [NTUnityInSDK SDKInitWithConfig:config];

    // Set EpicUnitySDKAgent as the SDK delegate (middle layer)
    [NTUnityInSDK shareInstance].delegate = [EpicUnitySDKAgent sharedInstance];
}

#pragma mark - Public Methods

- (void)loadSceneWithId:(NSString *)sceneId {
    [self loadSceneWithId:sceneId sceneConfig:[EpicUnitySceneConfig defaultConfig]];
}

- (void)loadSceneWithId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    // Set EpicUnityBusinessData as the business delegate
    [EpicUnitySDKAgent sharedInstance].delegate = [EpicUnityBusinessData sharedInstance];

    // Transfer callbacks to business data
    [EpicUnityBusinessData sharedInstance].didExitSceneBlock = self.didExitSceneBlock;
    [EpicUnityBusinessData sharedInstance].willEnterSceneBlock = self.willEnterSceneBlock;

    // Register plugins
    [[NTUnityInSDK shareInstance] exitScene];
    [EpicUnityPluginRegistry registerPlugins];

    self.currentSceneId = sceneId;
    NSString *userId = [[EpicUnityAdapterManager sharedInstance].authProvider currentUserId] ?: @"";
    [[NTUnityInSDK shareInstance] startSceneWithId:sceneId userId:userId config:config];
}

- (void)loadLocalSceneWithZip:(NSString *)zipName modName:(NSString *)modName {
    // Transfer callbacks to business data
    [EpicUnitySDKAgent sharedInstance].didExitSceneBlock = self.didExitSceneBlock;
    [EpicUnitySDKAgent sharedInstance].willEnterSceneBlock = self.willEnterSceneBlock;

    [[NTUnityInSDK shareInstance] exitScene];
    [EpicUnityPluginRegistry registerSignInPlugins];

    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *destDir = [docPath stringByAppendingPathComponent:@"UnityModTemp"];

    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:destDir]) {
        [fm removeItemAtPath:destDir error:nil];
    }
    [fm createDirectoryAtPath:destDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *zipPath = [[NSBundle mainBundle] pathForResource:zipName ofType:@"zip"];
    if (!zipPath) {
        NSLog(@"[EpicUnityBridge] zip resource not found: %@.zip", zipName);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [NTUZipArchive unzipFileAtPath:zipPath toDestination:destDir];
        NSLog(@"[EpicUnityBridge] unzip %@: %@", zipName, success ? @"success" : @"failed");

        if (!success) return;

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *scienceMainPath = [destDir stringByAppendingPathComponent:@"Science_Main"];
            NSString *frameworkPath = [destDir stringByAppendingPathComponent:@"framework"];
            NSString *modPath = [destDir stringByAppendingPathComponent:modName];

            NSDictionary *resourceInfo = @{
                @"Science_Main": scienceMainPath,
                @"framework": frameworkPath,
                modName: modPath
            };

            NSDictionary *params = @{
                @"Uuid": @"epic_test",
                @"Info": @{
                    @"roomId": @"#epicLocalTest",
                    @"userId": @"10086",
                    @"nickName": @"epic_test",
                    @"liveId": @"-1",
                    @"ModName": modName
                },
                @"ModName": modName,
                @"sync_type": @2,
                @"Token": @"{}"
            };

            NTUSceneConfig *config = [[NTUSceneConfig alloc] init];
            config.backgroundLoad = YES;
            config.backBtnShouldHidden = NO;

            self.currentSceneId = modName;
            [[NTUnityInSDK shareInstance] startLocalSceneWithResourceInfo:resourceInfo
                                                                   parms:params
                                                                  config:config];

            NSLog(@"[EpicUnityBridge] startLocalScene with mod: %@", modName);
        });
    });
}

- (void)showScene {
    [[NTUnityInSDK shareInstance] showScene];
}

- (void)exitScene {
    [[NTUnityInSDK shareInstance] exitScene];
    self.currentSceneId = nil;
}

- (BOOL)isSceneActive {
    return [[NTUnityInSDK shareInstance] sceneIn];
}

@end
