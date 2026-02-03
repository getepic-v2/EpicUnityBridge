//
//  EpicPushManager.h
//  EpicUnityBridge
//
//  Push service manager for Unity scene integration.
//  Manages IRC/Push service initialization and binding.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "EpicPushMessageEntity.h"

#if !TARGET_OS_SIMULATOR
#import <TALPush/PMPush.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - EpicPushMessageListener Protocol

@protocol EpicPushMessageListener <NSObject>

@required
/// Called when a transmission message is received
- (void)receivedTransmissionMessage:(EpicPushMessageEntity *)messageEntity;

@end

#pragma mark - EpicPushManager

#if !TARGET_OS_SIMULATOR
@interface EpicPushManager : NSObject <PMPushDelegate, UNUserNotificationCenterDelegate>
#else
@interface EpicPushManager : NSObject <UNUserNotificationCenterDelegate>
#endif

/// Singleton instance
+ (instancetype)sharedInstance;

/// IRC/Push app ID from scene config
@property (nonatomic, copy, nullable) NSString *appId;

/// IRC/Push app key from scene config
@property (nonatomic, copy, nullable) NSString *appKey;

/// Client ID for push service
@property (nonatomic, copy, nullable) NSString *clientId;

/// Start push service
+ (void)startPushService;

/// Stop push service
+ (void)stopPushService;

/// Bind push client when user logs in
+ (void)bindPushClientWhenLogin;

/// Initialize TMSdk (TalMsg SDK)
+ (void)initTMSdk;

#pragma mark - Listener Management

/// Add a push message listener (weak reference)
- (void)addListener:(id<EpicPushMessageListener>)listener;

/// Remove a push message listener
- (void)removeListener:(id<EpicPushMessageListener>)listener;

@end

NS_ASSUME_NONNULL_END
