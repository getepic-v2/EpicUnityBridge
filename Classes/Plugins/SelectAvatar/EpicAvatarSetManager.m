//
//  EpicAvatarSetManager.m
//  EpicUnityBridge
//
//  User avatar/appearance set manager.
//

#import "EpicAvatarSetManager.h"
#import "EpicSignInUnityBusiness.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import <EpicUnityAdapter/EpicUnityAdapterManager.h>

@interface EpicAvatarSetManager ()

/// Avatar list view
@property (nonatomic, strong, nullable) UIView *avatarListView;

/// Title label
@property (nonatomic, strong, nullable) UILabel *titleLabel;

/// Loading indicator
@property (nonatomic, strong, nullable) UIActivityIndicatorView *loadingIndicator;

/// Avatar data
@property (nonatomic, strong, nullable) NSDictionary *avatarData;

@end

@implementation EpicAvatarSetManager

#pragma mark - Singleton

+ (instancetype)sharedInstance {
    static EpicAvatarSetManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EpicAvatarSetManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (void)showAvatarListViewInParentView:(UIView *)parentView {
    if (!parentView) {
        NSLog(@"[EpicAvatarSetManager] parentView is nil");
        return;
    }

    NSLog(@"[EpicAvatarSetManager] showAvatarListViewInParentView");

    [parentView addSubview:self.avatarListView];
    [parentView addSubview:self.titleLabel];

    // Request avatar data
    [self requestAvatarInfoData];
}

- (void)removeAvatarListView {
    NSLog(@"[EpicAvatarSetManager] removeAvatarListView");

    [_avatarListView removeFromSuperview];
    _avatarListView = nil;

    [_titleLabel removeFromSuperview];
    _titleLabel = nil;

    [_loadingIndicator stopAnimating];
    [_loadingIndicator removeFromSuperview];
    _loadingIndicator = nil;
}

- (void)requestAvatarInfoData {
    NSLog(@"[EpicAvatarSetManager] requestAvatarInfoData");

    // Show loading
    [self showLoading];

    // TODO: Implement actual network request to fetch avatar data
    // For now, simulate a successful response after a delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];
        [self setupAvatarListWithData:nil];
    });
}

#pragma mark - Notification Handlers

- (void)applicationDidBecomeActive {
    // Resume any paused media if needed
}

#pragma mark - Private Methods

- (void)showLoading {
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _loadingIndicator.color = [UIColor whiteColor];
    }
    _loadingIndicator.center = self.avatarListView.center;
    [self.avatarListView addSubview:_loadingIndicator];
    [_loadingIndicator startAnimating];
}

- (void)hideLoading {
    [_loadingIndicator stopAnimating];
    [_loadingIndicator removeFromSuperview];
}

- (void)setupAvatarListWithData:(NSDictionary *)data {
    NSLog(@"[EpicAvatarSetManager] setupAvatarListWithData");

    self.avatarData = data;

    // TODO: Setup avatar list UI with data
    // This is where you would create collection views or buttons for avatar selection
}

#pragma mark - Avatar Selection Actions

- (void)didSelectHeadAvatar:(NSDictionary *)avatarInfo {
    NSLog(@"[EpicAvatarSetManager] didSelectHeadAvatar: %@", avatarInfo);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"id"] = avatarInfo[@"id"] ?: @"";
    params[@"url"] = avatarInfo[@"url"] ?: @"";
    params[@"isDefault"] = @0;
    params[@"uAddress"] = avatarInfo[@"uAddress"] ?: @"";
    params[@"bodyPartType"] = avatarInfo[@"bodyPartType"] ?: @0;
    params[@"cutType"] = avatarInfo[@"cutType"] ?: @0;
    params[@"decorateType"] = avatarInfo[@"decorateType"] ?: @0;

    [EpicSignInUnityBusiness sendToUnityChangeHead:params];
}

- (void)didSelectFaceAvatar:(NSDictionary *)avatarInfo isSkin:(BOOL)isSkin {
    NSLog(@"[EpicAvatarSetManager] didSelectFaceAvatar: %@, isSkin: %d", avatarInfo, isSkin);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // faceType: 1 = expression, 2 = skin
    params[@"faceType"] = isSkin ? @2 : @1;
    params[@"index"] = avatarInfo[@"id"] ?: @"";

    [EpicSignInUnityBusiness sendToUnityChangeFace:params];
}

- (void)didSelect2DHeadPic:(NSString *)avatarUrl {
    NSLog(@"[EpicAvatarSetManager] didSelect2DHeadPic: %@", avatarUrl);

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"url"] = avatarUrl ?: @"";

    [EpicSignInUnityBusiness sendToUnityChange2DHeadPic:params];
}

- (void)confirmAvatarSelectionWithNickName:(NSString *)nickName {
    NSLog(@"[EpicAvatarSetManager] confirmAvatarSelectionWithNickName: %@", nickName);

    if (nickName.length == 0) {
        NSLog(@"[EpicAvatarSetManager] nickname is empty");
        return;
    }

    [self showLoading];

    // TODO: Implement actual network request to save avatar and nickname
    // For now, simulate a successful response
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideLoading];

        // Notify Unity that nickname has been set
        [EpicSignInUnityBusiness sendNickNameSetSuccessfulMsgToUnity];

        // Remove avatar list view
        [self removeAvatarListView];
    });
}

#pragma mark - Getters

- (UIView *)avatarListView {
    if (!_avatarListView) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat width = screenWidth / 2;
        CGFloat originX = screenWidth - width;

        _avatarListView = [[UIView alloc] initWithFrame:CGRectMake(originX, 0, width, screenHeight)];
        _avatarListView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _avatarListView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat x = 60;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 14, screenWidth - 2 * x, 28)];
        _titleLabel.text = @"Select Avatar";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    }
    return _titleLabel;
}

@end
