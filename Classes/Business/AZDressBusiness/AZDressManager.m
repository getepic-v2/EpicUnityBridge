//
//  AZDressManager.m
//  AZCommonBusiness
//
//  Created by leev on 2023/8/1.
//

#import "AZDressManager.h"

#import <EpicWXCommonKit/AZAvatarUnityZipDownloadTask.h>
#import <EpicWXCommonKit/AZAvatarUnityZipDownloadTaskQueue.h>
#import "AZDressListView.h"
#import "AZDressListModel.h"
#import "AZDressUnityBusiness.h"

// rightView的宽度
#define kRightBgViewWidthValue                              76

// 装扮类型btn的宽度
#define kDressTypeButtonWidthValue                          83

// 装扮类型btn的高度
#define kDressTypeButtonHeightValue                         56

// 第一个皮肤类型btn距top的位置
#define kFirstSkinTypeBtnTopValue                    (IS_IPAD?120:10)
#define kDressViewTopValue                           (IS_IPAD?120:85)

// 右侧Button BasicTag
#define kDressTypeBtnBasicTag                               100

// 红点 basicTag
#define kRedPointViewBasicTag                               1000

// level筛选btn BasicTag
#define kDressLevelFilterBtnBasicTag                        10000

@interface AZDressManager () <AZDressListViewDelegate>
{
    id<EUANetworkTask> _networkTask;
    UIButton *_lastSelectedBtn;
    AZDressListModel *_currentDressListModel;
    AZDressListModel *_suitDressListModel;
    AZDressListModel *_headDressListModel;
    AZDressListModel *_upperDressListModel;
    AZDressListModel *_lowerDressListModel;
    
    AZDressListModel *_backDressListModel;
    AZDressListModel *_waistDressListModel;
    AZDressListModel *_headDescDressListModel;

    UIButton *_lastSelectedFilterBtn;
}


@property (nonatomic, strong) UIView *rightBgView; // 右侧背景view
@property (nonatomic, strong) UIScrollView *rightScrollView; // 右侧滚动view

@property (nonatomic, strong) AZDressListView *dressListView; //装扮listView

@property (nonatomic, strong) LoadingView *loadingView;

@property (nonatomic, strong) ErrorView *errorView;

@property (nonatomic, strong) NSArray *dressTypeArray;

@property (nonatomic, strong) UIButton *filterButton;

@property (nonatomic, strong) UIView *filterListView;

@property (nonatomic, strong) NSMutableArray<AZDressLevelModel *> *filterArray;

@end

@implementation AZDressManager

#pragma mark - Public Method

// 单例
+ (instancetype)sharedInstance
{
    static AZDressManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AZDressManager alloc] init];
    });
    return instance;
}


// 展示装扮view
- (void)showDressListViewInParentView:(UIView *)parentView
{
    // 先隐藏，等数据回来之后再展示
    [parentView addSubview:self.rightBgView];
    self.rightBgView.hidden = YES;
    
    [parentView addSubview:self.dressListView];
    
    [parentView addSubview:self.filterButton];
    self.filterButton.hidden = YES;
    
    // 请求数据
    [self requestDressData];
}


// 移除装扮view
- (void)removeDressListView
{
    [_dressListView removeFromSuperview];
    [_rightBgView removeFromSuperview];
    [_filterButton removeFromSuperview];
    [_filterListView removeFromSuperview];

    _dressListView = nil;
    _rightBgView = nil;
    _filterButton = nil;
    _filterListView = nil;
    _lastSelectedFilterBtn = nil;

    [_networkTask cancel];
    _networkTask = nil;
}

#pragma mark - Private Method

