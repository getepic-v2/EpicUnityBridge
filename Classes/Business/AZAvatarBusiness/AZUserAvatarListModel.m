//
//  AZUserAvatarListModel.m
//  AZSignIn
//
//  Created by leev on 2023/7/28.
//

#import "AZUserAvatarListModel.h"

@implementation AZUserAvatarListModel

- (void)manualParseJsonWithDic:(NSDictionary *)jsonDic
{
    // 引导音频
    self.guideAudioUrl = [jsonDic wx_stringForKey:@"dress_audio"];
    
    // 是否支持编辑昵称
    self.editNickNameEnable = [jsonDic wx_boolForKey:@"modify_nickname_able"];

    // 2D头像
    {
        self.Head2DModelArray = [NSMutableArray arrayWithCapacity:42];
        
        NSInteger index = -1;
        NSArray *array = [jsonDic wx_arrayForKey:@"avatar"];
        for (int i = 0; i < array.count; i++)
        {
            NSDictionary *dic = [array wx_objectAtIndex:i];
            AZUserAvtarModel *avatarModel = [[AZUserAvtarModel alloc] initWithDic:dic];
            avatarModel.avatarType = AZUserAvtarModelType2DHeadPic;
            
            if (avatarModel.isSelected)
            {
                index = i;
            }

            [self.Head2DModelArray addObject:avatarModel];
        }
        
        // 兜底，使用第一个作为默认选中态
        if (index == -1 && self.Head2DModelArray.count > 0)
        {
            AZUserAvtarModel *avatarModel =[self.Head2DModelArray wx_objectAtIndex:0];
            avatarModel.isSelected = YES;
        }
    }
    // 头部
    {
        self.packageModelArray = [NSMutableArray arrayWithCapacity:42];
        
        NSInteger index = -1;
        NSArray *array = [jsonDic wx_arrayForKey:@"dress_package"];
        for (int i = 0; i < array.count; i++)
        {
            NSDictionary *dic = [array wx_objectAtIndex:i];
            
            AZUserAvtarModel *avatarModel = [[AZUserAvtarModel alloc] initWithDic:dic];
            avatarModel.avatarType = AZUserAvtarModelTypePackage;
            
            if (avatarModel.isSelected)
            {
                index = i;
            }
            
            [self.packageModelArray addObject:avatarModel];
        }
        
        // 兜底，使用第一个作为默认选中态
        if (index == -1 && self.packageModelArray.count > 0)
        {
            AZUserAvtarModel *avatarModel =[self.packageModelArray wx_objectAtIndex:0];
            avatarModel.isSelected = YES;
        }
    }
    
    // 表情
    {
        self.expressionModelArray = [NSMutableArray arrayWithCapacity:42];
        
        NSInteger index = -1;
        NSArray *array = [jsonDic wx_arrayForKey:@"emoji"];
        for (int i = 0; i < array.count; i++)
        {
            NSDictionary *dic = [array wx_objectAtIndex:i];
            
            AZUserAvtarModel *avatarModel = [[AZUserAvtarModel alloc] initWithDic:dic];
            avatarModel.avatarType = AZUserAvtarModelTypeExpression;
            
            if (avatarModel.isSelected)
            {
                index = i;
            }

            [self.expressionModelArray addObject:avatarModel];
        }
        
        // 兜底，使用第一个作为默认选中态
        if (index == -1 && self.expressionModelArray.count > 0)
        {
            AZUserAvtarModel *avatarModel =[self.expressionModelArray wx_objectAtIndex:0];
            avatarModel.isSelected = YES;
        }
    }
    
    // 肤色
    {
        self.skinModelArray = [NSMutableArray arrayWithCapacity:42];
        
        NSInteger index = -1;
        NSArray *array = [jsonDic wx_arrayForKey:@"skin"];
        for (int i = 0; i < array.count; i++)
        {
            NSDictionary *dic = [array wx_objectAtIndex:i];
            
            AZUserAvtarModel *avatarModel = [[AZUserAvtarModel alloc] initWithDic:dic];
            avatarModel.avatarType = AZUserAvtarModelTypeSkin;
            
            if (avatarModel.isSelected)
            {
                index = i;
            }

            [self.skinModelArray addObject:avatarModel];
        }
        
        // 兜底，使用第一个作为默认选中态
        if (index == -1 && self.skinModelArray.count > 0)
        {
            AZUserAvtarModel *avatarModel =[self.skinModelArray wx_objectAtIndex:0];
            avatarModel.isSelected = YES;
        }
    }
}


@end
