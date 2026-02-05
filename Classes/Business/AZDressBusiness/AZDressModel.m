//
//  AZDressModel.m
//  AZCommonBusiness
//
//  Created by leev on 2023/7/31.
//

#import "AZDressModel.h"

@implementation AZDressModel

- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _isOwned = YES;
        _dressId = [dic wx_stringForKey:@"id"];
        _dressName = [dic wx_stringForKey:@"name"];
        _dressNumber = [dic wx_integerForKey:@"num"];
        _dressCoverUrl = [dic wx_stringForKey:@"pic"];
        _dressAttrUrl = [dic wx_stringForKey:@"attr_icon"];
        _levelCode =  [dic wx_integerForKey:@"level"];
        _levelName = [dic wx_stringForKey:@"level_name"];
        _popularityValue = [dic wx_integerForKey:@"pop"];
        
        _levelType = AZDressLevelTypeNormal;
        
        if (_levelCode == 10)
        {
            _levelType = AZDressLevelTypeNormal;
        }
        else if (_levelCode == 20)
        {
            _levelType = AZDressLevelTypeHigh;
        }
        else if (_levelCode == 30)
        {
            _levelType = AZDressLevelTypeRare;
        }
        else if (_levelCode == 40)
        {
            _levelType = AZDressLevelTypeLegend;
        }
        else if (_levelCode == 50)
        {
            _levelType = AZDressLevelTypeMyth;
        }
        
        NSInteger usedValue = [dic wx_integerForKey:@"is_use"];
        if (usedValue == 1)
        {
            _isUsed = YES;
        }
        else
        {
            _isUsed = NO;
        }
                
        NSInteger isNewValue = [dic wx_integerForKey:@"is_new"];
        if (isNewValue == 1)
        {
            _isNew = YES;
        }
        else
        {
            _isNew = NO;
        }
        
        NSInteger isLastValue = [dic wx_integerForKey:@"is_latest"];
        if (isLastValue == 1)
        {
            _isLastest = YES;
        }
        else
        {
            _isLastest = NO;
        }
        
        // 是否是限时皮肤
        NSInteger isLimitTime = [dic wx_integerForKey:@"is_time_limit"];
        if (isLimitTime == 1)
        {
            _isLimitTime = YES;
        }
        else
        {
            _isLimitTime = NO;
        }

        // 是否过期
        NSInteger isExpired = [dic wx_integerForKey:@"is_expire"];
        if (isExpired == 1)
        {
            _isExpired = YES;
        }
        else
        {
            _isExpired = NO;
        }
        
        // 限时皮肤剩余时间
        _leftTime = [dic wx_integerForKey:@"expire_time"];
        
        _dressType = AZDressModelTypeHead;
        NSInteger dressType = [dic wx_integerForKey:@"type"];
        if (dressType == 1)
        {
            _dressType = AZDressModelTypeHead;
        }
        else if (dressType == 2)
        {
            _dressType = AZDressModelTypeUpperClothing;
        }
        else if (dressType == 3)
        {
            _dressType = AZDressModelTypeLowerClothing;
        }
        else if (dressType == 6)
        {
            _dressType = AZDressModelTypeSuit;
        }
        else if(dressType == 9){
            _dressType = AZDressModelTypeHeadDec;
        }
        else if(dressType == 10){
            _dressType = AZDressModelTypeWaistDesc;
        }
        else if(dressType == 11){
            _dressType = AZDressModelTypeBackDesc;
        }
    
        
        if (_dressType == AZDressModelTypeSuit)
        {
            self.dressModelArray = [NSMutableArray array];
            
            NSArray *array = [dic wx_arrayForKey:@"dress_list"];
            for(int i = 0; i < array.count; i++)
            {
                NSDictionary *dic = [array wx_objectAtIndex:i];
                AZDressModel *dressModel = [[AZDressModel alloc] initWithDic:dic];
                
                [self.dressModelArray addObject:dressModel];
            }
        }
        else
        {
            NSDictionary *packageDic = [dic wx_dictionaryForKey:@"package"];
            _package = packageDic;
            _dressZipUrl = [packageDic wx_stringForKey:@"ios"];
            _uAddress = [packageDic wx_stringForKey:@"u_address"];
            _bodyPartType = [packageDic wx_integerForKey:@"body_part_type"];
            _cutType = [packageDic wx_integerForKey:@"cut_type"];
            _decorateType = [packageDic wx_integerForKey:@"decorate_type"];
        }
    }
    return self;
}
@end


@implementation AZDressLevelModel

- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self)
    {
        _levelCode = [dic wx_integerForKey:@"level"];
        _levelName = [dic wx_stringForKey:@"name"];
    }
    return self;
}

@end
