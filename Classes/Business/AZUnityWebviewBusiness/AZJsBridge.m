//
//  AZJsBridge.m
//  AZUnityBusiness
//
//  Created by wangyiyang on 2024/1/8.
//

#import "AZJsBridge.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import "EpicUnityBusinessData.h"

@interface AZJsBridge ()

@property (nonatomic, assign) BOOL pause; //仅用作释放时容错

@end

@implementation AZJsBridge

- (void)dealloc {
    if (self.pause) {
        [[NTUnityInSDK shareInstance] resumeScene];
    }
}

- (void)pauseUnity:(TJSNativeParam *)param {
    BOOL pause = [param.params wx_boolForKey:@"pause"];
    self.pause = pause;
    if (pause) {
        [EpicUnityBusinessData sharedInstance].pauseWithOutLoading = YES;
        [[NTUnityInSDK shareInstance] pauseScene];
    } else {
        [[NTUnityInSDK shareInstance] resumeScene];
    }
}

- (void)hideNativeCloseBtn:(TJSNativeParam *)param {
    BOOL hidden = [param.params wx_boolForKey:@"hidden"];
    if ([self.azDelegate respondsToSelector:@selector(hideNativeCloseBtn:)]) {
        [self.azDelegate hideNativeCloseBtn:hidden];
    }
}

@end
