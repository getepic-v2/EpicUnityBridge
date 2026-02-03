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

@end

NS_ASSUME_NONNULL_END
