//
//  AZUserAvtarListView.m
//  AZSignIn
//
//  Created by leev on 2023/7/27.
//

#import "AZUserAvtarListView.h"
#import "AZAvatarCollectionViewCell.h"
//#import "EpicAvatarSetManager.h"


#define kCellWidth                                 (IS_IPAD ? 62 * 1.5 : 62)
#define kCellHeight                                (IS_IPAD ? 62 * 1.5 : 62)

#define kConfirmButtonWidth                         118
#define kConfirmButtonHeight                        44

@interface AZUserAvtarListView () <AZAvatarCollectionViewCellDelegate, UITextFieldDelegate>
{
    AZAvatarCollectionViewCell *_lastSelected2DHeadCell;
    AZAvatarCollectionViewCell *_lastSelectedHeadCell;
    AZAvatarCollectionViewCell *_lastSelectedExpressionCell;
    AZAvatarCollectionViewCell *_lastSelectedSkinCell;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) AZUserAvatarListModel *avatarListModel;

@property (nonatomic, strong) UIView *nickNameParentView;

@property (nonatomic, strong) UITextField *nickNameTextField;

@property (nonatomic, strong) UIButton *refreshBtn;

@property (nonatomic, strong) UIView *leftTapView;

@property (nonatomic, strong) NSMutableArray *randomEnNameArray; //随机的英文名

@property (nonatomic, strong) NSString *currentRecommendNickName; //当前推荐的昵称

@property (nonatomic, strong) UIView *accountTipView;
@property (nonatomic, strong) UILabel *accountTipLabel;

@end

@implementation AZUserAvtarListView

#pragma mark - Override

- (void)dealloc
{
    [self removeNotifications];
    [self removeGuideAnimation];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        _lastSelected2DHeadCell = nil;
        _lastSelectedHeadCell = nil;
        _lastSelectedExpressionCell = nil;
        _lastSelectedSkinCell = nil;
    }
    return self;
}

#pragma mark - Public Method

- (void)setupAvatarListModel:(AZUserAvatarListModel *)avatarListModel
{
    _avatarListModel = avatarListModel;
    
    // 添加子视图
    [self setupSubviews];
    
    // 后端控制是否允许编辑昵称
    self.nickNameTextField.userInteractionEnabled = _avatarListModel.editNickNameEnable;
}

// 2D头像url
- (NSString *)selected2DHeadPicUrl
{
    return _lastSelected2DHeadCell.cellModel.avatarCoverUrl;
}

#pragma mark - Event Handle

- (void)confirmAction:(UIButton *)sender
{
    [self endEditing:YES];
    
    NSMutableArray *avatarIds = [NSMutableArray array];
    
    if (_lastSelectedHeadCell)
    {
        if(_lastSelectedHeadCell.cellModel.dressId.count > 0){
            [avatarIds addObjectsFromArray:_lastSelectedHeadCell.cellModel.dressId];
        }
    }
    if (_lastSelectedExpressionCell)
    {
        [avatarIds wx_addObject:_lastSelectedExpressionCell.cellModel.avatarId];
    }
    if (_lastSelectedSkinCell)
    {
        [avatarIds wx_addObject:_lastSelectedSkinCell.cellModel.avatarId];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(userAvatarListView:confirmSelectedDressIds:headPicId:nickName:isRecommmend:)])
    {
        BOOL isRecommend = NO;
        if (self.nickNameTextField.text.length > 0 && [self.currentRecommendNickName isEqualToString:self.nickNameTextField.text])
        {
            isRecommend = YES;
        }
        [self.delegate userAvatarListView:self confirmSelectedDressIds:avatarIds headPicId:_lastSelected2DHeadCell.cellModel.avatarId nickName:self.nickNameTextField.text isRecommmend:isRecommend];
    }
}

// 手势事件
- (void)tapAction:(UITapGestureRecognizer *)sender
{
    [self endEditing:YES];
}

