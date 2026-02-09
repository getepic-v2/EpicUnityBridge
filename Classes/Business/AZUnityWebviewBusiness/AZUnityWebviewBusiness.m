//
//  AZUnityWebviewBusiness.m
//  AZAppConfig
//
//  Created by wangyiyang on 2023/8/12.
//

#import "AZUnityWebviewBusiness.h"
#import <NTUnityIn/NTUnityInSDK.h>

#import "AZJsBridge.h"
#import "WKWebView+WXExtension.h"

static NSString * const kUnityBridgeKey = @"WXJsBridge";

@interface AZUnityWebviewBusiness () <NTUSDKPluginDelegate, WKNavigationDelegate, TScriptMessageHandler, WXJsBridgeDelegate, AZJsBridgeDelegate>

@property (nonatomic, strong) WKWebView *webview;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *reloadBtn;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) AZJsBridge *jsBridge;

@end

@implementation AZUnityWebviewBusiness

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.buss.webview.open",
        @"app.buss.webview.close",
        @"app.buss.webview.calljs",
        @"app.buss.webview.hide"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.buss.webview.open"]) {
        if (self.webview) {
            [self closeWebview];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self openWebView:reqEntity];
            });
        } else {
            [self openWebView:reqEntity];
        }
    } else if ([msgKey isEqualToString:@"app.buss.webview.close"]) {
        [self closeWebview];
        [reqEntity callback:^NSDictionary * _Nonnull{
            return @{
                @"status" : @"success"
            };
        }];
    } else if ([msgKey isEqualToString:@"app.buss.webview.calljs"]){
        NSString *jsFunc = [reqEntity.params wx_stringForKey:@"method_name"];
        NSString *jsParam = [reqEntity.params wx_stringForKey:@"method_param_str"];
        jsParam = jsParam ? [NSString stringWithFormat:@"'%@'",jsParam] : @"";
        NSString *javeScript = [NSString stringWithFormat:@"%@(%@);",jsFunc, jsParam];
        XESLog(@"cyh--unity=>Js:%@",javeScript);
        [self.webview evaluateJavaScript:javeScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if(!error && result){
                [reqEntity callback:^NSDictionary * _Nonnull{
                    return @{@"ret":result};
                }];
            }
            if(error){
//                [WXLog sys:@"NextLiveWebviewLog" label:@"调用js报错" attachment:[NSString stringWithFormat:@"%@", error]];
            }
        }];
    } else if ([msgKey isEqualToString:@"app.buss.webview.hide"]) {
        if([reqEntity.params objectForKey:@"is_show"]){
            BOOL isShow = [reqEntity.params wx_boolForKey:@"is_show"];
            _webview.hidden = !isShow;
        }
    }
}

#pragma mark - WXJsBridgeDelegate
- (void)webViewClose {
    [self closeWebview];
}

#pragma mark - AZJsBridgeDelegate
- (void)hideNativeCloseBtn:(BOOL)hidden {
    self.closeBtn.hidden = hidden;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self.loadingView stopLoading];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.loadingView stopLoading];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.loadingView stopLoading];
//    [WXLog info:@"AZUnityWebviewError" label:@"加载H5失败" attachment:error.description];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.closeBtn.hidden = NO;
    if (error.code == 102) return;
    // bugfix:引流跳到appstore不关闭web页面，防止聊天区不能恢复
    [self closeWebview];
    [WXToastView showToastWithTitle:error.localizedDescription];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    self.closeBtn.hidden = NO;
    [self closeWebview];
    [WXToastView showToastWithTitle:@"内存不足，网页被关闭。"];
}

-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name isEqualToString:kUnityBridgeKey]){
           
        NSString *paramJson = message.body;
        id param = paramJson;
        if([paramJson isKindOfClass:[NSString class]]){
           id paramObj = [paramJson wx_JSONValue];
            if(paramObj){
                param = paramObj;
            }
        }
        XESLog(@"cyh--js=>Untiy:%@",[param JSONRepresentation]);
            [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:@"app.buss.webview.jssend" params:param callback:nil];
    }
}

