//
//  AZDressListView.m
//  NTHome
//
//  Created by leev on 2023/3/30.
//

#import "AZDressListView.h"
#import <WXToolKit/WXToolKit.h>
#import "AZDressCollectionCell.h"

#define kClassifyViewWidth                                  150
#define kClassifyViewHeight                                 32

// collectionView.headerView的高度
#define kCollectionHeaderViewWidth                          26
#define kCollectionHeaderViewHeight                         36


// cell的宽高
#define kCollectionViewCellWidth                            (IS_IPAD ? 88 * 1.25 : 88)
#define kCollectionViewCellHeight                           (IS_IPAD ? 108 * 1.25 : 108)

// cell之间的间距
#define kCellLineSpacing                                    0
#define kCellInteritemSpacing                               0

#define kLeftOrRightSpacing                                 3

@interface AZDressListView () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_dressModelArray;
    AZDressModelType _dressType;
    AZDressModel *_lastUsedDressModel;
}

@property (nonatomic, strong) UIView *classifyView; //分类view

@property (nonatomic, strong) UIImageView *classifyImageView;

@property (nonatomic, strong) UILabel *classifyNameLabel;

@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end

@implementation AZDressListView

#pragma mark - Override

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _lastUsedDressModel = nil;
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Public Method

// 当前view的宽度度
+ (CGFloat)viewWidth
{
    return ceill(kCollectionViewCellWidth) * 3 + kCellInteritemSpacing * 2 + kLeftOrRightSpacing*3;
}

// 分类view的高度
+ (CGFloat)classifyViewWidth
{
    return kClassifyViewHeight;
}

- (void)setupDressModelArray:(NSMutableArray *)dressModelArray dressType:(AZDressModelType)dressType
{
    _dressModelArray = dressModelArray;
    _dressType = dressType;
    _lastUsedDressModel = nil;
    
    // 找到当前使用的状态model
    [self findUsedDressModel];
    
    self.classifyImageView.image = [UIImage imageNamed:[self getClassifyImageName]];
    self.classifyNameLabel.text = [self getClassifyName];
    [self.collectionView reloadData];
}

//  刷新
- (void)reloadWithUsedDressModel:(AZDressModel *)dressModel
{
    _lastUsedDressModel.isUsed = NO;
    dressModel.isUsed = YES;
    [self.collectionView reloadData];
    
    _lastUsedDressModel = dressModel;
}


#pragma mark - Private Method

- (NSString *)getClassifyImageName
{
    NSString *imageName = @"";
    if (_dressType == AZDressModelTypeHead)
    {
        return @"az_dress_header_icon";
    }
    else if (_dressType == AZDressModelTypeUpperClothing)
    {
        return @"az_dress_upper_icon";
    }
    else if (_dressType == AZDressModelTypeLowerClothing)
    {
        return @"az_dress_lower_icon";
    }
    else if (_dressType == AZDressModelTypeSuit)
    {
        return @"az_dress_suit_icon";
    }
    else if (_dressType == AZDressModelTypeBackDesc)
    {
        return @"az_dress_back_icon";
    }
    else if (_dressType == AZDressModelTypeWaistDesc)
    {
        return @"az_dress_waist_icon";
    }
    else if (_dressType == AZDressModelTypeHeadDec)
    {
        return @"az_dress_head_desc_icon";
    }
    
    return imageName;
}

- (NSString *)getClassifyName
{
    NSString *title = @"";
    if (_dressType == AZDressModelTypeHead)
    {
        return @"头部";
    }
    else if (_dressType == AZDressModelTypeUpperClothing)
    {
        return @"上装";
    }
    else if (_dressType == AZDressModelTypeLowerClothing)
    {
        return @"下装";
    }
    else if (_dressType == AZDressModelTypeSuit)
    {
        return @"套装";
    }
    else if (_dressType == AZDressModelTypeBackDesc)
    {
        return @"背部饰品";
    }
    else if (_dressType == AZDressModelTypeWaistDesc)
    {
        return @"腰部饰品";
    }
    else if (_dressType == AZDressModelTypeHeadDec)
    {
        return @"头部饰品";
    }
    
    return title;
}

// 找到当前使用的状态model
- (void)findUsedDressModel
{
    for (AZDressModel *dressModel in _dressModelArray)
    {
        if (dressModel.isUsed)
        {
            _lastUsedDressModel = dressModel;
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dressModelArray.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    AZDressModel *cellModel = [_dressModelArray wx_objectAtIndex:indexPath.row];
    
    AZDressCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AZDressCollectionCell class]) forIndexPath:indexPath];
    [cell setupCellModel:cellModel];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AZDressModel *cellModel = [_dressModelArray wx_objectAtIndex:indexPath.row];
    cellModel.isNew = NO;
    
    // 如果是限时皮肤 且 已过期，则直接return
    if (cellModel.isLimitTime && cellModel.isExpired)
    {
        return;;
    }
    
    // 已装扮&不可拆卸 or 未拥有 直接return
    if ((cellModel.isUsed && !cellModel.canInvert) || !cellModel.isOwned)
    {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dressListView:didSelectDressModel:)])
    {
        [self.delegate dressListView:self didSelectDressModel:cellModel];
    }
}

#pragma mark - Private Method

- (void)setupSubviews
{
    // 添加之前先置空
    [self wx_removeAllSubviews];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.wx_width, self.wx_height)];
//    imageView.image = [[UIImage imageNamed:@"dress_view_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:100];
    [self addSubview:imageView];
    [self addSubview:self.classifyView];
    [self addSubview:self.collectionView];
}


#pragma mark - Getter

- (UICollectionView *)collectionView
{
    if (_collectionView == nil)
    {
        CGFloat x = kLeftOrRightSpacing;
        CGFloat y = self.classifyView.wx_bottom;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(ceill(kCollectionViewCellWidth), ceill(kCollectionViewCellHeight));
        flowLayout.minimumLineSpacing = kCellLineSpacing;
        flowLayout.minimumInteritemSpacing = kCellInteritemSpacing  ;
        flowLayout.sectionInset = UIEdgeInsetsMake(9, 0, 0, 0);

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, y, self.wx_width-(2*x), self.wx_height-y) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 31, 0);

        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;

        [_collectionView registerClass:[AZDressCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([AZDressCollectionCell class])];
    }
    return _collectionView;
}

- (UIView *)classifyView
{
    if (_classifyView == nil)
    {
        _classifyView = [[UIView alloc] initWithFrame:CGRectMake(kLeftOrRightSpacing, 0, kClassifyViewWidth, kClassifyViewHeight)];
        _classifyView.backgroundColor = [UIColor clearColor];
        
        {
            CGFloat width = 24;
            CGFloat height = 24;
            CGFloat x = 0;
            CGFloat y = (kClassifyViewHeight - height) / 2;
            _classifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            [_classifyView addSubview:_classifyImageView];
        }
                
        {
            _classifyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_classifyImageView.wx_right, 0, kClassifyViewWidth - _classifyImageView.wx_width, kClassifyViewHeight)];
            _classifyNameLabel.textAlignment = NSTextAlignmentLeft;
            _classifyNameLabel.textColor = [UIColor wx_colorWithHEXValue:0xffffff];
            _classifyNameLabel.font = [UIFont wx_fontPingFangSCWithSize:12];
            [_classifyView addSubview:_classifyNameLabel];
        }
    }
    return _classifyView;
}

@end

