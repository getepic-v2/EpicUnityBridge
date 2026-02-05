//
//  EpicSignInUnityBusiness.h
//  EpicUnityBridge
//
//  Unity sign-in business plugin. Handles Unity messages related to sign-in flow.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicSignInUnityBusiness : NSObject

#pragma mark - Send Messages to Unity

/// Notify Unity that nickname has been set successfully
+ (void)sendNickNameSetSuccessfulMsgToUnity;

/// Notify Unity to change 2D head picture
+ (void)sendToUnityChange2DHeadPic:(NSDictionary *)params;

/// Notify Unity to change head/hair style
+ (void)sendToUnityChangeHead:(NSDictionary *)params;

/// Notify Unity to change face (skin color and expression)
+ (void)sendToUnityChangeFace:(NSDictionary *)params;

/// Notify Unity to close personal info page
+ (void)sendToUnityCloseChangePersonal;

@end

NS_ASSUME_NONNULL_END