- (void)dressListViewReload
{
    // 拿到当前的数据源，然后刷新
    AZDressModelType dressType = _lastSelectedBtn.tag - kDressTypeBtnBasicTag;
        
    switch (dressType)
    {
        case AZDressModelTypeSuit:
        {
            // 套装
            _currentDressListModel = _suitDressListModel;
        }
            break;
        case AZDressModelTypeHead:
        {
            // 发型
            _currentDressListModel = _headDressListModel;
        }
            break;
        case AZDressModelTypeUpperClothing:
        {
            // 上装
            _currentDressListModel = _upperDressListModel;
        }
            break;
        case AZDressModelTypeLowerClothing:
        {
            // 下装
            _currentDressListModel = _lowerDressListModel;
        }
            break;
        case AZDressModelTypeBackDesc:
        {
            _currentDressListModel = _backDressListModel;
        }
            break;
        case AZDressModelTypeWaistDesc:
        {
            _currentDressListModel = _waistDressListModel;
        }
            break;
        case AZDressModelTypeHeadDec:
        {
            _currentDressListModel = _headDescDressListModel;
        }
            break;
        default:
        {
        }
            break;
    }
    
    // 拿到当前筛选的levelCode
    NSInteger levelCode = -1;
    if (_lastSelectedFilterBtn)
    {
        NSInteger index = _lastSelectedFilterBtn.tag - kDressLevelFilterBtnBasicTag;
        
        levelCode = [[self.filterArray wx_objectAtIndex:index] levelCode];
    }
    
    NSMutableArray *filterDressModelArray = [NSMutableArray array];
    if (levelCode == -1)
    {
        filterDressModelArray = _currentDressListModel.dressModelArray;
    }
    else
    {
        for (AZDressModel *dressModel in _currentDressListModel.dressModelArray)
        {
            if (dressModel.levelCode == levelCode)
            {
                [filterDressModelArray wx_addObject:dressModel];
            }
        }
    }
    
    // 产品逻辑如果小于9，则补齐为9个，如果大于9 但不是3的倍数，需要补齐
    NSInteger addCount = 0;
    if (filterDressModelArray.count < 9)
    {
        addCount = 9 - filterDressModelArray.count;
    }
    else
    {
        addCount = 3 - filterDressModelArray.count % 3;
        
        // 如果刚好是3的倍数，则不再补齐
        if (addCount == 3)
        {
            addCount = 0;
        }
    }
    
    for (int i = 0; i < addCount; i++)
    {
        AZDressModel *dressModel = [[AZDressModel alloc] init];
        dressModel.isOwned = NO;
        dressModel.dressType = dressType;
        [filterDressModelArray addObject:dressModel];
    }
    
    
    // 刷新数据源
    [self.dressListView.collectionView setContentOffset:CGPointZero];
    [self.dressListView setupDressModelArray:filterDressModelArray dressType:dressType];
    
    // 锚点
    [self scrollToLastestModelIfNeed];
}

// 锚点
- (void)scrollToLastestModelIfNeed
{
    NSIndexPath *indexpath = nil;
    for (int row = 0; row < _currentDressListModel.dressModelArray.count; row++)
    {
        AZDressModel *dressModel = [_currentDressListModel.dressModelArray wx_objectAtIndex:row];
        if (dressModel.isLastest)
        {
            indexpath = [NSIndexPath indexPathForRow:row inSection:0];
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dressListView.collectionView scrollToItemAtIndexPath:indexpath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    });
}

- (void)parseDataDic:(NSDictionary *)dic
{
    // levelModel解析
    {
        [self.filterArray removeAllObjects];
        NSArray *filterList = [[dic wx_dictionaryForKey:@"filter"] wx_arrayForKey:@"list"];
        for (NSDictionary *dic in filterList)
        {
            AZDressLevelModel *model = [[AZDressLevelModel alloc] initWithDic:dic];
            [self.filterArray wx_addObject:model];
        }
    }
    
    // 套装解析
    {
        NSArray *suitArray = [dic wx_arrayForKey:@"suit"];
        _suitDressListModel = [[AZDressListModel alloc] initWithSuitArray:suitArray];
    }
    
    // 非套装解析
    {
        NSDictionary *dressDic = [dic wx_dictionaryForKey:@"dress"];
        
        // 头部装扮解析
        NSDictionary *headDic = [dressDic wx_dictionaryForKey:@"head"];
        _headDressListModel = [[AZDressListModel alloc] initWithDic:headDic];
        
        // 上装装扮解析
        NSDictionary *upperDic = [dressDic wx_dictionaryForKey:@"upper"];
        _upperDressListModel = [[AZDressListModel alloc] initWithDic:upperDic];

        
        // 下装装扮解析
        NSDictionary *lowerDdic = [dressDic wx_dictionaryForKey:@"lower"];
        _lowerDressListModel = [[AZDressListModel alloc] initWithDic:lowerDdic];
        // 背部装扮解析
        NSDictionary *backDdic = [dressDic wx_dictionaryForKey:@"back_jr"];
        _backDressListModel = [[AZDressListModel alloc] initWithDic:backDdic canInvert:[backDdic wx_integerForKey:@"can_invert"] == 1];
        // 腰部扮解析
        NSDictionary *waistDdic = [dressDic wx_dictionaryForKey:@"waist_jr"];
        _waistDressListModel = [[AZDressListModel alloc] initWithDic:waistDdic canInvert:[waistDdic wx_integerForKey:@"can_invert"] == 1];
        // 头部装扮解析
        NSDictionary *headDescDic = [dressDic wx_dictionaryForKey:@"head_jr" ];
        _headDescDressListModel = [[AZDressListModel alloc] initWithDic:headDescDic canInvert:[headDescDic wx_integerForKey:@"can_invert"] == 1];
    }
}

