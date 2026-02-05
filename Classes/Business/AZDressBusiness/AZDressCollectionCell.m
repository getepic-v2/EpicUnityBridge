//
//  AZDressCollectionCell.m
//  AZCommonBusiness
//
//  Created by leev on 2023/8/1.
//

#import "AZDressCollectionCell.h"

// 选中态
#define kDressSelectedImageName                             @"az_dress_selected_cover"

// 装扮数量image
#define kDressNumImageName                                  @"az_dress_num_img"

//  套装占位image
#define kDressSuitPlaceholderImageName                      @"az_dress_type_suit_bg"
// 头部占位image
#define kDressHeadPlaceholderImageName                      @"az_dress_type_head_bg"
// 上装占位image
#define kDressUpperClothingPlaceholderImageName             @"az_dress_type_upper_bg"
// 下装占位image
#define kDressLowerClothingPlaceholderImageName             @"az_dress_type_lower_bg"

// 红点
#define kRedPointViewWidth                                  8

@interface AZDressCollectionCell ()
{
    AZDressModel *_cellModel;
}

@property (nonatomic, strong) UIImageView *selectedImageView; //选中态imageView

@property (nonatomic, strong) UIImageView *coverImageView; //封面imageView

@property (nonatomic, strong) UIImageView *levelImageView; //levelImageView 目前分为普通、稀有和传说

//@property (nonatomic, strong) UIImageView *limitTimeImageView; //限时imageView;

@property (nonatomic, strong) YYLabel *leftTimeLabel; //限时皮肤剩余时间label

@property (nonatomic, strong) UIView *expiredMaskView; //过期蒙层

@property (nonatomic, strong) UIView *redPointView; //红点view

@property (nonatomic, strong) UILabel *dressNameLabel; //装扮名称label

@property (nonatomic, strong) UIImageView *dressNumImageView; //装扮数量imgView

@property (nonatomic, strong) UILabel *dressNumLabel; //装扮数量label

@property (nonatomic, strong) UIImageView *dressAttrImageView; //皮肤属性展示（限时、限定、隐藏）

@end

@implementation AZDressCollectionCell

#pragma mark - Override

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSubviews];
    }
    return self;
}

#pragma mark - Public Method

