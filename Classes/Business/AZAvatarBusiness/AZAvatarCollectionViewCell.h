//
//  AZAvatarCollectionViewCell.h
//  AZSignIn
//
//  Created by leev on 2023/7/27.
//

#import <UIKit/UIKit.h>
#import "AZUserAvtarModel.h"

@class AZAvatarCollectionViewCell;

@protocol AZAvatarCollectionViewCellDelegate <NSObject>

- (void)didSelectCell:(AZAvatarCollectionViewCell *)cell cellModel:(AZUserAvtarModel *)cellModel;

@end

@interface AZAvatarCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) AZUserAvtarModel *cellModel;

@property (nonatomic, weak) id<AZAvatarCollectionViewCellDelegate> delegate;

- (void)setupCellModel:(AZUserAvtarModel *)cellModel;

@end
