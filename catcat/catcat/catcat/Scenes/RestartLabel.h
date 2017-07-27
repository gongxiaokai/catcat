//
//  RestartView.h
//  catcat
//
//  Created by gongwenkai on 2017/7/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class RestartLabel;
@protocol RestartViewDelegate <NSObject>

- (void)restartView:(RestartLabel *)restartView didPressRestartButton:(SKSpriteNode *)restartButton;
- (void)restartView:(RestartLabel *)restartView didPressLeaderboardButton:(SKSpriteNode *)restartButton;
@end

@interface RestartLabel : SKSpriteNode

@property (weak, nonatomic) id <RestartViewDelegate> delegate;
@property (copy, nonatomic) NSString* finalPoint;
+ (RestartLabel *)getInstanceWithSize:(CGSize)size Point:(NSString *)point;
- (void)dismiss;
- (void)showInScene:(SKScene *)scene;

@end
