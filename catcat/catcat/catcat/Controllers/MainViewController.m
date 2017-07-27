//
//  MainViewController.m
//  catcat
//
//  Created by gongwenkai on 2017/7/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "MainViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "PrimaryScene.h"

@import GameKit;
@interface MainViewController ()

@property (strong, nonatomic) PrimaryScene *mainScene;
@property (assign, nonatomic) BOOL gameCenterEnabled;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mainScene = [[PrimaryScene alloc] initWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    _mainScene.scaleMode = SKSceneScaleModeAspectFit;
    [_mainScene runAction:[SKAction repeatActionForever:[SKAction playSoundFileNamed:@"backGround.mp3" waitForCompletion:YES]]];
    SKView *view = (SKView *)self.view;

//    view.showsDrawCount = YES;
//    view.showsFPS = YES;
//    view.showsNodeCount = YES;
    [self authenticateLocalPlayer];
    [self persentScene:_mainScene fromView:view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }else{
        if ([GKLocalPlayer localPlayer].authenticated) {
            _gameCenterEnabled = YES;        }
        
        else{
            _gameCenterEnabled = NO;
        }
        }
    };
}


-(void)persentScene:(SKScene*)scene fromView:(SKView*)view{
    [view presentScene:scene];
    return;

}

@end
