//
//  EpicAvatarSetManager.m
//  EpicUnityBridge
//
//  User avatar/appearance set manager.
//

#import "EpicAvatarSetManager.h"
#import "AZUserAvtarListView.h"
#import "AZUserAvatarListModel.h"
#import "EpicSignInUnityBusiness.h"
#import <EpicWXCommonKit/WXMediaPlayer.h>

@interface EpicAvatarSetManager () <AZUserAvtarListViewDelegate, WXMediaPlayerDelegate>

@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) ErrorView *errorView;
@property (nonatomic, strong) AZUserAvtarListView *avatarListView;
@property (nonatomic, strong) AZUserAvatarListModel *avatarListModel;
@property (nonatomic, strong) WXMediaPlayer *mediaPlayer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL isAvatarSetSuccess;
@property (nonatomic, strong) NSDictionary *accountTipDic;

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
        return;
    }
    [parentView addSubview:self.avatarListView];
    [parentView addSubview:self.titleLabel];
}

- (void)removeAvatarListView {
    [_avatarListView removeFromSuperview];
    _avatarListView = nil;

    [_titleLabel removeFromSuperview];
    _titleLabel = nil;
}

#pragma mark - Notification Handle

- (void)applicationDidBecomeActive {
    if (_mediaPlayer) {
        [_mediaPlayer play];
    }
}

#pragma mark - WXMediaPlayerDelegate

- (void)playerDidPlayFinished:(WXMediaPlayer *)player {
    [self mediaPlayerRelease];
}

- (void)player:(WXMediaPlayer *)player playError:(NSString *)errorMsg errCode:(NSInteger)errCode {
    [self mediaPlayerRelease];
}

#pragma mark - Private Methods

- (void)mediaPlayerRelease {
    [_mediaPlayer pause];
    _mediaPlayer = nil;
}

- (void)playGuideVoice:(NSString *)url {
    if (url.length > 0) {
        _mediaPlayer = [WXMediaPlayer playerWithPlayView:nil playerType:WXMediaPlayerEngineTypeAVPlayer];
        [_mediaPlayer playWithVideoURL:[NSURL URLWithString:url]];
        _mediaPlayer.delegate = self;
    }
}

- (void)requestAccountInterworking {
    NSString *url = [NSString stringWithFormat:@"%@/%@", [AZAppHostConfig getAppDomain], @"abc-api/sign/tcm/get-merge-user-config"];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params wx_setObject:@(1) forKey:@"scene"];

    // Header info
    long long timeInterval = (long long)[[NSDate date] timeIntervalSince1970];
    NSString *timeIntervalStr = [NSString stringWithFormat:@"%lld", timeInterval];
    NSString *appId = @"20008001";
    NSString *appKey = @"12ba1b5c8af4d7dffb1ece09fxxac6936";
    NSString *sign = [[NSString stringWithFormat:@"%@&%@%@", appId, timeIntervalStr, appKey] wx_md5String];

    NSDictionary *headers = @{
        @"appid": appId,
        @"timestamp": timeIntervalStr,
        @"sign": sign
    };

    @WeakObj(self);
    id<EUANetworkProvider> networkProvider = [EpicUnityAdapterManager sharedInstance].networkProvider;
    [networkProvider POST:url parameters:params headers:headers completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (!error && response) {
            selfWeak.accountTipDic = response;
            if (selfWeak.isAvatarSetSuccess) {
                [selfWeak updateAccountTip];
            }
        }
    }];
}

- (void)updateAccountTip {
    BOOL isShow = [self.accountTipDic wx_boolForKey:@"can_modify"];
    NSString *content = [self.accountTipDic wx_stringForKey:@"content"];
    if (content && [content isKindOfClass:[NSString class]] && content.length > 0) {
        [self.avatarListView setAccountTip:content isShow:isShow];
    } else {
        [self.avatarListView setAccountTip:@"" isShow:isShow];
    }
}

