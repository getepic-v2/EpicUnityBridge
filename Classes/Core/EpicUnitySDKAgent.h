//
//  EpicUnitySDKAgent.h
//  EpicUnityBridge
//
//  Middle layer agent for NTUnityInSDK delegate.
//  Handles common logic and forwards to business-specific delegate.
//

#import <Foundation/Foundation.h>
#import <NTUnityIn/NTUnityInSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicUnitySDKAgent : NSObject <NTUnityInSDKDelegate>

+ (instancetype)sharedInstance;

/// Business delegate - receives forwarded callbacks
@property (nonatomic, weak, nullable) id<NTUnityInSDKDelegate> delegate;

/// Current plan/scene ID
@property (nonatomic, copy, nullable) NSString *planId;

/// Called before entering Unity scene (e.g., to force landscape)
@property (nonatomic, copy, nullable) void (^willEnterSceneBlock)(void);

/// Called after exiting Unity scene (e.g., to restore portrait)
@property (nonatomic, copy, nullable) void (^didExitSceneBlock)(void);

@end

NS_ASSUME_NONNULL_END
