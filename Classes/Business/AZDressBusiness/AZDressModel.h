//
//  AZDressModel.h
//  AZCommonBusiness
//
//  Created by leev on 2023/7/31.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AZDressModelType)
{
    AZDressModelTypeHead, //头部
    AZDressModelTypeUpperClothing, //上装
    AZDressModelTypeLowerClothing, //下装
    AZDressModelTypeSuit, //套装
    AZDressModelTypeBackDesc, //背部饰品
    AZDressModelTypeWaistDesc, //腰部饰品
    AZDressModelTypeHeadDec, //头部饰品
};

typedef NS_ENUM(NSInteger, AZDressLevelType)
{
    AZDressLevelTypeNormal, //默认
    AZDressLevelTypeHigh, //高级
    AZDressLevelTypeRare, //稀有
    AZDressLevelTypeLegend, //传奇
    AZDressLevelTypeMyth, //神话
};

@interface AZDressModel : NSObject

@property (nonatomic, strong) NSString *dressId; //装扮id

@property (nonatomic, strong) NSString *dressName; //装扮名称

@property (nonatomic, assign) NSInteger dressNumber; //装扮数量

@property (nonatomic, assign) AZDressModelType dressType; //装扮分类

@property (nonatomic, assign) AZDressLevelType levelType; //等级类型

@property (nonatomic, assign) NSInteger levelCode; //后端返回的原始levelCode

@property (nonatomic, strong) NSString *levelName; //等级名称

@property (nonatomic, assign) NSInteger popularityValue; //潮流度

@property (nonatomic, strong) NSString *dressCoverUrl; //装扮封面url

@property (nonatomic, strong) NSString *dressAttrUrl; //装扮类型角标图片（隐藏or限定）

@property (nonatomic, strong) NSString *dressZipUrl; //装扮3D资源url

@property (nonatomic, strong) NSString *uAddress; //uAddress

@property (nonatomic, assign) BOOL isOwned; //是否拥有， 默认是YES

@property (nonatomic, assign) BOOL isUsed; //是否已使用

@property (nonatomic, assign) BOOL isNew; //是否是最新，如果isNew=YES，则需要展示红点

@property (nonatomic, assign) BOOL isLastest; //是否是最近获得的，如果是的话，需要锚点到对应为止

@property (nonatomic, assign) BOOL isLimitTime; // 是否是限时皮肤

@property (nonatomic, assign) BOOL isExpired; //是否过期(只有限时皮肤有过期逻辑)

@property (nonatomic, assign) NSInteger leftTime; //剩余时间(只有限时皮肤有剩余时间)

@property (nonatomic, strong) NSMutableArray<AZDressModel *> *dressModelArray; //装扮为套装时使用

@property (nonatomic, assign) BOOL canInvert; //本地字段，是否支持反选，默认NO


// 换肤给unity使用
@property (nonatomic, assign) NSInteger bodyPartType;
@property (nonatomic, assign) NSInteger decorateType;
@property (nonatomic, assign) NSInteger cutType;

@property (nonatomic, strong) NSDictionary *package; //装扮包信息，透传给unity（2.19版本支持）

- (id)initWithDic:(NSDictionary *)dic;

@end

@interface AZDressLevelModel : NSObject

@property (nonatomic, assign) NSInteger levelCode;

@property (nonatomic, copy) NSString *levelName;

- (id)initWithDic:(NSDictionary *)dic;

@end
