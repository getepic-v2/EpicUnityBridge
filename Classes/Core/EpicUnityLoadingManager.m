//
//  EpicUnityLoadingManager.m
//  EpicUnityBridge
//

#import "EpicUnityLoadingManager.h"
#import <NTUnityIn/NTUnityInSDK.h>

@interface EpicUnityLoadingManager ()

@property (nonatomic, strong) NSMutableArray<UIView *> *customViews;

@end

@implementation EpicUnityLoadingManager

+ (instancetype)sharedManager {
    static EpicUnityLoadingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _customViews = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods

- (void)configLoadingVideoUrl:(NSString *)videoUrl {
    if (videoUrl.length > 0) {
        [[NTUnityInSDK shareInstance] configSceneLoadVideoUrl:videoUrl];
        NSLog(@"[EpicUnityLoadingManager] configured loading video: %@", videoUrl);
    }
}

- (void)addCustomLoadingView:(UIView *)view {
    UIView *contextView = self.loadingContextView;
    if (contextView && view) {
        [contextView addSubview:view];
        [self.customViews addObject:view];
        NSLog(@"[EpicUnityLoadingManager] added custom view to loading context");
    }
}

- (void)removeCustomLoadingViews {
    for (UIView *view in self.customViews) {
        [view removeFromSuperview];
    }
    [self.customViews removeAllObjects];
    NSLog(@"[EpicUnityLoadingManager] removed all custom views");
}

- (void)sceneLoadSuccessful {
    [self removeCustomLoadingViews];
    NSLog(@"[EpicUnityLoadingManager] scene load successful");
}

- (void)sceneLoadError {
    [self removeCustomLoadingViews];
    NSLog(@"[EpicUnityLoadingManager] scene load error");
}

#pragma mark - Getters

- (UIView *)loadingContextView {
    return [NTUnityInSDK shareInstance].loadingContextView;
}

@end
