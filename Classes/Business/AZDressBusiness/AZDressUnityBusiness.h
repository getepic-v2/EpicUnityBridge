//
//  AZDressUnityBusiness.h
//  AZCommonBusiness
//
//  Created by leev on 2023/8/1.
//

#import <Foundation/Foundation.h>

@interface AZDressUnityBusiness : NSObject

/**
 * @desc 通知Unity换套装
 */
+ (void)sendToUnityChangeSuit:(NSDictionary *)params;


/**
 * @desc 通知Unity换装扮，单装扮换肤
 */
+ (void)sendToUnityChangeDress:(NSDictionary *)params;

@end
