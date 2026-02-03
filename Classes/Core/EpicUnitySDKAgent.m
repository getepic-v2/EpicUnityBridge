//
//  EpicUnitySDKAgent.m
//  EpicUnityBridge
//
//  Middle layer agent for NTUnityInSDK delegate.
//

#import "EpicUnitySDKAgent.h"
#import "EpicPushManager.h"
#import <EpicUnityAdapter/EpicUnityAdapterManager.h>

@interface EpicUnitySDKAgent ()

@property (nonatomic, assign) BOOL sceneShown;
@property (nonatomic, assign) NTUSceneLoadStatus sceneLoadStatus;

@property (nonatomic, copy, nullable) NSString *sceneLoadSubCode;

@end

@implementation EpicUnitySDKAgent

+ (instancetype)sharedInstance {
    static EpicUnitySDKAgent *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - NTUnityInSDKDelegate

- (void)sceneLoadTimeOut:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnitySDKAgent] sceneLoadTimeOut: %@", sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneLoadTimeOut:sceneConfig:)]) {
        [self.delegate sceneLoadTimeOut:sceneId sceneConfig:config];
    }
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config kickOutReason:(NTUSceneKickOutReasonType)reasonType {
    NSLog(@"[EpicUnitySDKAgent] kickOutReason: %ld sceneId: %@", (long)reasonType, sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneId:sceneConfig:kickOutReason:)]) {
        [self.delegate sceneId:sceneId sceneConfig:config kickOutReason:reasonType];
    }
}

- (void)didReceivedFixClientAction:(NSString *)sceneId {
    NSLog(@"[EpicUnitySDKAgent] didReceivedFixClientAction: %@", sceneId);

    if ([self.delegate respondsToSelector:@selector(didReceivedFixClientAction:)]) {
        [self.delegate didReceivedFixClientAction:sceneId];
    }
}

- (void)didRequestConfigDataSuccessful:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config sceneData:(NSDictionary *)sceneData {
    NSLog(@"[EpicUnitySDKAgent] didRequestConfigDataSuccessful: %@", sceneId);

    // Extract IRC config from scene data
    NSDictionary *ircConfig = sceneData[@"IrcConfig"];
    NSString *appId = ircConfig[@"appId"];
    NSString *appKey = ircConfig[@"appKey"];

    // Initialize push service if not already configured
    if (![EpicPushManager sharedInstance].appId || ![EpicPushManager sharedInstance].appKey) {
        [EpicPushManager sharedInstance].appId = appId;
        [EpicPushManager sharedInstance].appKey = appKey;

        [EpicPushManager initTMSdk];
        [EpicPushManager startPushService];
        NSLog(@"[EpicUnitySDKAgent] initialized TMSdk and started push service with appId: %@", appId);
    } else if ([appId isEqualToString:[EpicPushManager sharedInstance].appId] &&
               [appKey isEqualToString:[EpicPushManager sharedInstance].appKey]) {
        // Same config, just rebind
        [EpicPushManager bindPushClientWhenLogin];
        NSLog(@"[EpicUnitySDKAgent] rebind push client with existing config");
    }

    // Forward to business delegate
    if ([self.delegate respondsToSelector:@selector(didRequestConfigDataSuccessful:sceneConfig:sceneData:)]) {
        [self.delegate didRequestConfigDataSuccessful:sceneId sceneConfig:config sceneData:sceneData];
    }
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config loadStatus:(NTUSceneLoadStatus)status subCode:(NSString *)subCode {
    NSLog(@"[EpicUnitySDKAgent] loadStatus: %ld subCode: %@ sceneId: %@", (long)status, subCode, sceneId);

    self.planId = sceneId;
    self.sceneLoadStatus = status;
    self.sceneLoadSubCode = subCode;

    if ([self.delegate respondsToSelector:@selector(sceneId:sceneConfig:loadStatus:subCode:)]) {
        [self.delegate sceneId:sceneId sceneConfig:config loadStatus:status subCode:subCode];
    }
    
    // Show Unity scene during SceneLoad phase for local mod
    if (status == NTUSceneLoadStatusSceneLoad && config.backgroundLoad) {
        if (subCode.floatValue > 100.0) {
            if (!self.sceneShown) {
                self.sceneShown = YES;

                // Show Unity window
                [[NTUnityInSDK shareInstance] showScene];
                NSLog(@"[EpicUnityBusinessData] showScene called (subCode: %@)", subCode);
            }
        }
    }

    // 本地 mod 加载完成时直接显示 Unity 场景
    if (status == NTUSceneLoadStatusComplete) {
        if (sceneId.length == 0) {
            [[NTUnityInSDK shareInstance] showScene];
        }
    }
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config loadError:(NTUnityInError *)error {
    NSLog(@"[EpicUnitySDKAgent] loadError: %@ sceneId: %@", error.errorDesc, sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneId:sceneConfig:loadError:)]) {
        [self.delegate sceneId:sceneId sceneConfig:config loadError:error];
    }
}

