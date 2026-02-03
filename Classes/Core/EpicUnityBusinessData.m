//
//  EpicUnityBusinessData.m
//  EpicUnityBridge
//
//  Business layer delegate for Unity scene callbacks.
//

#import "EpicUnityBusinessData.h"
#import "EpicUnityLoadingManager.h"
#import <NTUnityIn/NTUnityInSDK.h>

@interface EpicUnityBusinessData ()


@end

@implementation EpicUnityBusinessData

+ (instancetype)sharedInstance {
    static EpicUnityBusinessData *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isFirstLoadScene = YES;
    }
    return self;
}

#pragma mark - NTUnityInSDKDelegate

- (void)sceneLoadTimeOut:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnityBusinessData] sceneLoadTimeOut: %@", sceneId);
    [[EpicUnityLoadingManager sharedManager] sceneLoadError];
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config kickOutReason:(NTUSceneKickOutReasonType)reasonType {
    NSLog(@"[EpicUnityBusinessData] kickOutReason: %ld sceneId: %@", (long)reasonType, sceneId);
}

- (void)didReceivedFixClientAction:(NSString *)sceneId {
    NSLog(@"[EpicUnityBusinessData] didReceivedFixClientAction: %@", sceneId);
}

- (void)didRequestConfigDataSuccessful:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config sceneData:(NSDictionary *)sceneData {
    NSLog(@"[EpicUnityBusinessData] didRequestConfigDataSuccessful: %@", sceneId);
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config loadError:(NTUnityInError *)error {
    NSLog(@"[EpicUnityBusinessData] loadError: %@ sceneId: %@", error.errorDesc, sceneId);
    [[EpicUnityLoadingManager sharedManager] sceneLoadError];
}

- (void)sceneId:(NSString *)sceneId gameId:(NSString *)gameId beginDownloadResource:(BOOL)cacheExist {
    NSLog(@"[EpicUnityBusinessData] beginDownloadResource sceneId: %@ gameId: %@ cacheExist: %d", sceneId, gameId, cacheExist);

    // Configure custom loading here if needed
    // Example: [[EpicUnityLoadingManager sharedManager] configLoadingVideoUrl:@"your_video_url"];
}

- (void)sceneLoadingVideoBeignPlay:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnityBusinessData] sceneLoadingVideoBeignPlay: %@", sceneId);

    // Show custom loading view if needed
    // Example: [[EpicUnityLoadingManager sharedManager] showCustomLoadingView];
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config loadStatus:(NTUSceneLoadStatus)status subCode:(NSString *)subCode {
    NSLog(@"[EpicUnityBusinessData] loadStatus: %ld subCode: %@ sceneId: %@", (long)status, subCode, sceneId);

    self.planId = sceneId;

    // Scene load complete
    if (status == NTUSceneLoadStatusComplete) {
        // Mark as not first load after successful load (for non-local scenes)
        if (self.planId.length > 0) {
            _isFirstLoadScene = NO;
        }

        [[EpicUnityLoadingManager sharedManager] sceneLoadSuccessful];
        NSLog(@"[EpicUnityBusinessData] scene load complete");
    }
}

- (void)sceneDidExit:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnityBusinessData] sceneDidExit: %@", sceneId);

    self.planId = nil;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didExitSceneBlock) {
            self.didExitSceneBlock();
        }

        // Restore app window
        UIWindow *appWindow = [UIApplication sharedApplication].delegate.window;
        [appWindow makeKeyAndVisible];
    });
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config preference:(NSArray *)preference {
    NSLog(@"[EpicUnityBusinessData] preference received for sceneId: %@", sceneId);
}

@end
