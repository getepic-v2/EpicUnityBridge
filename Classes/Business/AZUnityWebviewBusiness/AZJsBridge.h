//
//  AZJsBridge.h
//  AZUnityBusiness
//
//  Created by wangyiyang on 2024/1/8.
//

#import <Foundation/Foundation.h>
#import "TJSBridge.h"
#import "WXJsBridge.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AZJsBridgeDelegate <NSObject>

- (void)hideNativeCloseBtn:(BOOL)hidden;

@end

@interface AZJsBridge : WXJsBridge

@property (nonatomic, weak) id<AZJsBridgeDelegate> azDelegate;

///暂停Unity
- (void)pauseUnity:(TJSNativeParam *)param;

///隐藏原生关闭按钮
- (void)hideNativeCloseBtn:(TJSNativeParam *)param;

@end

NS_ASSUME_NONNULL_END
