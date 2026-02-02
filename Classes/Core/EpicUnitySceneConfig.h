//
//  EpicUnitySceneConfig.h
//  EpicUnityBridge
//
//  Default scene configuration for Epic app.
//  Replaces AZUnityBusinessManager.getDefaultSceneConfig.
//

#import <Foundation/Foundation.h>
#import <NTUnityIn/NTUSceneConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicUnitySceneConfig : NSObject

/// Default scene configuration with Epic branding
+ (NTUSceneConfig *)defaultConfig;

@end

NS_ASSUME_NONNULL_END
