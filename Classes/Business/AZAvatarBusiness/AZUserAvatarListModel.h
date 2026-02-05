//
//  AZUserAvatarListModel.h
//  AZSignIn
//
//  Created by leev on 2023/7/28.
//

#import <Foundation/Foundation.h>
#import "AZUserAvtarModel.h"

@interface AZUserAvatarListModel : NSObject

@property (nonatomic, strong) NSMutableArray *packageModelArray;

@property (nonatomic, strong) NSMutableArray *expressionModelArray;

@property (nonatomic, strong) NSMutableArray *skinModelArray;

@property (nonatomic, strong) NSMutableArray *Head2DModelArray;

@property (nonatomic, strong) NSString *guideAudioUrl; // 引导音频url

@property (nonatomic, assign) BOOL editNickNameEnable; //是否用户编辑昵称

@end