// 通知Unity换单装
- (void)sendToUnityChangeDress:(AZDressModel *)dressModel
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (dressModel.dressType == AZDressModelTypeSuit)
    {
        [params wx_setObject:dressModel.dressId forKey:@"id"];
        
        // 取第一个dressModel
        AZDressModel *item = [dressModel.dressModelArray wx_objectAtIndex:0];
        [params wx_setObject:@(item.levelCode) forKey:@"level"];
        [params wx_setObject:item.levelName forKey:@"levelName"];
        [params wx_setObject:@(item.popularityValue) forKey:@"pop"];

        NSMutableArray *dressArray = [NSMutableArray array];
        for (AZDressModel *item in dressModel.dressModelArray)
        {
            NSMutableDictionary *paramsNew = [NSMutableDictionary dictionary];
            [paramsNew wx_setObject:item.dressZipUrl forKey:@"url"];
            [paramsNew wx_setObject:item.dressId forKey:@"id"];
            [paramsNew wx_setObject:@0 forKey:@"isDefault"];
            [paramsNew wx_setObject:item.uAddress forKey:@"uAddress"];
            [paramsNew wx_setObject:@(item.bodyPartType) forKey:@"bodyPartType"];
            [paramsNew wx_setObject:@(item.cutType) forKey:@"cutType"];
            [paramsNew wx_setObject:@(item.decorateType) forKey:@"decorateType"];
            [paramsNew wx_setObject:item.package forKey:@"package"];
            [dressArray addObject:paramsNew];
        }
        
        [params wx_setObject:dressArray forKey:@"subSkin"];
        
        [AZDressUnityBusiness sendToUnityChangeSuit:params];
    }
    else
    {
        [params wx_setObject:dressModel.dressZipUrl forKey:@"url"];
        [params wx_setObject:dressModel.dressId forKey:@"id"];
        [params wx_setObject:@0 forKey:@"isDefault"];
        [params wx_setObject:dressModel.uAddress forKey:@"uAddress"];
        [params wx_setObject:@(dressModel.bodyPartType) forKey:@"bodyPartType"];
        [params wx_setObject:@(dressModel.cutType) forKey:@"cutType"];
        [params wx_setObject:@(dressModel.decorateType) forKey:@"decorateType"];
        [params wx_setObject:@(dressModel.levelCode) forKey:@"level"];
        [params wx_setObject:dressModel.levelName forKey:@"levelName"];
        [params wx_setObject:@(dressModel.popularityValue) forKey:@"pop"];
        [params wx_setObject:@(0) forKey:@"undecorate"];
        [params wx_setObject:dressModel.package forKey:@"package"];
        [AZDressUnityBusiness sendToUnityChangeDress:params];
    }
}