#pragma mark - Private Method
- (void)openWebView:(NTUnityMsgEntity *)reqEntity {
//    //检测设备内存
//    double freeMem = [WXAPMPerTool systemFreeMemory];
//    if (freeMem > 0 && freeMem < 200 * 1024 * 1024) {
//        //如果剩余内存小于200M，直接不弹出
//        [WXLog sys:@"NextLiveWebviewLog" label:@"内存不足不弹出" attachment:[NSString stringWithFormat:@"剩余%fM", freeMem / 1024 / 1024]];
//        [reqEntity callback:^NSDictionary * _Nonnull{
//            return @{
//                @"status" : @"failure"
//            };
//        }];
//        return;
//    }
    BOOL showCloseBtn = YES;
    if([reqEntity.params.allKeys containsObject:@"show_close_btn"]){
        showCloseBtn = [reqEntity.params wx_boolForKey:@"show_close_btn"];
    }
    BOOL clearCache = [reqEntity.params wx_boolForKey:@"clear_cache"];
    NSString *url = [reqEntity.params wx_stringForKey:@"url"];
    NSArray *position = [reqEntity.params wx_arrayForKey:@"position"];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x = [[position wx_numberAtIndex:0] floatValue] / scale;
    CGFloat y = [[position wx_numberAtIndex:1] floatValue] / scale;
    CGFloat width = [[position wx_numberAtIndex:2] floatValue] / scale;
    CGFloat height = [[position wx_numberAtIndex:3] floatValue] / scale;
    
    NSArray *normalizedPosition = [reqEntity.params wx_arrayForKey:@"normalizedPosition"];
    CGFloat screenW = MAX([UIScreen wx_currentScreenWidth], [UIScreen wx_currentScreenHeight]);
    CGFloat screenH = MIN([UIScreen wx_currentScreenWidth], [UIScreen wx_currentScreenHeight]);
    if (normalizedPosition) {
        x = [[normalizedPosition wx_numberAtIndex:0] floatValue] * screenW;
        y = [[normalizedPosition wx_numberAtIndex:1] floatValue] * screenH;
        width = [[normalizedPosition wx_numberAtIndex:2] floatValue] * screenW;
        height = [[normalizedPosition wx_numberAtIndex:3] floatValue] * screenH;
    }
    
    [[NTUnityInSDK shareInstance].sceneContextView addSubview:self.webview];
    self.webview.frame = CGRectMake(x, y, width, height);
    self.closeBtn.hidden = !showCloseBtn;
    if ([url hasPrefix:@"www"]) {
        url = [@"https://" stringByAppendingString:url];
    }

    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:clearCache?NSURLRequestReloadIgnoringCacheData: NSURLRequestUseProtocolCachePolicy  timeoutInterval:60]];
    [self.loadingView startLoadingInView:self.webview];
    [reqEntity callback:^NSDictionary * _Nonnull{
        return @{
            @"status" : @"success"
        };
    }];
}

- (void)closeWebview {
    [self.webview removeFromSuperview];
    self.webview = nil;
    self.jsBridge = nil;
    [[NTUSDKMessageCenter shareInstance] sendMsgToUnity:@"unity.buss.webview.close" params:@{} callback:nil];
}

- (void)reloadWebview {
    [self.webview reload];
}

#pragma mark - Lazy Load
- (WKWebView *)webview {
    if (!_webview) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.allowsInlineMediaPlayback = YES;
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        NSMutableString*javascript = [NSMutableString string];
        [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
        [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        [config.userContentController addUserScript:noneSelectScript];
        _webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
#if ENABLE_DEBUG_MOD
        if (@available(iOS 16.4, *)) {
            _webview.inspectable = YES;
        }
#endif
        //setupUA
        NSString *jzhUserAgent = [[NSUserDefaults standardUserDefaults] stringForKey:@"jzh-UserAgent"];
        jzhUserAgent = [jzhUserAgent stringByReplacingOccurrencesOfString:@"wxnext" withString:@"wxnext_mod"];
        if(nil != jzhUserAgent) {
            [_webview setCustomUserAgent:jzhUserAgent];
        }
        [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"WXJsBridge"];
        [_webview.configuration.userContentController addScriptMessageHandler:self name:@"WXJsBridge" nativeObj:self.jsBridge];

        _webview.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _webview.scrollView.bounces = NO;
        _webview.wx_navigationDelegate = self;
        _webview.backgroundColor = [UIColor clearColor];
        _webview.opaque = NO;
        [_webview addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(36);
            make.right.mas_equalTo(-5);
            make.top.mas_equalTo(5);
        }];
        
//        [_webview addSubview:self.reloadBtn];
//        [self.reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.mas_equalTo(self.closeBtn);
//            make.width.height.mas_equalTo(30);
//            make.right.mas_equalTo(self.closeBtn.mas_left).offset(-8);
//        }];
    }
    return _webview;
}

- (AZJsBridge *)jsBridge {
    if (!_jsBridge) {
        _jsBridge = [[AZJsBridge alloc] init];
        _jsBridge.delegate = self;
        _jsBridge.azDelegate = self;
    }
    return _jsBridge;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        [_closeBtn setImage:[UIImage imageNamed:@"unity_webview_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeWebview) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)reloadBtn {
    if (!_reloadBtn) {
        _reloadBtn = [UIButton new];
        [_reloadBtn addTarget:self action:@selector(reloadWebview) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadBtn;
}

- (LoadingView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [LoadingView loadFromNibWithText:nil];
        _loadingView.bgColorType = BackgroundColorTypeTransparent;
    }
    return _loadingView;
}


@end
