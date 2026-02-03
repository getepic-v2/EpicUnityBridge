//
//  EpicPushManager.m
//  EpicUnityBridge
//
//  Push service manager for Unity scene integration.
//

#import "EpicPushManager.h"
#import <UIKit/UIKit.h>

#if !TARGET_OS_SIMULATOR
#import <TalMsgSdk/TMSdkManager.h>
#import <TALPush/PMPush.h>
#endif

@interface EpicPushManager ()

/// Weak reference table for listeners
@property (nonatomic, strong) NSHashTable<id<EpicPushMessageListener>> *listeners;

@end

@implementation EpicPushManager

+ (instancetype)sharedInstance {
    static EpicPushManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _listeners = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

#pragma mark - Listener Management

- (void)addListener:(id<EpicPushMessageListener>)listener {
    if (!listener) return;

    @synchronized (self.listeners) {
        if (![self.listeners containsObject:listener]) {
            [self.listeners addObject:listener];
            NSLog(@"[EpicPushManager] Added listener: %@", listener);
        }
    }
}

- (void)removeListener:(id<EpicPushMessageListener>)listener {
    if (!listener) return;

    @synchronized (self.listeners) {
        [self.listeners removeObject:listener];
        NSLog(@"[EpicPushManager] Removed listener: %@", listener);
    }
}

- (void)dispatchMessageToListeners:(EpicPushMessageEntity *)messageEntity {
    if (!messageEntity) return;

    NSArray *allListeners;
    @synchronized (self.listeners) {
        allListeners = [self.listeners allObjects];
    }

    NSLog(@"[EpicPushManager] Dispatching message to %lu listeners", (unsigned long)allListeners.count);

    for (id<EpicPushMessageListener> listener in allListeners) {
        if ([listener respondsToSelector:@selector(receivedTransmissionMessage:)]) {
            [listener receivedTransmissionMessage:messageEntity];
        }
    }
}

#pragma mark - Config Helpers

+ (BOOL)isTestEnvironment {
    // TODO: Add environment switch logic if needed
    return YES; // Default to test environment for now
}

+ (NSString *)getTalMsgAppId {
    if ([self isTestEnvironment]) {
        return @"nextmath10001";
    }
    return @"nextmath20001";
}

+ (NSString *)getTalMsgAppKey {
    if ([self isTestEnvironment]) {
        return @"NjY1NTQzMjUyOWI5OTlkZg";
    }
    return @"ZjlmNjdlYjNhMjE3MDJiZg";
}

+ (NSString *)getTalMsgConfigHost {
    if ([self isTestEnvironment]) {
        return @"chatconf-test.msg.xescdn.com";
    }
    return @"chatconf.msg.xescdn.com";
}

+ (NSString *)getTalMsgConfigBackupIp {
    if ([self isTestEnvironment]) {
        return @"47.93.183.225";
    }
    return @"39.105.249.248";
}

#pragma mark - Public Methods

+ (void)startPushService {
    NSLog(@"[EpicPushManager] startPushService");

#if !TARGET_OS_SIMULATOR
    PushSdkPropertyEntity *cfgEntity = [PushSdkPropertyEntity new];
    cfgEntity.protocol = @"https";
    if ([self isTestEnvironment]) {
        cfgEntity.hostname = @"sandbox.gslb.msg.xescdn.com";
        cfgEntity.backupIp = @"120.52.32.211";
    } else {
        cfgEntity.hostname = @"push-api.xueersi.com";
        cfgEntity.backupIp = @"124.250.113.88";
    }
    cfgEntity.url = @"/login/push";
    cfgEntity.port = 443;

    PushSdkPropertyEntity *logEntity = [PushSdkPropertyEntity new];
    logEntity.protocol = @"https";
    logEntity.hostname = @"log.xescdn.com";
    logEntity.backupIp = @"39.107.218.17";
    logEntity.url = @"/log";
    logEntity.port = 443;

    // TODO: Get clientId from app
    NSString *clientId = @"";

    [[PMPushService sharedInstance] setupWithEnvMode:cfgEntity
                                         logProperty:logEntity
                                             logPath:nil
                                            clientId:clientId
                                            delegate:[EpicPushManager sharedInstance]];

    NSLog(@"[EpicPushManager] push service configured");
    [self bindPushClient];
#endif
}

+ (void)stopPushService {
    NSLog(@"[EpicPushManager] stopPushService");

#if !TARGET_OS_SIMULATOR
    [[PMPushService sharedInstance] unBind];
#endif
}

+ (void)bindPushClientWhenLogin {
    NSLog(@"[EpicPushManager] bindPushClientWhenLogin");

#if !TARGET_OS_SIMULATOR
    NSString *appId = [EpicPushManager sharedInstance].appId ?: [self getTalMsgAppId];
    NSString *appKey = [EpicPushManager sharedInstance].appKey ?: [self getTalMsgAppKey];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
    NSString *userId = @""; // TODO: Get current user ID

    [[PMPushService sharedInstance] bindWithAppId:appId
                                           appKey:appKey
                                       appVersion:version
                                           userId:userId];
    NSLog(@"[EpicPushManager] bind push with appId: %@, userId: %@", appId, userId);
#endif
}

+ (void)bindPushClient {
    NSLog(@"[EpicPushManager] bindPushClient");

#if !TARGET_OS_SIMULATOR
    NSString *appId = [EpicPushManager sharedInstance].appId ?: [self getTalMsgAppId];
    NSString *appKey = [EpicPushManager sharedInstance].appKey ?: [self getTalMsgAppKey];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
    NSString *userId = @""; // TODO: Get current user ID

    [[PMPushService sharedInstance] bindWithAppId:appId
                                           appKey:appKey
                                       appVersion:version
                                           userId:userId];
    NSLog(@"[EpicPushManager] bind push with appId: %@", appId);
#endif
}

#pragma mark - TMSdk Initialization

+ (void)initTMSdk {
    NSLog(@"[EpicPushManager] initTMSdk");

#if !TARGET_OS_SIMULATOR
    NSString *workPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *location = @"China";

    // 设置 SDK 属性
    SdkPropertyEntity *confServiceEntity = [[SdkPropertyEntity alloc] init];
    confServiceEntity.hostname = [self getTalMsgConfigHost];
    confServiceEntity.backupIp = [self getTalMsgConfigBackupIp];
    confServiceEntity.protocol = @"https";
    confServiceEntity.url = @"/chatapi/v4/proxy/config";
    confServiceEntity.port = 443;

    SdkPropertyEntity *logServiceEntity = [[SdkPropertyEntity alloc] init];
    logServiceEntity.hostname = @"log.xescdn.com";
    logServiceEntity.backupIp = @"39.107.218.17";
    logServiceEntity.protocol = @"https";
    logServiceEntity.url = @"/log";
    logServiceEntity.port = 443;

    NSString *appId = [EpicPushManager sharedInstance].appId ?: [self getTalMsgAppId];
    NSString *appKey = [EpicPushManager sharedInstance].appKey ?: [self getTalMsgAppKey];

    // SDK 初始化
    [[TMSdkManager sharedInstance] initWithAppId:appId
                                          appKey:appKey
                                        workPath:workPath
                                        location:location
                                      logService:logServiceEntity
                                     confService:confServiceEntity];

    NSLog(@"[EpicPushManager] TMSdk initialized with appId: %@, host: %@", appId, confServiceEntity.hostname);
#endif
}

#pragma mark - PMPushDelegate

#if !TARGET_OS_SIMULATOR

- (void)didBind:(BOOL)result info:(NSDictionary *)info {
    NSLog(@"[EpicPushManager] didBind result: %d, info: %@", result, info);
}

- (void)didUnBind:(BOOL)result info:(NSDictionary *)info {
    NSLog(@"[EpicPushManager] didUnBind result: %d, info: %@", result, info);
}

- (void)didGetPushLists:(BOOL)result dataArray:(NSArray *)dataArray {
    NSLog(@"[EpicPushManager] didGetPushLists result: %d, count: %lu", result, (unsigned long)dataArray.count);
}

- (void)didReceiveData:(NSString *)msgId title:(NSString *)title description:(NSString *)description payload:(NSDictionary *)payload {
    NSLog(@"[EpicPushManager] didReceiveData msgId: %@, title: %@, description: %@", msgId, title, description);

    // Create message entity and dispatch to listeners
    EpicPushMessageEntity *messageEntity = [[EpicPushMessageEntity alloc] initWithMsgId:msgId
                                                                                  title:title
                                                                            description:description
                                                                                payload:payload];
    [self dispatchMessageToListeners:messageEntity];
}

- (void)didRegisterClient:(BOOL)result {
    NSLog(@"[EpicPushManager] didRegisterClient result: %d", result);
}

- (void)didReceiveClientId:(NSString *)clientId {
    NSLog(@"[EpicPushManager] didReceiveClientId: %@", clientId);
    [EpicPushManager sharedInstance].clientId = clientId;
}

- (void)didRecvJPushRegisterId:(NSString *)registerId {
    NSLog(@"[EpicPushManager] didRecvJPushRegisterId: %@", registerId);
}

#endif

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"[EpicPushManager] willPresentNotification: %@", notification.request.content.userInfo);

    // Show notification banner when app is in foreground
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"[EpicPushManager] didReceiveNotificationResponse: %@", response.notification.request.content.userInfo);

    // Handle notification tap
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self handleNotificationUserInfo:userInfo];

    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
   openSettingsForNotification:(UNNotification *)notification {
    NSLog(@"[EpicPushManager] openSettingsForNotification");
}

#pragma mark - Notification Handling

- (void)handleNotificationUserInfo:(NSDictionary *)userInfo {
    NSLog(@"[EpicPushManager] handleNotificationUserInfo: %@", userInfo);
    // TODO: Parse userInfo and handle deep link or business logic
}

@end