// 随机英文名
- (void)refreshAction:(UIButton *)sender
{
    // 埋点
    [WXLog click:@"scene_nickname_random_click" params:nil];

    if (self.randomEnNameArray.count == 0)
    {
        @WeakObj(self);

        NSString *url = [NSString stringWithFormat:@"%@/abc-api/v3/ucenter/list-nickname", [AZAppHostConfig getAppDomain]];

        id<EUANetworkProvider> networkProvider = [EpicUnityAdapterManager sharedInstance].networkProvider;
        [networkProvider GET:url parameters:nil headers:nil completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
            if (error) {
                [WXToastView showToastWithTitle:error.localizedDescription ?: @"随机失败~"];
                return;
            }

            NSDictionary *resultDic = response;
            if ([resultDic isKindOfClass:[NSDictionary class]] && [resultDic wx_arrayForKey:@"list"].count > 0)
            {
                selfWeak.randomEnNameArray = [NSMutableArray arrayWithArray:[resultDic wx_arrayForKey:@"list"]];
                [selfWeak randomEnNameSet];
            }
            else
            {
                [WXToastView showToastWithTitle:@"随机失败~"];
            }
        }];
    }
    else
    {
        [self randomEnNameSet];
    }
}


- (void)keyboardWillShow:(NSNotification *)notification
{
    if (_nickNameTextField.isFirstResponder)
    {
        [self.superview addSubview:self.leftTapView];
        
        // 由于手机号输入不会被键盘遮挡，所以只处理验证码输入textField
        NSDictionary *userInfo = notification.userInfo;
        
        // 键盘的高度
        CGFloat keyboardHeight = [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size.height;
        
        CGPoint nickNameTextFieldPoint = [self convertPoint:CGPointMake(self.nickNameParentView.wx_left, self.nickNameParentView.wx_top) toView:self.superview];
        CGFloat sumHeight = nickNameTextFieldPoint.y + self.nickNameTextField.wx_height + keyboardHeight + 12;
        if (sumHeight <= [UIScreen wx_currentScreenHeight])
        {
            // 未遮挡不处理
            return;
        }
        else
        {
            CGFloat moveValue = sumHeight - [UIScreen wx_currentScreenHeight];
            // 最大不能移除屏幕之外
            if (moveValue > nickNameTextFieldPoint.y - self.nickNameTextField.wx_height)
            {
                moveValue = nickNameTextFieldPoint.y - self.nickNameTextField.wx_height;
            }
            
            // 键盘谈起的动画时长
            NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
            
            [UIView animateWithDuration:duration.doubleValue animations:^{
                self.wx_top -= moveValue;
            }];
        }
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    if (_nickNameTextField)
    {
        [_leftTapView removeFromSuperview];
        _leftTapView = nil;
        
        NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:duration.doubleValue animations:^{
            self.frame = CGRectMake(kCurrentScreenWidth / 2, 0, kCurrentScreenWidth / 2, kCurrentScreenHeight);
        }];
    }
}

- (void)textDidChanged:(NSNotification *)notification
{
    UITextField *currentTextField = notification.object;
    NSString *lang = [[currentTextField textInputMode] primaryLanguage];
    
    if (currentTextField == _nickNameTextField)
    {
        NSUInteger limitLength = 8;
        
        // 先去掉空格，最多只支持字符:limitLength
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *result = [currentTextField.text stringByTrimmingCharactersInSet:set];
        
        if ([lang isEqualToString:@"zh-Hans"])
        {
            UITextRange *selectedRange = [currentTextField markedTextRange];
            // 获取高亮部分
            UITextPosition *position = [currentTextField positionFromPosition:selectedRange.start offset:0];
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (!position)
            {
                if (result.length > limitLength)
                {
                    @try {
                        result = [result substringToIndex:limitLength];
                        currentTextField.text = result;
                    } @catch (NSException *exception) {
                        
                    }
                    [currentTextField resignFirstResponder];
                    
                    [WXToastView showToastWithTitle:@"昵称仅支持中文、英文、数字，最多8个字~" duration:3];
                }
            }
        }
        else
        {
            if (result.length > limitLength)
            {
                @try {
                    result = [result substringToIndex:limitLength];
                    currentTextField.text = result;
                } @catch (NSException *exception) {
                    
                }
                [currentTextField resignFirstResponder];
                
                [WXToastView showToastWithTitle:@"昵称仅支持中文、英文、数字，最多8个字~" duration:3];
            }
        }
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    return YES;
}


#pragma mark - AZAvatarCollectionViewCellDelegate

- (void)didSelectCell:(AZAvatarCollectionViewCell *)cell cellModel:(AZUserAvtarModel *)cellModel
{
    if (cellModel.isSelected)
    {
        return;
    }
    
    if (cellModel.avatarType == AZUserAvtarModelTypePackage)
    {
        if (_lastSelectedHeadCell)
        {
            _lastSelectedHeadCell.cellModel.isSelected = NO;
            [_lastSelectedHeadCell setupCellModel:_lastSelectedHeadCell.cellModel];
        }
        
        _lastSelectedHeadCell = cell;
        
        if(_lastSelectedExpressionCell.cellModel.avatarId.integerValue != cellModel.relationEmojiId) {
            //不通套装切换不通的默认表情
            for (UIView *subView in _scrollView.subviews) {
                if([subView isKindOfClass:[AZAvatarCollectionViewCell class]]){
                    AZAvatarCollectionViewCell *subCell = (AZAvatarCollectionViewCell *)subView;
                    if([_avatarListModel.expressionModelArray  containsObject:subCell.cellModel] && subCell.cellModel.avatarId.integerValue == cellModel.relationEmojiId){
                        _lastSelectedExpressionCell.cellModel.isSelected = NO;
                        [_lastSelectedExpressionCell setupCellModel:_lastSelectedExpressionCell.cellModel];
                        subCell.cellModel.isSelected = YES;
                        [subCell setupCellModel:subCell.cellModel];
                        _lastSelectedExpressionCell = subCell;
                    }
                }
            }
        }
        
        // 更新状态
        cellModel.isSelected = YES;
        [cell setupCellModel:cellModel];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(userAvatarListView:didSelectPackageAvater:expression:)])
        {
            [self.delegate userAvatarListView:self didSelectPackageAvater:cellModel expression:_lastSelectedExpressionCell.cellModel];
        }
        
        return;
    }
    
    if (cellModel.avatarType == AZUserAvtarModelType2DHeadPic)
    {
        if (_lastSelected2DHeadCell)
        {
            _lastSelected2DHeadCell.cellModel.isSelected = NO;
            [_lastSelected2DHeadCell setupCellModel:_lastSelected2DHeadCell.cellModel];
        }
        
        _lastSelected2DHeadCell = cell;
        
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params wx_setObject:cellModel.avatarId forKey:@"id"];
            [WXLog show:@"setting_personal_head_click" params:params];
        }
    }
    
    if (cellModel.avatarType == AZUserAvtarModelTypeExpression)
    {
        if (_lastSelectedExpressionCell)
        {
            _lastSelectedExpressionCell.cellModel.isSelected = NO;
            [_lastSelectedExpressionCell setupCellModel:_lastSelectedExpressionCell.cellModel];
        }
        
        _lastSelectedExpressionCell = cell;
        
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params wx_setObject:cellModel.avatarId forKey:@"id"];
            [WXLog show:@"setting_personal_face_click" params:params];
        }
        
    }
    
    if (cellModel.avatarType == AZUserAvtarModelTypeSkin)
    {
        if (_lastSelectedSkinCell)
        {
            _lastSelectedSkinCell.cellModel.isSelected = NO;
            [_lastSelectedSkinCell setupCellModel:_lastSelectedSkinCell.cellModel];
        }
        _lastSelectedSkinCell = cell;
        
        {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params wx_setObject:cellModel.avatarId forKey:@"id"];
            [WXLog show:@"setting_personal_skin_click" params:params];
        }
    }
    
    // 更新状态
    cellModel.isSelected = YES;
    [cell setupCellModel:cellModel];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(userAvatarListView:didSelectAvater:)])
    {
        [self.delegate userAvatarListView:self didSelectAvater:cellModel];
    }
}