// 展示红点
- (void)showRedPointViewIfNeed
{
    // 套装展示红点判断
    {
        BOOL showRedPoint = NO;
        
        for (int i = 0; i < _suitDressListModel.dressModelArray.count; i++)
        {
            AZDressModel *dressModel = [_suitDressListModel.dressModelArray wx_objectAtIndex:i];
            if (dressModel.isNew)
            {
                showRedPoint = YES;
                break;
            }
        }
        
        // 拿到当前的红点视图
        UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + AZDressModelTypeSuit];
        redPointView.hidden = !showRedPoint;
    }
    
    // 头部展示红点判断
    {
        BOOL showRedPoint = NO;
        
        for (int i = 0; i < _headDressListModel.dressModelArray.count; i++)
        {
            AZDressModel *dressModel = [_headDressListModel.dressModelArray wx_objectAtIndex:i];
            if (dressModel.isNew)
            {
                showRedPoint = YES;
                break;
            }
        }
        
        // 拿到当前的红点视图
        UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + AZDressModelTypeHead];
        redPointView.hidden = !showRedPoint;
    }
    
    // 上装展示红点判断
    {
        BOOL showRedPoint = NO;
        
        for (int i = 0; i < _upperDressListModel.dressModelArray.count; i++)
        {
            AZDressModel *dressModel = [_upperDressListModel.dressModelArray wx_objectAtIndex:i];
            if (dressModel.isNew)
            {
                showRedPoint = YES;
                break;
            }
        }
        
        // 拿到当前的红点视图
        UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + AZDressModelTypeUpperClothing];
        redPointView.hidden = !showRedPoint;
    }

    // 下装展示红点判断
    {
        BOOL showRedPoint = NO;
        
        for (int i = 0; i < _lowerDressListModel.dressModelArray.count; i++)
        {
            AZDressModel *dressModel = [_lowerDressListModel.dressModelArray wx_objectAtIndex:i];
            if (dressModel.isNew)
            {
                showRedPoint = YES;
                break;
            }
        }
        
        // 拿到当前的红点视图
        UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + AZDressModelTypeLowerClothing];
        redPointView.hidden = !showRedPoint;
    }

    // 背部展示红点判断
    {
        BOOL showRedPoint = NO;
        
        for (int i = 0; i < _backDressListModel.dressModelArray.count; i++)
        {
            AZDressModel *dressModel = [_backDressListModel.dressModelArray wx_objectAtIndex:i];
            if (dressModel.isNew)
            {
                showRedPoint = YES;
                break;
            }
        }
        
        // 拿到当前的红点视图
        UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + AZDressModelTypeBackDesc];
        redPointView.hidden = !showRedPoint;
    }
    
    // 腰部展示红点判断
    {
        BOOL showRedPoint = NO;
        
        for (int i = 0; i < _waistDressListModel.dressModelArray.count; i++)
        {
            AZDressModel *dressModel = [_waistDressListModel.dressModelArray wx_objectAtIndex:i];
            if (dressModel.isNew)
            {
                showRedPoint = YES;
                break;
            }
        }
        
        // 拿到当前的红点视图
        UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + AZDressModelTypeWaistDesc];
        redPointView.hidden = !showRedPoint;
    }
    
    // 头饰展示红点判断
    {
        BOOL showRedPoint = NO;
        
        for (int i = 0; i < _headDescDressListModel.dressModelArray.count; i++)
        {
            AZDressModel *dressModel = [_headDescDressListModel.dressModelArray wx_objectAtIndex:i];
            if (dressModel.isNew)
            {
                showRedPoint = YES;
                break;
            }
        }
        
        // 拿到当前的红点视图
        UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + AZDressModelTypeHeadDec];
        redPointView.hidden = !showRedPoint;
    }
}

// 刷新红点
- (void)refreshRedPointView
{
    BOOL showRedPoint = NO;
    
    for (int i = 0; i < _currentDressListModel.dressModelArray.count; i++)
    {
        AZDressModel *dressModel = [_currentDressListModel.dressModelArray wx_objectAtIndex:i];
        if (dressModel.isNew)
        {
            showRedPoint = YES;
            break;
        }
    }
    
    // 拿到当前的红点视图
    UIView *redPointView = [self.rightBgView viewWithTag:kRedPointViewBasicTag + (_lastSelectedBtn.tag - kDressTypeBtnBasicTag)];
    redPointView.hidden = !showRedPoint;
}

// 设置其他皮肤选中和红点状态
- (void)resetCellModelStatus:(AZDressModel *)dressModel
{
    // 此时选中的是套装
    if (dressModel.dressType == AZDressModelTypeSuit)
    {
        // 拿到套装中的头部装扮id、上装装扮id、下装装扮id
        NSString *headDressId = nil;
        NSString *upperDressId = nil;
        NSString *lowwerDressId = nil;
        for (AZDressModel *item in dressModel.dressModelArray)
        {
            if (item.dressType == AZDressModelTypeHead)
            {
                headDressId = item.dressId;
            }
            else if (item.dressType == AZDressModelTypeUpperClothing)
            {
                upperDressId = item.dressId;
            }
            else if (item.dressType == AZDressModelTypeLowerClothing)
            {
                lowwerDressId = item.dressId;
            }
        }
        
        //分别将对应装扮设置为选中态
        for (AZDressModel *item in _headDressListModel.dressModelArray)
        {
            if ([headDressId isEqualToString:item.dressId])
            {
                item.isUsed = YES;
                item.isNew = NO;
            }
            else
            {
                item.isUsed = NO;
            }
        }
        
        for (AZDressModel *item in _upperDressListModel.dressModelArray)
        {
            if ([upperDressId isEqualToString:item.dressId])
            {
                item.isUsed = YES;
                item.isNew = NO;
            }
            else
            {
                item.isUsed = NO;
            }
        }
        
        for (AZDressModel *item in _lowerDressListModel.dressModelArray)
        {
            if ([lowwerDressId isEqualToString:item.dressId])
            {
                item.isUsed = YES;
                item.isNew = NO;
            }
            else
            {
                item.isUsed = NO;
            }
        }
    }
    else
    {
        // 此时选中的是非套装，则将套装的选中态改为NO
        for (AZDressModel *item in _suitDressListModel.dressModelArray)
        {
            if (item.isUsed)
            {
                item.isUsed = !item.isUsed;
                break;
            }
        }
    }
}

