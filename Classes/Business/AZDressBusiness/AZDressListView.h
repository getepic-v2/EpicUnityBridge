//
//  AZDressListView.h
//  NTHome
//
//  Created by leev on 2023/3/30.
//

#import <UIKit/UIKit.h>
#import "AZDressListModel.h"
#import "AZDressModel.h"

@class AZDressListView;
@protocol AZDressListViewDelegate <NSObject>

// 选中了装扮
- (void)dressListView:(AZDressListView *)listView didSelectDressModel:(AZDressModel *)dressModel;

@end

@interface AZDressListView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, weak) id<AZDressListViewDelegate> delegate;

/**
 * @desc 当前view的宽度
 */
+ (CGFloat)viewWidth;


/**
 * @desc 分类view的高度
 */
+ (CGFloat)classifyViewWidth;



/**
 * @desc datasource设置
 */
- (void)setupDressModelArray:(NSMutableArray *)dressModelArray dressType:(AZDressModelType)dressType;


/**
 * @desc  刷新
 *
 *  @param dressModel 当前选中的dressModel
 */
- (void)reloadWithUsedDressModel:(AZDressModel *)dressModel;

@end
