//
//  EpicPushMessageEntity.m
//  EpicUnityBridge
//
//  Push message entity model.
//

#import "EpicPushMessageEntity.h"

@implementation EpicPushMessageEntity

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _msgId = dict[@"msgId"];
        _title = dict[@"title"];
        _msgDescription = dict[@"description"];
        _payload = dict[@"payload"];
        _msgType = dict[@"msgType"];
        _timestamp = [dict[@"timestamp"] doubleValue] ?: [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (instancetype)initWithMsgId:(NSString *)msgId
                        title:(NSString *)title
                  description:(NSString *)description
                      payload:(NSDictionary *)payload {
    self = [super init];
    if (self) {
        _msgId = msgId;
        _title = title;
        _msgDescription = description;
        _payload = payload;
        _timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<EpicPushMessageEntity: msgId=%@, title=%@, description=%@, payload=%@>",
            self.msgId, self.title, self.msgDescription, self.payload];
}

@end