- (void)setAccountTip:(NSString *)text isShow:(BOOL)isShow
{
    if (text.length > 0) {
        self.accountTipView.hidden = NO;
        
        CGFloat tipHeight = [text boundingRectWithSize:CGSizeMake(334, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: [UIFont wx_fontPingFangSCMediumWithSize:13]}
                                                    context:nil].size.height+1;
        self.accountTipLabel.text = text;
        
        if (tipHeight < 18) tipHeight = 18;
        self.accountTipView.wx_height = tipHeight;
        self.accountTipLabel.wx_height = tipHeight;
        
    }else {
        self.accountTipView.hidden = YES;
        self.accountTipLabel.text = @"";
    }
    if (isShow) {
        
        CGFloat nickNameWidth = self.refreshBtn.wx_left - 24;
        self.nickNameTextField.wx_width = nickNameWidth;
        
        self.refreshBtn.hidden = NO;
    } else {
        
        CGFloat nickNameWidth = self.refreshBtn.wx_left + 56;
        self.nickNameTextField.wx_width = nickNameWidth;
        self.refreshBtn.hidden = YES;
    }
}

#pragma mark - Private Method

- (void)setupSubviews
{
    [self wx_removeAllSubviews];
    
    [self addSubview:self.scrollView];
    [self addSubview:self.confirmButton];
    [self addSubview:self.nickNameParentView];
    [self.nickNameParentView addSubview:self.nickNameTextField];
    [self.nickNameParentView addSubview:self.refreshBtn];
    // 默认的名字，先做一下赋值
    self.nickNameTextField.text = [[EpicUnityAdapterManager sharedInstance].authProvider currentUserName];
    // 添加手势
    [self addTapGR];
    // 添加通知
    [self addNotifications];
    // 播放引导动画
    [self playGuideAnimation];

    [self addSubview:self.accountTipView];
}

