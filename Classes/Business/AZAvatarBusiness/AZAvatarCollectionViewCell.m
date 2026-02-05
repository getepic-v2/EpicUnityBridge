//
//  AZAvatarCollectionViewCell.m
//  AZSignIn
//
//  Created by leev on 2023/7/27.
//

#import "AZAvatarCollectionViewCell.h"
#import <WXToolKit/WXToolKitMacro.h>

// 形象选中态
#define kAvatarSelectedImageName                        @"signin_avatar_selected_image"

// 形象背景
#define kAvatarBgImageName                              @"signin_avatar_bg_image"

#define kAvatarSelectedImageWidth                       (IS_IPAD ? 62 * 1.5 : 62)
#define kAvatarSelectedImageHeight                      (IS_IPAD ? 62 * 1.5 : 62)

#define kAvatarImageWidth                               (IS_IPAD ? 54 * 1.5 : 54)
#define kAvatarImageHeight                              (IS_IPAD ? 54 * 1.5 : 54)

@interface AZAvatarCollectionViewCell ()

@property (nonatomic, strong) UIImageView *selectedImageView; //选中态imageView

@property (nonatomic, strong) UIImageView *avatarImageView; //形象imageView

@property (nonatomic, strong) UIImageView *avatarBgImageView; //形象背景imageView


@end

@implementation AZAvatarCollectionViewCell

#pragma mark - Override

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSubviews];
        
        [self addTapGR];
    }
    return self;
}

#pragma mark - Public Method

- (void)setupCellModel:(AZUserAvtarModel *)cellModel
{
    _cellModel = cellModel;
    
    NSString *url = _cellModel.avatarCoverUrl;
    if (url.length > 0)
    {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    
    if (_cellModel.avatarType == AZUserAvtarModelType2DHeadPic)
    {
        // 如果是头像的话，需要改一下约束
        [self.avatarImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kAvatarImageWidth * 0.7);
        }];
    }
    
    if (_cellModel.avatarType == AZUserAvtarModelTypeExpression)
    {
        // 如果是表情的话，需要改一下约束
        [self.avatarImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kAvatarImageWidth * 0.8);
        }];
    }
    
    self.selectedImageView.hidden = !_cellModel.isSelected;
    self.avatarBgImageView.hidden = _cellModel.isSelected;
}

#pragma mark - Private Method

- (void)addTapGR
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.contentView addGestureRecognizer:tapGR];
}

- (void)setupSubviews
{
    @WeakObj(self);
    
    [self.contentView addSubview:self.selectedImageView];
    [self.selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(selfWeak.contentView.mas_centerX);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.width.height.mas_equalTo(kAvatarSelectedImageWidth);
        make.height.mas_equalTo(kAvatarSelectedImageHeight);
    }];
    
    [self.contentView addSubview:self.avatarBgImageView];
    [self.avatarBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(selfWeak.contentView.mas_centerX);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.width.height.mas_equalTo(kAvatarImageWidth);
        make.height.mas_equalTo(kAvatarImageWidth);
    }];

    [self.contentView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(selfWeak.contentView.mas_centerX);
        make.centerY.mas_equalTo(selfWeak.contentView.mas_centerY);
        make.width.height.mas_equalTo(kAvatarImageWidth);
    }];
}

#pragma mark - Event Handle

- (void)tapAction:(UITapGestureRecognizer *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCell:cellModel:)])
    {
        [self.delegate didSelectCell:self cellModel:_cellModel];
    }
}

#pragma mark - Getter

- (UIImageView *)avatarImageView
{
    if (_avatarImageView == nil)
    {
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

- (UIImageView *)avatarBgImageView
{
    if (_avatarBgImageView == nil)
    {
        _avatarBgImageView = [[UIImageView alloc] init];
        _avatarBgImageView.image = [UIImage imageNamed:kAvatarBgImageName];
    }
    return _avatarBgImageView;
}

- (UIImageView *)selectedImageView
{
    if (_selectedImageView == nil)
    {
        _selectedImageView = [[UIImageView alloc] init];
        _selectedImageView.image = [UIImage imageNamed:kAvatarSelectedImageName];
    }
    return _selectedImageView;
}

@end
