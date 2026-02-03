//
//  EpicPushMessageEntity.h
//  EpicUnityBridge
//
//  Push message entity model.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EpicPushMessageEntity : NSObject

/// Message ID
@property (nonatomic, copy, nullable) NSString *msgId;

/// Message title
@property (nonatomic, copy, nullable) NSString *title;

/// Message description
@property (nonatomic, copy, nullable) NSString *msgDescription;

/// Message payload
@property (nonatomic, strong, nullable) NSDictionary *payload;

/// Message type
@property (nonatomic, copy, nullable) NSString *msgType;

/// Timestamp
@property (nonatomic, assign) NSTimeInterval timestamp;

/// Initialize with dictionary
- (instancetype)initWithDictionary:(NSDictionary *)dict;

/// Initialize with msgId, title, description and payload
- (instancetype)initWithMsgId:(nullable NSString *)msgId
                        title:(nullable NSString *)title
                  description:(nullable NSString *)description
                      payload:(nullable NSDictionary *)payload;

@end

NS_ASSUME_NONNULL_END
