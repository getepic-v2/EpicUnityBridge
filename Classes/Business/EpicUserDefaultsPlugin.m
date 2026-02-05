//
//  EpicUserDefaultsPlugin.m
//  EpicUnityBridge
//

#import "EpicUserDefaultsPlugin.h"
#import <NTUnityIn/NTUnityInSDK.h>

@interface EpicUserDefaultsPlugin () <NTUSDKPluginDelegate>

@end

@implementation EpicUserDefaultsPlugin

+ (NSArray<NSString *> *)unityToNativeMsgKeys {
    return @[
        @"app.buss.storage.userdefaults"
    ];
}

- (void)receivedUnityMsgKey:(NSString *)msgKey reqEntity:(NTUnityMsgEntity *)reqEntity {
    if ([msgKey isEqualToString:@"app.buss.storage.userdefaults"]) {
        NSDictionary *params = reqEntity.params;
        NSString *type = params[@"type"];
        NSString *key = params[@"key"];
        NSString *value = params[@"value"];

        if (!key || ![key isKindOfClass:[NSString class]]) return;

        // Namespace keys to avoid collisions with Epic's own UserDefaults
        NSString *namespacedKey = [NSString stringWithFormat:@"unity_%@", key];

        if ([type isEqualToString:@"set"]) {
            if (value) {
                [[NSUserDefaults standardUserDefaults] setValue:value forKey:namespacedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else if ([type isEqualToString:@"get"]) {
            NSString *storedValue = [[NSUserDefaults standardUserDefaults] stringForKey:namespacedKey];
            [reqEntity callback:^NSDictionary * _Nonnull{
                return @{@"value": storedValue ?: @""};
            }];
        }
    }
}

@end