#pragma mark - Event Handle

// 切换皮肤类型
- (void)switchSkinTypeAction:(UIButton *)sender
{
    if (sender == _lastSelectedBtn)
    {
        return;
    }
    
    //判断scroll滚动方向
    NSInteger lastBtnTag = _lastSelectedBtn.tag != 103?_lastSelectedBtn.tag:99;
    NSInteger btnTag = sender.tag != 103?sender.tag:99;
    BOOL next = lastBtnTag < btnTag;
    
    // 选中态切换
    _lastSelectedBtn.selected = NO;
    sender.selected = YES;
    _lastSelectedBtn = sender;
    
    // 隐藏筛选列表
    _filterButton.selected = NO;
    self.filterListView.hidden = YES;
    
    // 刷新当前的数据源
    [self dressListViewReload];
    if(_rightScrollView.contentSize.height > _rightScrollView.wx_height){
        CGFloat offsetY = _rightScrollView.contentOffset.y + (next?sender.wx_height : (-sender.wx_height));
        offsetY = next? MIN(offsetY, _rightScrollView.contentSize.height - _rightScrollView.wx_height) : MAX(0, offsetY);
        [_rightScrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }
    
    NSInteger type = 2;
    switch (sender.tag - kDressTypeBtnBasicTag)
    {
        case AZDressModelTypeSuit:
        {
            type = 1;
        }
            break;
        case AZDressModelTypeHead:
        {
            type = 2;
        }
            break;
        case AZDressModelTypeUpperClothing:
        {
            type = 3;
        }
            break;
        case AZDressModelTypeLowerClothing:
        {
            type = 4;
        }
            break;
        case AZDressModelTypeHeadDec:
        {
            type = 5;
        }
            break;
        case AZDressModelTypeBackDesc:
        {
            type = 6;
        }
            break;
        case AZDressModelTypeWaistDesc:
        {
            type = 7;
        }
            break;
        default:
            break;
    }
    [WXLog click:@"dress_clothes_tab_click" params:@{@"type" : @(type)}];
}

- (void)filterAction:(UIButton *)sender
{
    [WXLog click:@"dress_clothes_level_screen_click" params:nil];
    
    _filterButton.selected = !_filterButton.isSelected;
    
    if (_filterButton.selected)
    {
        [self.rightBgView.superview addSubview:self.filterListView];
        self.filterListView.hidden = NO;
    }
    else
    {
        self.filterListView.hidden = YES;
    }
}

- (void)filterDressLevelAction:(UIButton *)sender
{
    if (sender == _lastSelectedFilterBtn)
    {
        return;
    }
        
    _lastSelectedFilterBtn.selected = NO;
    sender.selected = YES;
    
    _lastSelectedFilterBtn = sender;
    
    // 更新选中文案并隐藏筛选列表
    NSString *levelName = [[self.filterArray wx_objectAtIndex:_lastSelectedFilterBtn.tag - kDressLevelFilterBtnBasicTag] levelName];
    [_filterButton setTitle:levelName forState:UIControlStateNormal];
    _filterButton.selected = NO;
    self.filterListView.hidden = YES;
    
    // 刷新列表
    [self dressListViewReload];
    
    // 埋点
    {
        NSInteger levelCode = [[self.filterArray wx_objectAtIndex:_lastSelectedFilterBtn.tag - kDressLevelFilterBtnBasicTag] levelCode];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params wx_setObject:@(levelCode) forKey:@"level"];
        [WXLog click:@"dress_clothes_level_choose_click" params:params];
    }
}


#pragma mark - NetWork

// 数据请求
- (void)requestDressData
{
    @WeakObj(self);

    [self.errorView removeFromSuperview];

    [self.loadingView startLoadingInView:self.dressListView];

    NSString *url = [NSString stringWithFormat:@"%@/abc-api/v3/dress/get-all-v2", [AZAppHostConfig getAppDomain]];

    id<EUANetworkProvider> networkProvider = [EpicUnityAdapterManager sharedInstance].networkProvider;
    _networkTask = [networkProvider GET:url parameters:nil headers:nil completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [selfWeak.loadingView removeFromSuperview];
            // 展示失败信息
            [selfWeak.dressListView addSubview:selfWeak.errorView];
            return;
        }

        [selfWeak.loadingView removeFromSuperview];

        [selfWeak parseDataDic:response];

        // 展示rightBgView及筛选Btn
        selfWeak.rightBgView.hidden = NO;
        selfWeak.filterButton.hidden = NO;

        // 刷新dressListView
        [selfWeak dressListViewReload];

        // 红点展示
        [selfWeak showRedPointViewIfNeed];
    }];
}