- (void)requestAvatarInfoData {
    self.accountTipDic = nil;
    self.isAvatarSetSuccess = NO;
    [self requestAccountInterworking];

    [self.errorView removeFromSuperview];
    [self.loadingView startLoadingInView:self.avatarListView];

    @WeakObj(self);
    [self _requestAvatarInfoDataSuccessBlock:^(NSDictionary *responseData) {
        [selfWeak.loadingView removeFromSuperview];

        // Show avatarListView
        [selfWeak.avatarListView setupAvatarListModel:selfWeak.avatarListModel];

        selfWeak.isAvatarSetSuccess = YES;
        if (selfWeak.accountTipDic) {
            [selfWeak updateAccountTip];
        }

        // Play guide audio
        [selfWeak playGuideVoice:selfWeak.avatarListModel.guideAudioUrl];

        // Trigger initial avatar downloads
        dispatch_async(dispatch_get_main_queue(), ^{
            // Find selected package
            for (AZUserAvtarModel *item in selfWeak.avatarListModel.packageModelArray) {
                if (item.isSelected) {
                    [selfWeak downloadHeadAvatar:item];
                    break;
                }
            }

            // Find selected expression
            for (AZUserAvtarModel *item in selfWeak.avatarListModel.expressionModelArray) {
                if (item.isSelected) {
                    [selfWeak sendToUnityChangeFace:item];
                    break;
                }
            }

            // Find selected skin
            for (AZUserAvtarModel *item in selfWeak.avatarListModel.skinModelArray) {
                if (item.isSelected) {
                    [selfWeak sendToUnityChangeFace:item];
                    break;
                }
            }
        });

    } failureBlock:^(NSError *error) {
        [selfWeak.loadingView removeFromSuperview];
        [selfWeak.avatarListView addSubview:selfWeak.errorView];
    }];
}

- (void)_requestAvatarInfoDataSuccessBlock:(void (^)(NSDictionary *responseData))successBlock
                              failureBlock:(void (^)(NSError *error))failureBlock {
    NSString *url = [NSString stringWithFormat:@"%@/abc-api/v3/dress/get-default", [AZAppHostConfig getAppDomain]];

    @WeakObj(self);
    id<EUANetworkProvider> networkProvider = [EpicUnityAdapterManager sharedInstance].networkProvider;
    [networkProvider GET:url parameters:nil headers:nil completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failureBlock) {
                failureBlock(error);
            }
            return;
        }

        // Parse response to model
        selfWeak.avatarListModel = [[AZUserAvatarListModel alloc] init];
        [selfWeak.avatarListModel yy_modelSetWithDictionary:response];

        if (successBlock) {
            successBlock(response);
        }
    }];
}

- (void)downloadHeadAvatar:(AZUserAvtarModel *)avatarModel {
    NSString *zipUrl = avatarModel.avatarZipUrl;
    if (zipUrl.length == 0) {
        return;
    }

    // Check if cache exists - use simple file check for now
    NSString *cacheKey = [zipUrl wx_md5String];
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:cacheKey];
    BOOL cacheExist = [[NSFileManager defaultManager] fileExistsAtPath:cachePath];

    if (cacheExist) {
        [self sendToUnityChangeHead:avatarModel];
    } else {
        [self.loadingView startLoadingInView:self.avatarListView.superview];

        // Download zip file
        @WeakObj(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:zipUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfWeak.loadingView removeFromSuperview];
                if (data) {
                    [data writeToFile:cachePath atomically:YES];
                    [selfWeak sendToUnityChangeHead:avatarModel];
                } else {
                    [WXToastView showToastWithTitle:@"Avatar download failed"];
                }
            });
        });
    }
}

- (void)sendToUnityChangeHead:(AZUserAvtarModel *)avatarModel {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params wx_setObject:[NSString stringWithFormat:@"%@", avatarModel.avatarId] forKey:@"id"];
    [params wx_setObject:avatarModel.avatarZipUrl forKey:@"url"];
    [params wx_setObject:@0 forKey:@"isDefault"];
    [params wx_setObject:avatarModel.uAddress forKey:@"uAddress"];
    [params wx_setObject:@(avatarModel.bodyPartType) forKey:@"bodyPartType"];
    [params wx_setObject:@(avatarModel.cutType) forKey:@"cutType"];
    [params wx_setObject:@(avatarModel.decorateType) forKey:@"decorateType"];

    [EpicSignInUnityBusiness sendToUnityChangeHead:params];
}

- (void)sendToUnityChangeFace:(AZUserAvtarModel *)avatarModel {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    if (avatarModel.avatarType == AZUserAvtarModelTypeSkin) {
        [params wx_setObject:@2 forKey:@"faceType"];
    } else if (avatarModel.avatarType == AZUserAvtarModelTypeExpression) {
        [params wx_setObject:@1 forKey:@"faceType"];
    }

    [params wx_setObject:avatarModel.avatarId forKey:@"index"];

    [EpicSignInUnityBusiness sendToUnityChangeFace:params];
}

#pragma mark - AZUserAvtarListViewDelegate

