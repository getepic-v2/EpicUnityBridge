//
//  AZUserAvtarModel.h
//  AZSignIn
//
//  Created by leev on 2023/7/27.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AZUserAvtarModelType)
{
    AZUserAvtarModelTypePackage = 1, //3D套装
    AZUserAvtarModelTypeExpression = 2, //3D表情
    AZUserAvtarModelTypeSkin = 3, //3D肤色
    AZUserAvtarModelType2DHeadPic = 4, //2D头像
};

@interface AZUserAvtarModel : NSObject

@property (nonatomic, strong) NSNumber *avatarId; //id

@property (nonatomic, assign) AZUserAvtarModelType avatarType; //类型

@property (nonatomic, strong) NSString *avatarCoverUrl; //avatar封面url

@property (nonatomic, strong) NSString *avatarZipUrl; //zip包

@property (nonatomic, strong) NSString *uAddress;

@property (nonatomic, assign) BOOL isSelected; //是否已使用

/**套装使用字段---start*/
@property (nonatomic, strong) NSArray *dressId; // id列表，仅是套装时使用的
@property (nonatomic, assign) NSInteger  sex; //性别 1男 2女
@property (nonatomic, assign) NSInteger relationEmojiId; //关联的默认表情id
/**套装使用字段---end*/

@property (nonatomic, assign) NSInteger bodyPartType;
@property (nonatomic, assign) NSInteger decorateType;
@property (nonatomic, assign) NSInteger cutType;

- (id)initWithDic:(NSDictionary *)dic;

@end