- (void)playGuideAnimation
{
    @WeakObj(self);
    
    [WXAnimationManager playWithJson:@"az_signin_finger_guide"
                               speed:1
                         repeatCount:10000
                          identifier:@"az_signin_finger_guide_01"
                              layout:^(WXAnimationView *aniView) {
        [selfWeak.confirmButton addSubview:aniView];
        aniView.userInteractionEnabled = NO;
        aniView.frame = CGRectMake(kConfirmButtonWidth / 2 + 18, 12, 65, 68);
    }
                            autoPlay:YES
                          completion:^(BOOL finished) {
        
    }];
}

- (void)removeGuideAnimation
{
    [[WXAnimationManager defaultManager] stopAniamtionWithIdentifier:@"az_signin_finger_guide_01"];
}

- (void)addTapGR
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGR];
}

// 添加通知
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

// 移除通知
- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

- (void)randomEnNameSet
{
    NSString *nickName = [self.randomEnNameArray wx_objectAtIndex:0];
    
    self.nickNameTextField.text = nickName;
    
    self.currentRecommendNickName = nickName;
    
    // 用完之后删除
    [self.randomEnNameArray removeObjectAtIndex:0];
}


#pragma mark - Getter

- (UIView *)leftTapView
{
    if (_leftTapView == nil)
    {
        _leftTapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kCurrentScreenWidth / 2, kCurrentScreenHeight)];
        _leftTapView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_leftTapView addGestureRecognizer:tapGR];
    }
    return _leftTapView;
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil)
    {
        // 先计算scrollView的位置
        CGFloat titleWidth = 36;
        CGFloat maxContentWidth = 0;
        {
            if (maxContentWidth < _avatarListModel.packageModelArray.count * kCellWidth + titleWidth)
            {
                maxContentWidth = _avatarListModel.packageModelArray.count * kCellWidth + titleWidth;
            }
            
            if (maxContentWidth < _avatarListModel.expressionModelArray.count * kCellWidth + titleWidth)
            {
                maxContentWidth = _avatarListModel.expressionModelArray.count * kCellWidth + titleWidth;
            }
            
            if (maxContentWidth < _avatarListModel.skinModelArray.count * kCellWidth + titleWidth)
            {
                maxContentWidth = _avatarListModel.skinModelArray.count * kCellWidth + titleWidth;
            }
        }
        
        CGFloat height = kCellHeight * 3 + 12 * 2;
        CGFloat originY = (self.wx_height - height - kConfirmButtonHeight - 20) / 2;
        CGFloat originX = maxContentWidth - self.wx_width > 0 ? 0 : (self.wx_width - maxContentWidth) / 2;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(originX, originY, self.wx_width - originX * 2, height)];
        
        // y轴位置
        CGFloat itemOriginY = 0;
        // 注册环节
        {
            CGFloat x = 0;
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, itemOriginY, titleWidth, kCellHeight)];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"套装";
            titleLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:12];
            [_scrollView addSubview:titleLabel];
            
            x = titleWidth;
            
            for (AZUserAvtarModel *avatarModel in _avatarListModel.packageModelArray)
            {
                AZAvatarCollectionViewCell *cell = [[AZAvatarCollectionViewCell alloc] initWithFrame:CGRectMake(x, itemOriginY, kCellWidth, kCellHeight)];
                cell.delegate = self;
                [cell setupCellModel:avatarModel];
                
                if (avatarModel.isSelected)
                {
                    _lastSelectedHeadCell = cell;
                }
                
                x += kCellWidth;
                
                [_scrollView addSubview:cell];
            }
        }
        
        
        // 表情元素
        {
            CGFloat x = 0;
            itemOriginY += kCellHeight;
            itemOriginY += 12;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, itemOriginY, titleWidth, kCellHeight)];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"表情";
            titleLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:12];
            [_scrollView addSubview:titleLabel];
            
            x = titleWidth;
            
            for (AZUserAvtarModel *avatarModel in _avatarListModel.expressionModelArray)
            {
                AZAvatarCollectionViewCell *cell = [[AZAvatarCollectionViewCell alloc] initWithFrame:CGRectMake(x, itemOriginY, kCellWidth, kCellHeight)];
                cell.delegate = self;
                [cell setupCellModel:avatarModel];
                
                if (avatarModel.isSelected)
                {
                    _lastSelectedExpressionCell = cell;
                }
                
                x += kCellWidth;
                
                [_scrollView addSubview:cell];
            }
        }
        
        // 肤色元素
        {
            CGFloat x = 0;
            itemOriginY += kCellHeight;
            itemOriginY += 12;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, itemOriginY, titleWidth, kCellHeight)];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"肤色";
            titleLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:12];
            [_scrollView addSubview:titleLabel];
            
            x = titleWidth;
            
            for (AZUserAvtarModel *avatarModel in _avatarListModel.skinModelArray)
            {
                AZAvatarCollectionViewCell *cell = [[AZAvatarCollectionViewCell alloc] initWithFrame:CGRectMake(x, itemOriginY, kCellWidth, kCellHeight)];
                cell.delegate = self;
                [cell setupCellModel:avatarModel];
                
                if (avatarModel.isSelected)
                {
                    _lastSelectedSkinCell = cell;
                }
                
                x += kCellWidth;
                
                [_scrollView addSubview:cell];
            }
        }
        _scrollView.contentSize = CGSizeMake(maxContentWidth, height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        if (maxContentWidth > _scrollView.wx_width)
        {
            _scrollView.scrollEnabled = YES;
        }
        else
        {
            _scrollView.scrollEnabled = NO;
        }
    }
    return _scrollView;
}

