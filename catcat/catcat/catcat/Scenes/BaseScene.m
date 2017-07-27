//
//  BaseScene.m
//  catcat
//
//  Created by gongwenkai on 2017/7/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "BaseScene.h"

@interface BaseScene()

@property (assign, nonatomic) BOOL contentCreated;

@end

@implementation BaseScene

- (void)didMoveToView:(SKView *)view
{
    if (_contentCreated) {
        return;
    }
    
    [self initalize];
    self.contentCreated = YES;
}

- (void)initalize
{
    
}

@end
