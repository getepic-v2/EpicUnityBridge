//
//  AZDressListModel.h
//  AZCommonBusiness
//
//  Created by leev on 2023/7/31.
//

#import <Foundation/Foundation.h>
#import "AZDressModel.h"

@interface AZDressListModel : NSObject

@property (nonatomic, strong) NSMutableArray<AZDressModel *> *dressModelArray; //分类下的装扮信息

/**
 * @desc 单装解析
 */
- (id)initWithDic:(NSDictionary *)dic;
- (id)initWithDic:(NSDictionary *)dic canInvert:(BOOL)canInvert;

/**
 * @desc 套装解析
 */
- (id)initWithSuitArray:(NSArray *)array;

@end

