//
//  EpicUnityBridge.m
//  EpicUnityBridge
//

#import "EpicUnityBridge.h"
#import "EpicUnityPluginRegistry.h"
#import "EpicUnitySceneConfig.h"
#import <EpicUnityAdapter/EpicUnityAdapterManager.h>
#import <NTUnityIn/NTUSDKMessageCenter.h>
#import <NTUnityIn/NTUZipArchive.h>

@interface EpicUnityBridge ()

@property (nonatomic, strong, nullable) NSString *currentSceneId;
@property (nonatomic, assign) BOOL localSceneLoadSuccess;
@property (nonatomic, assign) BOOL shouldShowWhenLoaded;

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

+ (void)setupUnitySDK
{
    NTUnityInSDKConfig *config = [[NTUnityInSDKConfig alloc] init];
    
//    config.appId = @"50";
//    config.appSerect = @"2f4a6b8c0d2e4f6a8b0c2d4e6f8a0b2c4d6e8f0a2b4c6d8e0f2a4b6c8d0e2f4a";
//    config.envType = NTUSDKEnvTypeRelease;
    
    config.appId = @"50";
    config.appSerect = @"7f8a9b2c3d4e5f6a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a";
    config.envType = NTUSDKEnvTypeTest;
    
    NTUnityInHostConfig *hostConfig = [[NTUnityInHostConfig alloc]init];
    hostConfig.host = @"https://science.chuangjing.com";
    hostConfig.hostTest = @"https://science-test.chuangjing.com";
    hostConfig.ircAppId = @"next20001";
    hostConfig.ircAppKey = @"ZjlmNjdlYjNhMjE3MDJiZg";
    hostConfig.ircAppIdTest = @"next10001";
    hostConfig.ircAppKeyTest = @"NjY1NTQzMjUyOWI5OTlkZg";
    
    [NTUnityInSDK SDKInitWithConfig:config];
    [NTUnityInSDK shareInstance].delegate = [EpicUnityBridge sharedInstance];
}

+ (void)setupSDKWithAppId:(NSString *)appId
                appSecret:(NSString *)appSecret
              environment:(NSString *)environment {
    NTUnityInSDKConfig *config = [[NTUnityInSDKConfig alloc] init];
    config.appId = appId;
    config.appSerect = appSecret;
    config.envType = NTUSDKEnvTypeTest;
    
    NTUnityInHostConfig *hostConfig = [[NTUnityInHostConfig alloc]init];
    hostConfig.host = @"https://science.chuangjing.com";
    hostConfig.hostTest = @"https://science-test.chuangjing.com";
    hostConfig.ircAppId = @"next20001";
    hostConfig.ircAppKey = @"ZjlmNjdlYjNhMjE3MDJiZg";
    hostConfig.ircAppIdTest = @"next10001";
    hostConfig.ircAppKeyTest = @"NjY1NTQzMjUyOWI5OTlkZg";
    
    [NTUnityInSDK SDKInitWithConfig:config];
    [NTUnityInSDK shareInstance].delegate = [EpicUnityBridge sharedInstance];
}

- (void)loadSceneWithId:(NSString *)sceneId {
    [self loadSceneWithId:sceneId sceneConfig:[EpicUnitySceneConfig defaultConfig]];
}

- (void)loadSceneWithId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    self.currentSceneId = sceneId;

    // Register business plugins
    [EpicUnityPluginRegistry registerPlugins];

    // Get userId from auth provider
    NSString *userId = [[EpicUnityAdapterManager sharedInstance].authProvider currentUserId] ?: @"";

    // Start scene
    [[NTUnityInSDK shareInstance] startSceneWithId:sceneId userId:userId config:config];
}

