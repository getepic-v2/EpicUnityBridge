//
//  AZUserAvtarModel.m
//  AZSignIn
//
//  Created by leev on 2023/7/27.
//

#import "AZUserAvtarModel.h"

@implementation AZUserAvtarModel

- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {        
        _avatarCoverUrl = [dic wx_stringForKey:@"pic"];
        _avatarId = [dic wx_numberForKey:@"id"];
        
        NSInteger usedValue = [dic wx_integerForKey:@"is_use"];
        if (usedValue == 1)
        {
            _isSelected = YES;
        }
        else
        {
            _isSelected = NO;
        }
        _dressId = [dic wx_arrayForKey:@"dress_id"];
        _sex = [dic wx_integerForKey:@"sex"];
        _relationEmojiId = [dic wx_integerForKey:@"relation_emoji_id"];
        
        NSDictionary *packageDic = [dic wx_dictionaryForKey:@"package"];
        _avatarZipUrl = [packageDic wx_stringForKey:@"ios"];
        _uAddress = [packageDic wx_stringForKey:@"u_address"];
        _bodyPartType = [packageDic wx_integerForKey:@"body_part_type"];
        _cutType = [packageDic wx_integerForKey:@"cut_type"];
        _decorateType = [packageDic wx_integerForKey:@"decorate_type"];
        
    }
    return self;;
}
@end
