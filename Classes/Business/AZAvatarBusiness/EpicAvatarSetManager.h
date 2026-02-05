//
//  EpicAvatarSetManager.h
//  EpicUnityBridge
//
//  User avatar/appearance set manager.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicAvatarSetManager : NSObject

/// Singleton instance
+ (instancetype)sharedInstance;

/// Show avatar list view in parent view
- (void)showAvatarListViewInParentView:(UIView *)parentView;

/// Remove avatar list view
- (void)removeAvatarListView;

/// Request avatar info data from server
- (void)requestAvatarInfoData;

@end

NS_ASSUME_NONNULL_END