- (UIView *)nickNameParentView
{
    if (_nickNameParentView == nil)
    {
        CGFloat width = 222;
        CGFloat height = 44;
        _nickNameParentView = [[UIView alloc] initWithFrame:CGRectMake(self.confirmButton.wx_left - 12 - width, self.confirmButton.wx_top, width, height)];
        _nickNameParentView.backgroundColor = [UIColor wx_colorWithHEXValue:0xffffff alpha:0.6];
        _nickNameParentView.layer.cornerRadius = height / 2;
        _nickNameParentView.layer.masksToBounds = YES;
    }
    return _nickNameParentView;
}

- (UITextField *)nickNameTextField
{
    if (_nickNameTextField == nil)
    {
        CGFloat x = 12;
        CGFloat width = self.refreshBtn.wx_left - x - 12;
        CGFloat height = 40;
        _nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(x, (self.nickNameParentView.wx_height - height) / 2, width, height)];
        _nickNameTextField.font = [UIFont wx_fontPingFangSCMediumWithSize:15];
        _nickNameTextField.tintColor = [UIColor wx_colorWithHEXValue:0x2D6EFF];
        _nickNameTextField.textColor = [UIColor wx_FontGrayColor];
        _nickNameTextField.placeholder = @"请在此输入昵称";
        _nickNameTextField.delegate = self;
    }
    return _nickNameTextField;
}

