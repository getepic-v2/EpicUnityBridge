//
//  AZUserAvtarListView.h
//  AZSignIn
//
//  Created by leev on 2023/7/27.
//

#import <UIKit/UIKit.h>
#import "AZUserAvatarListModel.h"

@class AZUserAvtarListView;

@protocol AZUserAvtarListViewDelegate <NSObject>

- (void)userAvatarListView:(AZUserAvtarListView *)avatarListView didSelectAvater:(AZUserAvtarModel *)avatarModel;

- (void)userAvatarListView:(AZUserAvtarListView *)avatarListView
    didSelectPackageAvater:(AZUserAvtarModel *)avatarModel
                expression:(AZUserAvtarModel *)expressionModel;

- (void)userAvatarListView:(AZUserAvtarListView *)avatarListView
    confirmSelectedDressIds:(NSArray *)dressIds
                  headPicId:(NSNumber *)headPicId
                   nickName:(NSString *)nickName
               isRecommmend:(BOOL)isRecommend;

@end

@interface AZUserAvtarListView : UIView

@property(nonatomic, weak) id<AZUserAvtarListViewDelegate> delegate;

- (void)setupAvatarListModel:(AZUserAvatarListModel *)avatarListModel;

// 2D头像url
- (NSString *)selected2DHeadPicUrl;

// 设置账号互通提示
- (void)setAccountTip:(NSString *)text isShow:(BOOL)isShow;
@end