- (void)sceneLoadingVideoBeignPlay:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnitySDKAgent] sceneLoadingVideoBeignPlay: %@", sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneLoadingVideoBeignPlay:sceneConfig:)]) {
        [self.delegate sceneLoadingVideoBeignPlay:sceneId sceneConfig:config];
    }
}

- (void)sceneDidExit:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config {
    NSLog(@"[EpicUnitySDKAgent] sceneDidExit: %@", sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneDidExit:sceneConfig:)]) {
        [self.delegate sceneDidExit:sceneId sceneConfig:config];
    }
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config eventId:(NSString *)eventId eventParams:(NSDictionary *)params {
    // Forward analytics events
    id<EUAAnalyticsProvider> analytics = [EpicUnityAdapterManager sharedInstance].analyticsProvider;
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params ?: @{}];
    allParams[@"sceneId"] = sceneId ?: @"";
    [analytics trackEvent:eventId params:allParams];

    if ([self.delegate respondsToSelector:@selector(sceneId:sceneConfig:eventId:eventParams:)]) {
        [self.delegate sceneId:sceneId sceneConfig:config eventId:eventId eventParams:params];
    }
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config preference:(NSArray *)preference {
    NSLog(@"[EpicUnitySDKAgent] preference received for sceneId: %@", sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneId:sceneConfig:preference:)]) {
        [self.delegate sceneId:sceneId sceneConfig:config preference:preference];
    }
}

- (void)sceneId:(NSString *)sceneId gameId:(NSString *)gameId beginDownloadResource:(BOOL)cacheExist {
    NSLog(@"[EpicUnitySDKAgent] beginDownloadResource sceneId: %@ gameId: %@ cacheExist: %d", sceneId, gameId, cacheExist);

    if ([self.delegate respondsToSelector:@selector(sceneId:gameId:beginDownloadResource:)]) {
        [self.delegate sceneId:sceneId gameId:gameId beginDownloadResource:cacheExist];
    }
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config exceptionMessage:(NSString *)msg {
    NSLog(@"[EpicUnitySDKAgent] exceptionMessage: %@ sceneId: %@", msg, sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneId:sceneConfig:exceptionMessage:)]) {
        [self.delegate sceneId:sceneId sceneConfig:config exceptionMessage:msg];
    }
}

- (void)sceneId:(NSString *)sceneId sceneConfig:(NTUSceneConfig *)config exceptionWillExitApp:(NSString *)msg {
    NSLog(@"[EpicUnitySDKAgent] exceptionWillExitApp: %@ sceneId: %@", msg, sceneId);

    if ([self.delegate respondsToSelector:@selector(sceneId:sceneConfig:exceptionWillExitApp:)]) {
        [self.delegate sceneId:sceneId sceneConfig:config exceptionWillExitApp:msg];
    }
}

@end
