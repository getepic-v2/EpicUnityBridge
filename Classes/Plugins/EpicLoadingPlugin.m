//
//  EpicLoadingPlugin.m
//  EpicUnityBridge
//

#import "EpicLoadingPlugin.h"
#import <NTUnityIn/NTUnityInSDK.h>

@interface EpicLoadingPlugin () <NTUSDKPluginDelegate>

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;

@end

@implementation EpicLoadingPlugin

- (instancetype)init {
    if (self = [super init]) {
        _loadingView = [[UIView alloc] init];
        _loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        _loadingView.userInteractionEnabled = YES;

        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _activityIndicator.color = [UIColor whiteColor];
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [_loadingView addSubview:_activityIndicator];

        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.textColor = [UIColor whiteColor];
        _loadingLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_loadingView addSubview:_loadingLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_activityIndicator.centerXAnchor constraintEqualToAnchor:_loadingView.centerXAnchor],
            [_activityIndicator.centerYAnchor constraintEqualToAnchor:_loadingView.centerYAnchor constant:-20],
            [_loadingLabel.centerXAnchor constraintEqualToAnchor:_loadingView.centerXAnchor],
            [_loadingLabel.topAnchor constraintEqualToAnchor:_activityIndicator.bottomAnchor constant:16],
        ]];
    }
    return self;
}

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.buss.ABCLoading.show",
        @"app.buss.ABCLoading.hide",
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.buss.ABCLoading.show"]) {
        UIView *contextView = [NTUnityInSDK shareInstance].sceneContextView;
        if (!contextView) return;

        self.loadingLabel.text = reqEntity.params[@"msg"];
        self.loadingView.frame = contextView.bounds;
        self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [contextView addSubview:self.loadingView];
        [self.activityIndicator startAnimating];

    } else if ([msgKey isEqualToString:@"app.buss.ABCLoading.hide"]) {
        [self.activityIndicator stopAnimating];
        [self.loadingView removeFromSuperview];
    }
}

@end
