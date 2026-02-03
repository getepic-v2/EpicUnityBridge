//
//  EpicUnityPluginRegistry.h
//  EpicUnityBridge
//
//  Plugin registration hub. Replaces AZUnityBusinessManager.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicUnityPluginRegistry : NSObject

/// Register all Epic business plugins with NTUnityIn message center
+ (void)registerPlugins;

+ (void)registerSignInPlugins;

@end

NS_ASSUME_NONNULL_END