#pragma mark - AZDressListViewDelegate

- (void)dressListView:(AZDressListView *)listView didSelectDressModel:(AZDressModel *)dressModel
{
    //如果是拆卸饰品
    if(dressModel.canInvert && dressModel.isUsed){
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params wx_setObject:dressModel.dressZipUrl forKey:@"url"];
        [params wx_setObject:dressModel.dressId forKey:@"id"];
        [params wx_setObject:@0 forKey:@"isDefault"];
        [params wx_setObject:dressModel.uAddress forKey:@"uAddress"];
        [params wx_setObject:@(dressModel.bodyPartType) forKey:@"bodyPartType"];
        [params wx_setObject:@(dressModel.cutType) forKey:@"cutType"];
        [params wx_setObject:@(dressModel.decorateType) forKey:@"decorateType"];
        [params wx_setObject:@(dressModel.levelCode) forKey:@"level"];
        [params wx_setObject:dressModel.levelName forKey:@"levelName"];
        [params wx_setObject:@(dressModel.popularityValue) forKey:@"pop"];
        [params wx_setObject:@(1) forKey:@"undecorate"];
        [AZDressUnityBusiness sendToUnityChangeDress:params];
        dressModel.isUsed = NO;
        [listView reloadWithUsedDressModel:nil];
        return;
    }
    
    
    // 重置其他皮肤选中和红点状态
    [self resetCellModelStatus:dressModel];
    
    AZDressModelType dressType = dressModel.dressType;
    
    // 埋点
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params wx_setObject:dressModel.dressId forKey:@"id"];
        [params wx_setObject:dressModel.dressName forKey:@"name"];
        
        NSString *buryId = @"dress_headwear_click";
        if (dressType == AZDressModelTypeUpperClothing)
        {
            buryId = @"dress_clothes_click";
        }
        else if (dressType == AZDressModelTypeLowerClothing)
        {
            buryId = @"dress_pants_click";
        }
        else if (dressType == AZDressModelTypeSuit)
        {
            buryId = @"dress_suit_click";
        }
        
        [WXLog click:buryId params:params];
    }
    
    // 套装逻辑
    if (dressType == AZDressModelTypeSuit)
    {
        NSMutableArray *downloadUrls = [NSMutableArray array];
        for (AZDressModel *item in dressModel.dressModelArray)
        {
            NSString *url = item.dressZipUrl;
            BOOL cacheExist = [AZAvatarUnityZipDownloadTask cacheIsExist:url];
            if (!cacheExist)
            {
                [downloadUrls addObject:url];
            }
        }
        
        if (downloadUrls.count == 0)
        {
            // 不需要下载
            // 下载完成，给unity发换装消息
            [self sendToUnityChangeDress:dressModel];
            
            // 刷新列表
            [listView reloadWithUsedDressModel:dressModel];
        }
        else
        {
            [self.loadingView startLoadingInView:self.dressListView.superview];

            [[AZAvatarUnityZipDownloadTaskQueue sharedInstance] downloadUrls:downloadUrls completionHandler:^(NSError *error) {
                // 切换主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.loadingView removeFromSuperview];
                    
                    if (error)
                    {
                        [WXToastView showToastWithTitle:@"换装失败~"];
                    }
                    else
                    {
                        // 下载完成，给unity发换装消息
                        [self sendToUnityChangeDress:dressModel];
                        
                        // 刷新列表
                        [listView reloadWithUsedDressModel:dressModel];
                    }
                });
            }];
        }
    }
    else
    {
        // 非套装逻辑
        NSString *zipUrl = dressModel.dressZipUrl;
        // cache是否存在
        BOOL cacheExist = [AZAvatarUnityZipDownloadTask cacheIsExist:zipUrl];
        if (cacheExist)
        {
            // 直接给unity发换装消息
            [self sendToUnityChangeDress:dressModel];
            
            // 刷新列表
            [listView reloadWithUsedDressModel:dressModel];
        }
        else
        {
            [self.loadingView startLoadingInView:self.dressListView.superview];
            [AZAvatarUnityZipDownloadTask downloadUrl:zipUrl completionHandler:^(NSError *error) {
                // 切回到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.loadingView removeFromSuperview];
                    
                    if (error)
                    {
                        [WXToastView showToastWithTitle:@"换装失败~"];
                    }
                    else
                    {
                        // 下载完成，给unity发换装消息
                        [self sendToUnityChangeDress:dressModel];
                        
                        // 刷新列表
                        [listView reloadWithUsedDressModel:dressModel];
                    }
                });
            }];
        }
    }
        
    // 刷新红点
    [self refreshRedPointView];
}

