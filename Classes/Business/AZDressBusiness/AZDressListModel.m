//
//  AZDressListModel.m
//  AZCommonBusiness
//
//  Created by leev on 2023/7/31.
//

#import "AZDressListModel.h"

@implementation AZDressListModel

//  单装解析
- (id)initWithDic:(NSDictionary *)dic
{
    return [self initWithDic:dic canInvert:NO];
}

- (id)initWithDic:(NSDictionary *)dic canInvert:(BOOL)canInvert {
    self = [super init];
    if (self)
    {
        _dressModelArray = [NSMutableArray array];
        
        NSArray *list = [dic wx_arrayForKey:@"list"];
        for(int i = 0; i < list.count; i++)
        {
            NSDictionary *dic = [list wx_objectAtIndex:i];
            AZDressModel *dressModel = [[AZDressModel alloc] initWithDic:dic];
            dressModel.canInvert = canInvert;
            [_dressModelArray addObject:dressModel];
        }

    }
    return self;
}


// 套装解析
- (id)initWithSuitArray:(NSArray *)array
{
    self = [super init];
    if (self)
    {
        _dressModelArray = [NSMutableArray array];
        for (NSMutableDictionary *dic in array)
        {
            AZDressModel *dressModel = [[AZDressModel alloc] initWithDic:dic];
            
            [_dressModelArray addObject:dressModel];
        }
    }
    return self;
}

@end