- (void)loadLocalSceneWithZip:(NSString *)zipName modName:(NSString *)modName {
    self.localSceneLoadSuccess = NO;
    self.shouldShowWhenLoaded = YES;

    // Exit any current scene
    [[NTUnityInSDK shareInstance] exitScene];

    // Register plugins
    [EpicUnityPluginRegistry registerPlugins];

    // Unzip to Documents/UnityModTemp
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

    // Unzip on background thread then load scene on main thread
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
            config.backBtnShouldHidden = YES;

            self.currentSceneId = modName;
            [[NTUnityInSDK shareInstance] startLocalSceneWithResourceInfo:resourceInfo
                                                                   parms:params
                                                                  config:config];

            // Ensure app window stays on top during background load
            [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelNormal;

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
    self.localSceneLoadSuccess = NO;
    self.shouldShowWhenLoaded = NO;
}

- (BOOL)isSceneActive {
    return [[NTUnityInSDK shareInstance] sceneIn];
}

- (void)injectWindowSceneIfNeeded {
    // Get the current windowScene from the app's key window
    UIWindowScene *windowScene = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
            windowScene = (UIWindowScene *)scene;
            break;
        }
    }

    if (!windowScene) return;

    // Inject windowScene into all windows that don't have one (Unity window, loading window)
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (!window.windowScene) {
            window.windowScene = windowScene;
        }
    }
}

#pragma mark - NTUnityInSDKDelegate

- (void)sceneLoadTimeOut:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnityBridge] ⚠️ sceneLoadTimeOut: %@", sceneId);
    // Don't exit on timeout for local scene — let it keep trying
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config kickOutReason:(NTUSceneKickOutReasonType)reasonType {
    NSLog(@"[EpicUnityBridge] ⚠️ kickOutReason: %ld sceneId: %@", (long)reasonType, sceneId);
    [self exitScene];
}

- (void)didReceivedFixClientAction:(NSString *)sceneId {
    NSLog(@"[EpicUnityBridge] ⚠️ didReceivedFixClientAction: %@", sceneId);
    [self exitScene];
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config loadStatus:(NTUSceneLoadStatus)status subCode:(NSString *)subCode {
    NSLog(@"[EpicUnityBridge] loadStatus: %ld subCode: %@ sceneId: %@", (long)status, subCode, sceneId);

    // Inject windowScene at every status change
    [self injectWindowSceneIfNeeded];

    // Scene loaded successfully
    if (status == NTUSceneLoadStatusComplete) {
        self.localSceneLoadSuccess = YES;
        NSLog(@"[EpicUnityBridge] ✅ scene load complete");

        if (self.shouldShowWhenLoaded) {
            self.shouldShowWhenLoaded = NO;

            // Force landscape before showing
            if (self.willEnterSceneBlock) {
                self.willEnterSceneBlock();
            }

            // Show Unity scene and raise its window above app window
            [[NTUnityInSDK shareInstance] showScene];
            [self bringUnityWindowToFront];

            // SDK may reset window levels after showScene, so retry
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self bringUnityWindowToFront];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self bringUnityWindowToFront];
            });

            NSLog(@"[EpicUnityBridge] showScene called");
        }
    }
}

- (void)bringUnityWindowToFront {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        NSLog(@"[EpicUnityBridge] window: %@ level: %.0f hidden: %d keyWindow: %d",
              NSStringFromClass([window class]), window.windowLevel, window.isHidden, window.isKeyWindow);
    }

    // Find NTUnityWindow and raise it above EpicWindow
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        NSString *className = NSStringFromClass([window class]);
        if ([className containsString:@"Unity"] || [className containsString:@"NTU"]) {
            window.windowLevel = UIWindowLevelNormal + 1;
            window.hidden = NO;
            [window makeKeyAndVisible];
            NSLog(@"[EpicUnityBridge] raised unity window: %@ to level: %.0f", className, window.windowLevel);
        }
    }
    // Lower the app window
    [UIApplication sharedApplication].delegate.window.windowLevel = UIWindowLevelNormal - 1;
}

- (void)sceneDidExit:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnityBridge] sceneDidExit: %@", sceneId);
    self.currentSceneId = nil;

    // Restore orientation and main window
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didExitSceneBlock) {
            self.didExitSceneBlock();
        }

        // Reset all window levels back to normal and restore app window
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            window.windowLevel = UIWindowLevelNormal;
        }
        UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
        [appWindow makeKeyAndVisible];
    });
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config eventId:(NSString *)eventId eventParams:(NSDictionary *)params {
    NSLog(@"[EpicUnityBridge] event: %@ params: %@", eventId, params);
    id<EUAAnalyticsProvider> analytics = [EpicUnityAdapterManager sharedInstance].analyticsProvider;
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params ?: @{}];
    allParams[@"sceneId"] = sceneId ?: @"";
    [analytics trackEvent:eventId params:allParams];
}

@end
