//
//  EpicVibratePlugin.m
//  EpicUnityBridge
//

#import "EpicVibratePlugin.h"
#import <NTUnityIn/NTUnityInSDK.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreHaptics/CoreHaptics.h>

@interface EpicVibratePlugin () <NTUSDKPluginDelegate>

@property (nonatomic, strong) CHHapticEngine *engine API_AVAILABLE(ios(13.0));

@end

@implementation EpicVibratePlugin

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.api.vibrate.check",
        @"app.api.vibrate.start",
        @"app.api.vibrate.stop"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.api.vibrate.check"]) {
        BOOL supported = NO;
        if (@available(iOS 13.0, *)) {
            supported = [CHHapticEngine capabilitiesForHardware].supportsHaptics;
        }
        [reqEntity callback:^NSDictionary * _Nonnull{
            return @{@"support": @(supported)};
        }];

    } else if ([msgKey isEqualToString:@"app.api.vibrate.start"]) {
        NSDictionary *params = reqEntity.params;
        NSInteger type = [params[@"type"] integerValue];

        if (type == 1) {
            // Short vibration
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [generator prepare];
            [generator impactOccurred];
        } else {
            // Custom vibration — fallback to system vibrate
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }

    } else if ([msgKey isEqualToString:@"app.api.vibrate.stop"]) {
        if (@available(iOS 13.0, *)) {
            if (self.engine) {
                [self.engine stopWithCompletionHandler:nil];
                self.engine = nil;
            }
        }
    }
}

@end