- (UIButton *)refreshBtn
{
    if (_refreshBtn == nil)
    {
        CGFloat width = 56;
        CGFloat height = 24;
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshBtn.frame = CGRectMake(self.nickNameParentView.wx_width - width - 12, (self.nickNameParentView.wx_height - height) / 2, width, height);
        _refreshBtn.backgroundColor = [UIColor wx_colorWithHEXValue:0xffe500];
        
        [_refreshBtn setTitle:@" 随机" forState:UIControlStateNormal];
        _refreshBtn.titleLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:11];
        [_refreshBtn setTitleColor:[UIColor wx_colorWithHEXValue:0x000000] forState:UIControlStateNormal];
        
        [_refreshBtn setImage:[UIImage imageNamed:@"signin_enname_refresh_icon"] forState:UIControlStateNormal];
        
        [_refreshBtn addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
        _refreshBtn.layer.cornerRadius = _refreshBtn.wx_height / 2;
    }
    return _refreshBtn;
}


- (UIButton *)confirmButton
{
    if (_confirmButton == nil)
    {
        // 确定按钮需要和scrollView内容区域左对齐，所以需要动态计算
        CGFloat right = self.scrollView.wx_right;
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(right - kConfirmButtonWidth, self.scrollView.wx_bottom + 20, kConfirmButtonWidth, kConfirmButtonHeight);
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"signin_avatar_confirm"] forState:UIControlStateNormal];
        [_confirmButton setTitle:@"立即进入" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor wx_colorWithHEXValue:0x822F01] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:16];
        [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIView *)accountTipView
{
    if (_accountTipView == nil) {
        _accountTipView = [[UIView alloc] initWithFrame:CGRectMake(self.nickNameParentView.wx_left, self.nickNameParentView.wx_bottom + 10, 352, 18)];
        _accountTipView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 16, 16)];
        imageView.image = [UIImage imageNamed:@"account_tip"];
        [_accountTipView addSubview:imageView];
        [_accountTipView addSubview:self.accountTipLabel];
        _accountTipView.hidden = YES;
    }
    return _accountTipView;
}

- (UILabel *)accountTipLabel
{
    if (_accountTipLabel == nil) {
        _accountTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 334, 18)];
        _accountTipLabel.numberOfLines = 0;
        _accountTipLabel.textColor = [UIColor whiteColor];
        _accountTipLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:13];
    }
    return _accountTipLabel;
}

@end