- (void)userAvatarListView:(AZUserAvtarListView *)avatarListView didSelectAvater:(AZUserAvtarModel *)avatarModel {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (avatarModel.avatarType == AZUserAvtarModelTypeExpression) {
        [params wx_setObject:avatarModel.avatarId forKey:@"type2"];
    } else {
        [params wx_setObject:avatarModel.avatarId forKey:@"type3"];
    }
    [WXLog click:@"image_type_click" params:params];

    if (avatarModel.avatarType == AZUserAvtarModelType2DHeadPic) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params wx_setObject:avatarModel.avatarCoverUrl forKey:@"url"];
        [EpicSignInUnityBusiness sendToUnityChange2DHeadPic:params];
    } else {
        [self sendToUnityChangeFace:avatarModel];
    }
}

- (void)userAvatarListView:(AZUserAvtarListView *)avatarListView
    didSelectPackageAvater:(AZUserAvtarModel *)avatarModel
                expression:(AZUserAvtarModel *)expressionModel {
    // Analytics
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params wx_setObject:avatarModel.avatarId forKey:@"type1"];
    [WXLog click:@"image_type_click" params:params];

    [self downloadHeadAvatar:avatarModel];

    if (expressionModel) {
        [self sendToUnityChangeFace:expressionModel];
    }
}

- (void)userAvatarListView:(AZUserAvtarListView *)avatarListView
   confirmSelectedDressIds:(NSArray *)dressIds
                 headPicId:(NSNumber *)headPicId
                  nickName:(NSString *)nickName
              isRecommmend:(BOOL)isRecommend {
    // Analytics
    [WXLog click:@"image_continue_click" params:nil];

    if (nickName.length == 0) {
        [WXToastView showToastWithTitle:@"Nickname cannot be empty"];
        return;
    }

    [self.loadingView startLoadingInView:self.avatarListView.superview];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *url = [NSString stringWithFormat:@"%@/abc-api/v3/dress/set-default-nickname", [AZAppHostConfig getAppDomain]];

    [params wx_setObject:nickName forKey:@"nickname"];
    [params wx_setObject:dressIds forKey:@"dress_id"];

    @WeakObj(self);
    id<EUANetworkProvider> networkProvider = [EpicUnityAdapterManager sharedInstance].networkProvider;
    [networkProvider POST:url parameters:params headers:nil completion:^(NSDictionary * _Nullable response, NSError * _Nullable error) {
        [selfWeak.loadingView removeFromSuperview];

        if (error) {
            // Error analytics
            NSMutableDictionary *attachmentDic = [NSMutableDictionary dictionary];
            [attachmentDic wx_setObject:@(error.code) forKey:@"errorcode"];
            [attachmentDic wx_setObject:error.localizedDescription forKey:@"errormsg"];
            [attachmentDic wx_setObject:nickName forKey:@"nickname"];

            if (isRecommend) {
                [WXLog sys:@"abc_recommendnickname_sensitive" label:@"" attachmentDic:attachmentDic];
            } else {
                [WXLog sys:@"abc_setnickname_error" label:@"" attachmentDic:attachmentDic];
            }

            [WXToastView showToastWithTitle:error.localizedDescription ?: @"Failed to save"];
            return;
        }

        // Success analytics
        [WXLog show:@"image_continue_success" params:nil];

        // Release media player
        [selfWeak mediaPlayerRelease];

        // Save user info locally
        // TODO: Implement user info storage via EpicUnityAdapter

        // Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kUserNickNameDidSetSuccessfulNotification" object:nil];

        // Remove avatar list view
        [selfWeak removeAvatarListView];
    }];
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat x = 60;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 14, kCurrentScreenWidth - 2 * x, 28)];
        _titleLabel.text = @"Select Avatar";
        _titleLabel.textColor = [UIColor wx_colorWithHEXValue:0xffffff];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont wx_fontPingFangSCMediumWithSize:20];
    }
    return _titleLabel;
}

- (AZUserAvtarListView *)avatarListView {
    if (!_avatarListView) {
        CGFloat width = kCurrentScreenWidth / 2;
        CGFloat originX = kCurrentScreenWidth - width;
        _avatarListView = [[AZUserAvtarListView alloc] initWithFrame:CGRectMake(originX, 0, width, kCurrentScreenHeight)];
        _avatarListView.delegate = self;
    }
    return _avatarListView;
}

- (LoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[LoadingView alloc] init];
        _loadingView.bgColorType = BackgroundColorTypeTransparent;
    }
    return _loadingView;
}

- (ErrorView *)errorView {
    if (!_errorView) {
        @WeakObj(self);
        _errorView = [ErrorView errorView];
        _errorView.frame = self.avatarListView.bounds;
        _errorView.forceErrorContentViewHalfRender = YES;
        [_errorView setCustomBackgroundColor:[UIColor clearColor]];
        _errorView.clipsToBounds = YES;
        [_errorView setRetryBlock:^{
            [selfWeak requestAvatarInfoData];
        }];
    }
    return _errorView;
}

@end
