//
//  AZDressManager.h
//  AZCommonBusiness
//
//  Created by leev on 2023/8/1.
//

/**
 * @desc 装扮管理类
 */

#import <Foundation/Foundation.h>

@interface AZDressManager : NSObject

/**
 * @desc 单例
 */
+ (instancetype)sharedInstance;


/**
 * @desc 展示装扮view
 */
- (void)showDressListViewInParentView:(UIView *)parentView;


/**
 * @desc 移除装扮view
 */
- (void)removeDressListView;

@end
