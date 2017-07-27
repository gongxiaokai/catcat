//
//  ScoreLabel.m
//  catcat
//
//  Created by gongwenkai on 2017/7/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "ScoreLabel.h"

@implementation ScoreLabel

- (id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        SKLabelNode* scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabelNode.text=_finalPoint;
        scoreLabelNode.fontSize = 20.0f;
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        scoreLabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        scoreLabelNode.position = CGPointMake(size.width / 2.0f, size.height - 300);
        scoreLabelNode.fontColor = [UIColor whiteColor];
        [self addChild:scoreLabelNode];    }
    return self;
}

@end