#pragma mark - Getter

- (UIView *)rightBgView
{
    if (_rightBgView == nil)
    {
        _rightBgView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen wx_currentScreenWidth] - kRightBgViewWidthValue, 0, kRightBgViewWidthValue, [UIScreen wx_currentScreenHeight])];
        _rightBgView.backgroundColor = [UIColor wx_colorWithHEXValue:0x113F87 alpha:0.5];
        UIScrollView *btnScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, kFirstSkinTypeBtnTopValue, kRightBgViewWidthValue, _rightBgView.wx_height - (2*kFirstSkinTypeBtnTopValue))];
        [_rightBgView addSubview:btnScrollView];
        _rightBgView.layer.masksToBounds = NO;
        btnScrollView.contentSize = CGSizeMake(kRightBgViewWidthValue, self.dressTypeArray.count * kDressTypeButtonHeightValue);
        btnScrollView.layer.masksToBounds = NO;
        self.rightScrollView = btnScrollView;
        CGFloat originY = 0;
        for (int i = 0; i < self.dressTypeArray.count; i++)
        {
            NSString *imgName = [[self.dressTypeArray wx_objectAtIndex:i] wx_stringForKey:@"img"];
            NSString *bgImgName = [[self.dressTypeArray wx_objectAtIndex:i] wx_stringForKey:@"bgimg"];
            AZDressModelType dressType = [[self.dressTypeArray wx_objectAtIndex:i] wx_integerForKey:@"type"];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(kRightBgViewWidthValue - kDressTypeButtonWidthValue, originY, kDressTypeButtonWidthValue, kDressTypeButtonHeightValue);
            btn.tag = kDressTypeBtnBasicTag + dressType;
            [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:bgImgName] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(switchSkinTypeAction:) forControlEvents:UIControlEventTouchUpInside];
            if (dressType == AZDressModelTypeHead)
            {
                btn.selected = YES;
                _lastSelectedBtn = btn;
            }
            else
            {
                btn.selected = NO;
            }
            originY += kDressTypeButtonHeightValue;
            [btnScrollView addSubview:btn];
            
            // 添加红点逻辑
            {
                CGFloat width = 8;
                CGFloat height = 8;
                UIView *redPointView = [[UIView alloc] initWithFrame:CGRectMake(btn.imageView.wx_right - width, btn.imageView.wx_top, width, height)];
                redPointView.backgroundColor = [UIColor wx_colorWithHEXValue:0xff4242];
                redPointView.layer.cornerRadius = width / 2;
                redPointView.layer.borderColor = [UIColor whiteColor].CGColor;
                redPointView.layer.borderWidth = 1.5;
                redPointView.layer.masksToBounds = YES;
                redPointView.hidden = YES;
                redPointView.tag = kRedPointViewBasicTag + dressType;
                
                [btn addSubview:redPointView];
            }
        }
    }
    return _rightBgView;
}

- (AZDressListView *)dressListView
{
    if (_dressListView == nil)
    {
        CGFloat y = kDressViewTopValue - [AZDressListView classifyViewWidth];
        _dressListView = [[AZDressListView alloc] initWithFrame:CGRectMake([UIScreen wx_currentScreenWidth] - self.rightBgView.wx_width - 16 - [AZDressListView viewWidth], y, [AZDressListView viewWidth], [UIScreen wx_currentScreenHeight] - y - 11)];
        _dressListView.delegate = self;
    }
    return _dressListView;
}