- (void)setupCellModel:(AZDressModel *)cellModel
{
    _cellModel = cellModel;
    
    // 是否已选中
    self.selectedImageView.hidden = !_cellModel.isUsed;
    
    // 是否已拥有
    self.levelImageView.hidden = !_cellModel.isOwned;
    
    // 限时标签是否展示
    //self.limitTimeImageView.hidden = !_cellModel.isLimitTime;
    
    // 过期时间标签是否展示，时间标签和数量互斥
    self.leftTimeLabel.hidden = !_cellModel.isLimitTime;
    
    if (_cellModel.isLimitTime)
    {
        [self setLeftTimeAttributedStr:[self getLeftTimeStr]];
    }
    
    // 是限时皮肤且已过期，则展示蒙层
    if (_cellModel.isLimitTime && _cellModel.isExpired)
    {
//        self.expiredMaskView.hidden = NO;
//        
//        self.expiredMaskView.layer.opacity = 0.5;
        self.levelImageView.layer.opacity = 0.6;
        //self.limitTimeImageView.layer.opacity = 0.6;
        self.leftTimeLabel.layer.opacity = 0.6;
        self.contentView.layer.opacity = 0.6;
    }
    else
    {
//        self.expiredMaskView.hidden = YES;
        
        self.levelImageView.layer.opacity = 1;
        //self.limitTimeImageView.layer.opacity = 1;
        self.leftTimeLabel.layer.opacity = 1;
        self.contentView.layer.opacity = 1;
    }
    // 装扮数量展示
    NSString *dressNumStr = [NSString stringWithFormat:@"%ld", _cellModel.dressNumber];
    if (_cellModel.dressNumber > 99)
    {
        // 大于99件则展示99+
        dressNumStr = @"99+";
        if (IS_IPAD)
        {
            self.dressNumLabel.font = [UIFont wx_fontPingFangSCSemiboldWithSize:8];
        }
        else
        {
            self.dressNumLabel.font = [UIFont wx_fontPingFangSCSemiboldWithSize:7];
        }
    }
    else
    {
        self.dressNumLabel.font = [UIFont wx_fontPingFangSCSemiboldWithSize:10];
    }
    
    self.dressNumLabel.text = dressNumStr;
    
    // 已拥有 且 非限制皮肤，则不隐藏
    if (_cellModel.isOwned && !_cellModel.isLimitTime)
    {
        self.dressNumLabel.hidden = NO;
        self.dressNumImageView.hidden = NO;
    }
    else
    {
        self.dressNumLabel.hidden = YES;
        self.dressNumImageView.hidden = YES;
    }
    
    // 是否是最新
    self.redPointView.hidden = !_cellModel.isNew;
    
    self.dressNameLabel.text = _cellModel.dressName;
    self.dressNameLabel.hidden = !_cellModel.isOwned;
    
    //展示 “限时”“限定”“隐藏”图标
    [self.dressAttrImageView sd_cancelCurrentImageLoad];
    if (_cellModel.dressAttrUrl && _cellModel.dressAttrUrl.length > 0) {
        self.dressAttrImageView.hidden = NO;
        [self.dressAttrImageView sd_setImageWithURL:[NSURL URLWithString:_cellModel.dressAttrUrl]];
    } else {
        self.dressAttrImageView.hidden = YES;
    }
    
    [self.coverImageView sd_cancelCurrentImageLoad];
    // 封面展示
    if (_cellModel.isOwned)
    {
        // 已获得
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:_cellModel.dressCoverUrl]];
        
        NSString *levelImageName = @"";
        
        switch (_cellModel.levelType) {
            case AZDressLevelTypeNormal:
            {
                levelImageName = @"az_dress_normallevel_bg";
            }
                break;
            case AZDressLevelTypeHigh:
            {
                levelImageName = @"az_dress_highlevel_bg";
            }
                break;
            case AZDressLevelTypeRare:
            {
                levelImageName = @"az_dress_rarelevel_bg";
            }
                break;
            case  AZDressLevelTypeLegend:
            {
                levelImageName = @"az_dress_legendlevel_bg";
            }
                break;
            case  AZDressLevelTypeMyth:
            {
                levelImageName = @"az_dress_mythlevel_bg";
            }
                break;
            default:
            {
                levelImageName = @"az_dress_normallevel_bg";
            }
                break;
        }
        self.levelImageView.image = [UIImage imageNamed:levelImageName];
    }
    else
    {
        // 未获得
        NSString *imageName = @"";
        if (_cellModel.dressType == AZDressModelTypeHead)
        {
            imageName = kDressHeadPlaceholderImageName;
        }
        else if (_cellModel.dressType == AZDressModelTypeUpperClothing)
        {
            imageName = kDressUpperClothingPlaceholderImageName;
        }
        else if (_cellModel.dressType == AZDressModelTypeLowerClothing)
        {
            imageName = kDressLowerClothingPlaceholderImageName;
        }
        else if (_cellModel.dressType == AZDressModelTypeSuit)
        {
            imageName = kDressSuitPlaceholderImageName;
        }
        else if (_cellModel.dressType == AZDressModelTypeBackDesc)
        {
            imageName = @"az_dress_type_back_bg";
        }
        else if (_cellModel.dressType == AZDressModelTypeWaistDesc)
        {
            imageName = @"az_dress_type_waist_bg";
        }
        else if (_cellModel.dressType == AZDressModelTypeHeadDec)
        {
            imageName = @"az_dress_type_head_desc_bg";
        }
        
        self.coverImageView.image = [UIImage imageNamed:imageName];
    }
    
    // 更新布局
    [self updateCoverImageViewConstraints:_cellModel.isOwned];
}

#pragma mark - Private Method

