//
//  EpicUnityBridge.h
//  EpicUnityBridge
//
//  Entry point for Unity scene integration in Epic app.
//  Replaces AZUnityBusinessMediator+Module.
//

#import <Foundation/Foundation.h>
#import <NTUnityIn/NTUnityInSDK.h>
#import <EpicUnityAdapter/EpicUnityAdapterProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicUnityBridge : NSObject <NTUnityInSDKDelegate>

+ (instancetype)sharedInstance;

+ (void)setupUnitySDK;

/// Initialize the NTUnityIn SDK. Call in AppDelegate didFinishLaunchingWithOptions.
/// @param appId Application ID for NTUnityIn
/// @param appSecret Application secret for NTUnityIn
/// @param environment Environment string (e.g. @"release", @"dev")
+ (void)setupSDKWithAppId:(NSString *)appId
                appSecret:(NSString *)appSecret
              environment:(NSString *)environment;

/// Load a Unity scene.
/// @param sceneId The scene identifier to load
- (void)loadSceneWithId:(NSString *)sceneId;

/// Load a Unity scene with custom config.
/// @param sceneId The scene identifier to load
/// @param config Custom scene configuration
- (void)loadSceneWithId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config;

/// Load a local Unity scene from a bundled zip resource.
/// @param zipName The zip file name in main bundle (without extension), e.g. @"signin_avatar"
/// @param modName The mod directory name inside the zip
- (void)loadLocalSceneWithZip:(NSString *)zipName modName:(NSString *)modName;

/// Show the Unity scene window (call after scene loaded successfully)
- (void)showScene;

/// Exit the current Unity scene
- (void)exitScene;

/// Whether Unity scene is currently active
- (BOOL)isSceneActive;

/// Called before entering Unity scene (e.g., to force landscape)
@property (nonatomic, copy, nullable) void (^willEnterSceneBlock)(void);
/// Called after exiting Unity scene (e.g., to restore portrait)
@property (nonatomic, copy, nullable) void (^didExitSceneBlock)(void);

/// Inject windowScene into Unity windows (call after scene loads under iOS 13+)
- (void)injectWindowSceneIfNeeded;

@end

NS_ASSUME_NONNULL_END