- (UIButton *)filterButton
{
    if (_filterButton == nil)
    {
        CGFloat width = 58;
        CGFloat height = 23;
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterButton.frame = CGRectMake(self.dressListView.wx_right - width, self.dressListView.wx_top + ([AZDressListView classifyViewWidth] - height) / 2, width, height);
        _filterButton.backgroundColor = [UIColor wx_colorWithHEXValue:0x000000 alpha:0.3];
        _filterButton.layer.cornerRadius = height / 2;
        _filterButton.layer.masksToBounds = YES;
        [_filterButton setImage:[UIImage imageNamed:@"az_dress_filter_down_icon"] forState:UIControlStateNormal];
        [_filterButton setImage:[UIImage imageNamed:@"az_dress_filter_up_icon"] forState:UIControlStateSelected];
        [_filterButton setTitle:@"全部" forState:UIControlStateNormal];
        [_filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _filterButton.titleLabel.font = [UIFont wx_fontPingFangSCWithSize:12];
        [_filterButton wx_adjustUIButtonImageAndLabel:WXButtonLayoutImageRightWordLeft andSpacing:2];
        _filterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_filterButton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterButton;
}

- (UIView *)filterListView
{
    if (_filterListView == nil)
    {
        CGFloat btnTop = 6;
        CGFloat btnWidth = 58;
        CGFloat btnHeight = 24;
        _filterListView = [[UIView alloc] initWithFrame:CGRectMake(self.filterButton.wx_left, self.dressListView.wx_top + [AZDressListView classifyViewWidth], btnWidth, self.filterArray.count * btnHeight + btnTop * 2)];
        _filterListView.backgroundColor = [UIColor wx_colorWithHEXValue:0x1b2b3b alpha:0.8];
        
        CGFloat originY = btnTop;
        for (int i = 0; i < self.filterArray.count; i++)
        {
            AZDressLevelModel *levelModel = [self.filterArray wx_objectAtIndex:i];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, originY, btnWidth , btnHeight);
            btn.tag = kDressLevelFilterBtnBasicTag + i;
            [btn setTitle:levelModel.levelName forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont wx_fontPingFangSCWithSize:12];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor wx_FontGrayColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage wx_imageFromColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage wx_imageFromColor:[UIColor wx_colorWithHEXValue:0xfff500]] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(filterDressLevelAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [_filterListView addSubview:btn];
            
            if (levelModel.levelCode == -1)
            {
                // 和后端约定, levelCode = -1代表全部
                btn.selected = YES;
                _lastSelectedFilterBtn = btn;
            }
            
            originY += btnHeight;
        }
        
        _filterListView.layer.cornerRadius = 4;
        _filterListView.layer.masksToBounds = YES;
        
    }
    return _filterListView;
}

- (LoadingView *)loadingView
{
    if (_loadingView == nil)
    {
        _loadingView = [[LoadingView alloc] init];
        _loadingView.bgColorType = BackgroundColorTypeTransparent;
    }
    return _loadingView;
}

- (ErrorView *)errorView
{
    if (_errorView == nil)
    {
        @WeakObj(self);
        _errorView = [ErrorView errorView];
        _errorView.frame = self.dressListView.bounds;
        _errorView.forceErrorContentViewHalfRender = YES;
        [_errorView setCustomBackgroundColor:[UIColor clearColor]];
        _errorView.clipsToBounds = YES;
        [_errorView setRetryBlock:^{
            // 重试
            [selfWeak requestDressData];
        }];
    }
    return _errorView;
}

- (NSArray *)dressTypeArray
{
    if (_dressTypeArray == nil)
    {
        NSString *bgimg = @"az_dress_type_selected";
        _dressTypeArray = @[
            @{
                @"type" : @(AZDressModelTypeSuit),
                @"img" : @"az_dress_suit_image",
                @"bgimg" : bgimg,
            },
            @{
                @"type" : @(AZDressModelTypeHead),
                @"img" : @"az_dress_header_image",
                @"bgimg" : bgimg,
            },
            @{
                @"type" : @(AZDressModelTypeUpperClothing),
                @"img" : @"az_dress_upper_image",
                @"bgimg" : bgimg,
            },
            @{
                @"type" : @(AZDressModelTypeLowerClothing),
                @"img" : @"az_dress_lower_image",
                @"bgimg" : bgimg,
            },
            @{
                @"type" : @(AZDressModelTypeBackDesc),
                @"img" : @"az_dress_back_image",
                @"bgimg" : bgimg,
            },
            @{
                @"type" : @(AZDressModelTypeWaistDesc),
                @"img" : @"az_dress_waist_image",
                @"bgimg" : bgimg,
            },
            @{
                @"type" : @(AZDressModelTypeHeadDec),
                @"img" : @"az_dress_head_desc_image",
                @"bgimg" : bgimg,
            },
        ];
    }
    return _dressTypeArray;
}

- (NSMutableArray *)filterArray
{
    if (_filterArray == nil)
    {
        _filterArray = [NSMutableArray arrayWithCapacity:42];
    }
    return _filterArray;
}

@end