- (void)setupSubviews
{
    CGFloat dressNameBgHeight = (IS_IPAD ? 20 * 1.25 : 20);
    
    @WeakObj(self);
    
    [self.contentView addSubview:self.levelImageView];
    [self.levelImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
        
    [self.contentView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.bottom.mas_offset(-dressNameBgHeight);
        make.centerX.mas_equalTo(selfWeak.contentView.mas_centerX);
        make.width.height.mas_equalTo(selfWeak.wx_width - dressNameBgHeight);
    }];
    
//    [self.contentView addSubview:self.limitTimeImageView];
//    [self.limitTimeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_offset(4);
//        make.left.mas_equalTo(selfWeak.levelImageView.mas_left).mas_offset(8);
//        make.width.mas_equalTo(26);
//        make.height.mas_equalTo(14);
//    }];
    
    [self.contentView addSubview:self.redPointView];
    [self.redPointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.right.mas_offset((IS_IPAD ? -4 : 0));
        make.width.height.mas_equalTo(kRedPointViewWidth);
    }];
    
    [self.contentView addSubview:self.dressNameLabel];
    [self.dressNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(6);
        make.right.mas_offset(-6);
        make.bottom.mas_offset((IS_IPAD ? (-8 * 1.25) : (-8)));
        make.height.mas_equalTo(dressNameBgHeight);
    }];
    
    [self.contentView addSubview:self.leftTimeLabel];
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(8);
        make.right.mas_offset(-8);
        make.bottom.mas_equalTo(selfWeak.dressNameLabel.mas_bottom).mas_offset(-(dressNameBgHeight + 1));
        make.height.mas_equalTo(12);
    }];
    
    [self.contentView addSubview:self.dressNumImageView];
    [self.dressNumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-8);
        make.bottom.mas_equalTo(selfWeak.dressNameLabel.mas_bottom).mas_offset(-(dressNameBgHeight + 5));
        make.width.height.mas_equalTo(IS_IPAD ? 19 * 1.2 : 19);
    }];
    
    [self.contentView addSubview:self.dressNumLabel];
    [self.dressNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(selfWeak.dressNumImageView.mas_top);
        make.bottom.mas_equalTo(selfWeak.dressNumImageView.mas_bottom);
        make.left.mas_equalTo(selfWeak.dressNumImageView.mas_left).mas_offset(1);
        make.right.mas_equalTo(selfWeak.dressNumImageView.mas_right).mas_offset(-1);
    }];
    
    [self.contentView addSubview:self.selectedImageView];
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    
    [self.contentView addSubview:self.expiredMaskView];
    [self.expiredMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.left.mas_offset(IS_IPAD ? 5 : 4);
        make.right.mas_offset(IS_IPAD ? -5 : -4);
        make.bottom.mas_offset(IS_IPAD ? -10 : -8);
    }];
    
    [self.contentView addSubview:self.dressAttrImageView];
    [self.dressAttrImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(IS_IPAD ? 7 * 1.25 : 7);
        make.left.mas_offset(IS_IPAD ? 12 * 1.25 : 12);
        make.width.mas_equalTo(IS_IPAD ? 25 * 1.25 : 25);
        make.height.mas_equalTo(IS_IPAD ? 13 * 1.25 : 13);
    }];
    
}

- (void)updateCoverImageViewConstraints:(BOOL)isOwned
{
    @WeakObj(self);
    
    CGFloat dressNameBgHeight = 20;
    if (isOwned)
    {
        [self.coverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            CGFloat width = 72;
            CGFloat height = width;
            
            CGFloat imgMaxHeight = selfWeak.wx_height - dressNameBgHeight - 8;
            CGFloat top = (imgMaxHeight - height) / 2;
            CGFloat left = (selfWeak.wx_width - width) / 2;
            
            make.top.mas_offset(top);
            make.left.mas_offset(left);
            make.width.height.mas_equalTo(width);
        }];
    }
    else
    {
        [self.coverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.mas_offset(0);
        }];
    }
}

- (void )setLeftTimeAttributedStr:(NSString *)leftTimeStr
{
    if (leftTimeStr.length == 0)
    {
        _leftTimeLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@""];
        return;
    }
    //文字描边（空心字）默认黑色，必须设置width
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:leftTimeStr];
    attributedText.yy_font = [UIFont wx_fontPingFangSCSemiboldWithSize:10];
    attributedText.yy_color = [UIColor wx_colorWithHEXValue:0xE02727];
    YYTextShadow *shadow = [YYTextShadow new];
    shadow.color = [UIColor wx_colorWithHEXValue:0xffffff alpha:0.7];
    shadow.offset = CGSizeMake(0, 1);
    shadow.radius = 1;
    {
        YYTextShadow *subShadow = [YYTextShadow new];
        subShadow.color = [UIColor wx_colorWithHEXValue:0xffffff alpha:0.7];
        subShadow.offset = CGSizeMake(0, -1);
        subShadow.radius = 1;
        shadow.subShadow = subShadow;
    }
    attributedText.yy_textShadow = shadow;
    
    _leftTimeLabel.attributedText = attributedText;
    
    _leftTimeLabel.textAlignment = NSTextAlignmentRight;
}

