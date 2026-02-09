//
//  EpicUnityBusinessData.h
//  EpicUnityBridge
//
//  Business layer delegate for Unity scene callbacks.
//  Manages business data and loading view interactions.
//

#import <Foundation/Foundation.h>
#import <NTUnityIn/NTUnityInSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicUnityBusinessData : NSObject <NTUnityInSDKDelegate>

+ (instancetype)sharedInstance;

/// Current scene/plan ID
@property (nonatomic, copy, nullable) NSString *planId;

/// Whether this is the first scene load in current session
@property (nonatomic, assign) BOOL isFirstLoadScene;

//将此值置为YES可以使pause不出现全屏loading遮盖，注意每次pause都需要设置
@property (nonatomic, assign) BOOL pauseWithOutLoading;

/// Called before entering Unity scene (e.g., to force landscape)
@property (nonatomic, copy, nullable) void (^willEnterSceneBlock)(void);

/// Called after exiting Unity scene (e.g., to restore portrait)
@property (nonatomic, copy, nullable) void (^didExitSceneBlock)(void);

@end

NS_ASSUME_NONNULL_END
