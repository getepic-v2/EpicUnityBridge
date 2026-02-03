//
//  EpicUnityLoadingManager.h
//  EpicUnityBridge
//
//  Custom loading manager for Unity scenes.
//  Can configure custom loading video, images, and views.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicUnityLoadingManager : NSObject

+ (instancetype)sharedManager;

/// Configure custom loading video URL
/// @param videoUrl URL string for the loading video (local or remote)
- (void)configLoadingVideoUrl:(nullable NSString *)videoUrl;

/// Add custom view to loading context
/// @param view Custom view to add
- (void)addCustomLoadingView:(UIView *)view;

/// Remove all custom loading views
- (void)removeCustomLoadingViews;

/// Called when scene load is successful
- (void)sceneLoadSuccessful;

/// Called when scene load fails
- (void)sceneLoadError;

/// The container view for custom loading content (from SDK)
@property (nonatomic, readonly, nullable) UIView *loadingContextView;

@end

NS_ASSUME_NONNULL_END