- (NSString *)getLeftTimeStr
{
    if (_cellModel.isExpired)
    {
        return @"已过期";
    }
    
    NSInteger leftTime = _cellModel.leftTime;
    if (leftTime <= 60)
    {
        return @"剩余1分钟";
    }
    else if (leftTime > 60 && leftTime / 60.0 < 60)
    {
        return [NSString stringWithFormat:@"剩余%ld分钟", (long)(leftTime / 60.0)];
    }
    else if (leftTime / 60.0 >= 60 && leftTime / 60.0 / 60.0 < 24)
    {
        return [NSString stringWithFormat:@"剩余%ld小时", (long)(leftTime / 60.0 / 60.0)];
    }
    else
    {
        return [NSString stringWithFormat:@"剩余%ld天", (long)(leftTime / 60.0 / 60.0 / 24)];
    }
}

#pragma mark - Getter

- (UIImageView *)coverImageView
{
    if (_coverImageView == nil)
    {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.backgroundColor = [UIColor clearColor];
    }
    return _coverImageView;
}

- (UIImageView *)levelImageView
{
    if (_levelImageView == nil)
    {
        _levelImageView = [[UIImageView alloc] init];
    }
    return _levelImageView;
}

- (UIImageView *)selectedImageView
{
    if (_selectedImageView == nil)
    {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.image = [UIImage imageNamed:kDressSelectedImageName];
    }
    return _selectedImageView;
}

//- (UIImageView *)limitTimeImageView
//{
//    if (_limitTimeImageView == nil)
//    {
//        _limitTimeImageView = [[UIImageView alloc] init];
//        _limitTimeImageView.image = [UIImage imageNamed:@"az_dress_limit_time_icon"];
//    }
//    return _limitTimeImageView;
//}


- (UIView *)redPointView
{
    if (_redPointView == nil)
    {
        _redPointView = [[UIView alloc] init];
        _redPointView.backgroundColor = [UIColor wx_colorWithHEXValue:0XFF4242];
        _redPointView.layer.cornerRadius = kRedPointViewWidth / 2;
        _redPointView.layer.borderColor = [UIColor wx_colorWithHEXValue:0XFFFFFF].CGColor;
        _redPointView.layer.borderWidth = 1.5f;
        _redPointView.layer.masksToBounds = YES;
    }
    return _redPointView;
}

- (UIImageView *)dressNumImageView
{
    if (_dressNumImageView == nil)
    {
        _dressNumImageView = [[UIImageView alloc] init];
        _dressNumImageView.image = [UIImage imageNamed:kDressNumImageName];
    }
    return _dressNumImageView;
}

- (UILabel *)dressNameLabel
{
    if (_dressNameLabel == nil)
    {
        _dressNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dressNameLabel.textColor = [UIColor whiteColor];
        _dressNameLabel.textAlignment = NSTextAlignmentCenter;
        _dressNameLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:10];
    }
    return _dressNameLabel;
}

- (UILabel *)dressNumLabel
{
    if (_dressNumLabel == nil)
    {
        _dressNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dressNumLabel.textColor = [UIColor blackColor];
        _dressNumLabel.textAlignment = NSTextAlignmentCenter;
        _dressNumLabel.font = [UIFont wx_fontPingFangSCSemiboldWithSize:10];
    }
    return _dressNumLabel;
}

- (YYLabel *)leftTimeLabel
{
    if (_leftTimeLabel == nil)
    {
        _leftTimeLabel = [[YYLabel alloc] init];
        _leftTimeLabel.font = [UIFont wx_fontPingFangSCSemiboldWithSize:10];
    }
    return _leftTimeLabel;
}

- (UIView *)expiredMaskView
{
    if (_expiredMaskView == nil)
    {
        _expiredMaskView = [[UIView alloc] init];
        _expiredMaskView.hidden = YES;
        _expiredMaskView.backgroundColor = [UIColor wx_colorWithHEXValue:0xfffffff];
        NSInteger cornerRadius = 11;
        if (IS_IPAD)
        {
            cornerRadius = 15;
        }
        _expiredMaskView.layer.cornerRadius = cornerRadius;
        
        _expiredMaskView.layer.masksToBounds = YES;
    }
    return _expiredMaskView;
}

- (UIImageView *)dressAttrImageView
{
    if (_dressAttrImageView == nil)
    {
        _dressAttrImageView = [[UIImageView alloc] init];
        _dressAttrImageView.backgroundColor = [UIColor clearColor];
    }
    return _dressAttrImageView;
}

@end
