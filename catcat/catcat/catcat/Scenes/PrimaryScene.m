//
//  MainScene.m
//  catcat
//
//  Created by gongwenkai on 2017/7/20.
//  Copyright © 2017年 Chenglin. All rights reserved.
//

#import "PrimaryScene.h"
#import "RestartLabel.h"
#import "MainViewController.h"
#import "GDTMobInterstitial.h"

@import GameKit;

//Category bit masks
static const uint32_t heroCategory = 0x1 << 0;     //0x1     补满32位
static const uint32_t wallCategory = 0x1 << 1;     //0x10
static const uint32_t holeCategory = 0x1 << 2;     //0x100
static const uint32_t groundCategory = 0x1 << 3;   //0x1000
static const uint32_t edgeCategory = 0x1 << 4;     //0x10000
static const uint32_t fishCategory = 0x1 << 4;     //0x10000

@interface PrimaryScene() <SKPhysicsContactDelegate, RestartViewDelegate,GKGameCenterControllerDelegate,GDTMobInterstitialDelegate>

@property (strong, nonatomic) SKAction *moveWallAction, *moveHeadAction;
@property (strong, nonatomic) SKSpriteNode *hero, *ground, *ceiling;
@property (strong, nonatomic) SKLabelNode *labelNode, *tapToStart, *hitSakuraToScore;
@property (assign, nonatomic) BOOL isGameOver, contactBegin, musicPlaying;
@property (strong, nonatomic) GDTMobInterstitial *interstitialObj;

@end

@implementation PrimaryScene

- (void)initalize
{
    [super initalize];
    SKSpriteNode* background=[SKSpriteNode spriteNodeWithImageNamed:@"sky.png"];
    background.size = self.view.frame.size;
    background.position=CGPointMake(background.size.width/2, background.size.height/2);
    [self addChild:background];
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsWorld.contactDelegate = self;
    self.moveWallAction = [SKAction sequence:@[[SKAction moveToX:-WALL_WIDTH duration:TIMEINTERVAL_MOVEWALL],[SKAction removeFromParent]]];
    SKAction *upHeadAction = [SKAction rotateToAngle:M_PI / 6 duration:0.2f];
    upHeadAction.timingMode = SKActionTimingEaseOut;
    SKAction *downHeadAction = [SKAction rotateToAngle:-M_PI / 2 duration:0.8f];
    downHeadAction.timingMode = SKActionTimingEaseOut;
    self.moveHeadAction = [SKAction sequence:@[upHeadAction, downHeadAction,]];
    [self addHeroNode];
    [self addResultLabelNode];
    [self addInstruction];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction performSelector:@selector(addFish) onTarget:self],
                                                                       [SKAction waitForDuration:0.3f],
                                                                       ]]] withKey:ACTIONKEY_ADDFISH];
    
    _interstitialObj = [[GDTMobInterstitial alloc]
                        initWithAppkey:GDT_APPID
                        placementId:GDT_ADSUPPOT1];
    _interstitialObj.delegate = self;
    //设置委托 _interstitialObj.isGpsOn = NO; //【可选】设置GPS开关
    //预加载广告
    [_interstitialObj loadAd];
    
    
}

- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial {
    [interstitial loadAd];
}

#pragma mark - RestartViewDelegate

- (void)restartView:(RestartLabel *)restartView didPressRestartButton:(SKSpriteNode *)restartButton
{
    [restartView dismiss];
    [self restart];

}
- (void)restartView:(RestartLabel *)restartView didPressLeaderboardButton:(SKSpriteNode *)restartButton{
    [self showLeaderboard];
}

-(void)showLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    gcViewController.gameCenterDelegate = self;
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = @"MyFirstLeaderboard";
    [self.view.window.rootViewController presentViewController:gcViewController animated:YES completion:nil];
    
}
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Game progress

- (void)startGame
{
    self.isGameStart = YES;
    _hero.physicsBody.affectedByGravity = YES;
    [_hero removeActionForKey:ACTIONKEY_FLY];
    [_tapToStart removeFromParent];
    [_hitSakuraToScore removeFromParent];
    [self addResultLabelNode];
    SKAction *addWall = [SKAction sequence:@[
                                             [SKAction performSelector:@selector(addWall) onTarget:self],
                                             [SKAction waitForDuration:TIMEINTERVAL_ADDWALL],
                                             ]];
    [self runAction:[SKAction repeatActionForever:addWall] withKey:ACTIONKEY_ADDWALL];
}

- (void)gameOver
{
    self.isGameOver = YES;
    self.isGameStart=NO;
    [_hero removeActionForKey:ACTIONKEY_MOVEHEAD];
    [self removeActionForKey:ACTIONKEY_ADDWALL];
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeActionForKey:ACTIONKEY_MOVEWALL];
    }];
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeActionForKey:ACTIONKEY_MOVEWALL];
    }];
    if([_labelNode.text isEqualToString:@""])
        _labelNode.text=@"0";
    NSString *result=_labelNode.text;
    RestartLabel *restartView = [RestartLabel getInstanceWithSize:self.size Point:result];
    restartView.delegate = self;
    [restartView showInScene:self];
    _labelNode.text=@"";
    
    if (_interstitialObj.isReady) {
        UIViewController *vc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        //vc = [self navigationController];
        [_interstitialObj presentFromRootViewController:vc];
    }
    
    
}

- (void)restart
{
    [self addInstruction];
    self.labelNode.text = @"";
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [_hero removeFromParent];
    self.hero = nil;
    [self addHeroNode];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction performSelector:@selector(addFish) onTarget:self],
                                                                       [SKAction waitForDuration:0.3f],
                                                                       ]]] withKey:ACTIONKEY_ADDFISH];
    self.isGameStart = NO;
    self.isGameOver = NO;
}

- (void)playSoundWithName:(NSString *)fileName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runAction:[SKAction playSoundFileNamed:fileName waitForCompletion:YES]];
    });
}
#pragma mark - add method
- (void)addResultLabelNode
{
    self.labelNode = [SKLabelNode labelNodeWithFontNamed:@"PingFangSC-Regular"];
    _labelNode.fontSize = 30.0f;
    _labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _labelNode.position = CGPointMake(10, self.frame.size.height - 20);
    _labelNode.fontColor = COLOR_LABEL;
    _labelNode.zPosition=100;
    [self addChild:_labelNode];
}

- (SKAction *)getFlyAction
{
    SKAction *flyUp = [SKAction moveToY:_hero.position.y + 10 duration:0.3f];
    flyUp.timingMode = SKActionTimingEaseOut;
    SKAction *flyDown = [SKAction moveToY:_hero.position.y - 10 duration:0.3f];
    flyDown.timingMode = SKActionTimingEaseOut;
    SKAction *fly = [SKAction sequence:@[flyUp, flyDown]];
    return fly;
}

- (void)addInstruction{
    self.hitSakuraToScore = [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter"];
    _hitSakuraToScore.fontSize = 20.0f;
    _hitSakuraToScore.position = CGPointMake(self.frame.size.width / 2, CGRectGetMidY(self.frame)-60);
    _hitSakuraToScore.fontColor = COLOR_LABEL;
    _hitSakuraToScore.zPosition=100;
    _hitSakuraToScore.text=@"Hit fish to Score";
//    _hitSakuraToScore.text=NSLocalizedString(@"Hit Sakura to Score", nil);
    [self addChild:_hitSakuraToScore];
    self.tapToStart = [SKLabelNode labelNodeWithFontNamed:@"PingFangSC-Regular"];
    _tapToStart.fontSize = 20.0f;
    _tapToStart.position = CGPointMake(self.frame.size.width / 2, CGRectGetMidY(self.frame)-100);
    _tapToStart.fontColor = COLOR_LABEL;
    _tapToStart.zPosition=100;
    _tapToStart.text=@"Tap to Jump";
    [self addChild:_tapToStart];
}
- (void)addHeroNode
{
    self.hero=[SKSpriteNode spriteNodeWithImageNamed:@"player"];
    SKTexture* texture=[SKTexture textureWithImageNamed:@"player"];
    _hero.physicsBody=[SKPhysicsBody bodyWithTexture:texture size:_hero.size];
    _hero.anchorPoint = CGPointMake(0.5, 0.5);
    _hero.position = CGPointMake(self.frame.size.width / 2, CGRectGetMidY(self.frame));
    _hero.name = NODENAME_HERO;
    _hero.physicsBody.categoryBitMask = heroCategory;
    _hero.physicsBody.collisionBitMask = wallCategory | groundCategory|edgeCategory;
    _hero.physicsBody.contactTestBitMask = holeCategory | wallCategory | groundCategory|fishCategory;
    _hero.physicsBody.dynamic = YES;
    _hero.physicsBody.affectedByGravity = NO;
    _hero.physicsBody.allowsRotation = NO;
    _hero.physicsBody.restitution = 0.4;
    _hero.physicsBody.usesPreciseCollisionDetection = NO;
    [self addChild:_hero];
//    SKTexture* texture1=[SKTexture textureWithImageNamed:@"player"];
//    SKTexture* texture2=[SKTexture textureWithImageNamed:@"player3"];
//
//    SKAction *animate = [SKAction animateWithTextures:@[texture1,texture2] timePerFrame:0.1];
//    [_hero runAction:[SKAction repeatActionForever:animate]];
    [_hero runAction:[SKAction repeatActionForever:[self getFlyAction]]
             withKey:ACTIONKEY_FLY];
}


- (void)addFish
{
    
    SKSpriteNode *fishNode = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    fishNode.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius: fishNode.size.width/3 center:CGPointMake(0, 0)];
    fishNode.physicsBody.restitution=.6;
    fishNode.physicsBody.categoryBitMask = fishCategory;
    fishNode.physicsBody.contactTestBitMask= heroCategory;
    fishNode.anchorPoint = CGPointMake(0, 0);
    fishNode.physicsBody.dynamic=NO;
    fishNode.physicsBody.affectedByGravity=NO;
    fishNode.name = NODENAME_FISH;
    fishNode.position = CGPointMake(self.frame.size.width, arc4random() % (int)(self.frame.size.height / 3) + self.frame.size.height *2/ 3);
    SKAction* actionMove=[SKAction moveTo:CGPointMake(-fishNode.frame.size.width, arc4random() %(int)(self.frame.size.height / 5) + self.frame.size.height / 2) duration:2.0f];
    SKAction* actionRemove = [SKAction removeFromParent];
    [fishNode runAction:[SKAction moveTo:CGPointMake(-fishNode.frame.size.width, arc4random() %(int)(self.frame.size.height / 5) + self.frame.size.height / 2) duration:2.0f]];
    [fishNode runAction:[SKAction sequence:@[actionMove, actionRemove]]];
    [self addChild:fishNode];
}

- (void)addWall
{
    CGFloat spaceHeigh = self.frame.size.height - GROUND_HEIGHT;
    float random= arc4random() % 4;
    CGFloat holeLength = HERO_SIZE.height * (2.0+random*0.1);
    int holePosition = arc4random() % (int)((spaceHeigh - holeLength) / HERO_SIZE.height);
    CGFloat x = self.frame.size.width;
    CGFloat upHeight = holePosition * HERO_SIZE.height;
    if (upHeight > 0) {
        SKSpriteNode *upWall = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(WALL_WIDTH, upHeight)];
        upWall.anchorPoint = CGPointMake(0, 0);
        upWall.position = CGPointMake(x, self.frame.size.height - upHeight);
        upWall.name = NODENAME_WALL;
        upWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:upWall.size center:CGPointMake(upWall.size.width / 2.0f, upWall.size.height / 2.0f)];
        upWall.physicsBody.categoryBitMask = wallCategory;
        upWall.physicsBody.dynamic = NO;
        upWall.physicsBody.friction = 0;
        [upWall runAction:_moveWallAction withKey:ACTIONKEY_MOVEWALL];
        [self addChild:upWall];
    }
    CGFloat downHeight = spaceHeigh - upHeight - holeLength;
    if (downHeight > 0) {
        SKSpriteNode *downWall = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(WALL_WIDTH, downHeight)];
        downWall.anchorPoint = CGPointMake(0, 0);
        downWall.position = CGPointMake(x, GROUND_HEIGHT);
        downWall.name = NODENAME_WALL;
        downWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:downWall.size center:CGPointMake(downWall.size.width / 2.0f, downWall.size.height / 2.0f)];
        downWall.physicsBody.categoryBitMask = wallCategory;
        downWall.physicsBody.dynamic = NO;
        downWall.physicsBody.friction = 0;
        [downWall runAction:_moveWallAction withKey:ACTIONKEY_MOVEWALL];
        [self addChild:downWall];
    }
    
    SKSpriteNode *hole = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(WALL_WIDTH, holeLength)];
    hole.anchorPoint = CGPointMake(0, 0);
    hole.position = CGPointMake(x, self.frame.size.height - upHeight - holeLength);
    hole.name = NODENAME_HOLE;
    hole.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hole.size center:CGPointMake(hole.size.width / 2.0f, hole.size.height / 2.0f)];
    hole.physicsBody.categoryBitMask = holeCategory;
    hole.physicsBody.dynamic = NO;
    [hole runAction:_moveWallAction withKey:ACTIONKEY_MOVEWALL];
    [self addChild:hole];
}

- (void)update:(NSTimeInterval)currentTime
{
    if(self.hero&&!_isGameOver){
        if ( self.hero.position.x<10) {
            [self gameOver];
        }else if(self.hero.position.x>self.frame.size.width){
            self.hero.position =CGPointMake(self.hero.position.x-20, self.hero.position.y);
        }
    }
    __block int wallCount = 0;
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        if (wallCount >= 2) {
            *stop = YES;
            return;
        }
        if (node.position.x <= -WALL_WIDTH) {
            wallCount++;
            [node removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x <= -WALL_WIDTH) {
            [node removeFromParent];
            *stop = YES;
        }
    }];
    [self enumerateChildNodesWithName:NODENAME_FISH usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x <= -node.frame.size.width) {
            [node removeFromParent];
        }
    }];
}


#pragma mark - TouchEvent
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isGameOver) {
        return;
    }
    if (!_isGameStart) {
        [self startGame];
    }
    _hero.physicsBody.velocity = CGVectorMake(100, 500);
    [_hero runAction:_moveHeadAction withKey:ACTIONKEY_MOVEHEAD];
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (_isGameOver) {
        return;
    }
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if ((firstBody.categoryBitMask & heroCategory) && (secondBody.categoryBitMask & fishCategory)) {
        if(secondBody.node.parent&&self.isGameStart){
            int currentPoint = [_labelNode.text intValue];
            _labelNode.text = [NSString stringWithFormat:@"%d", currentPoint + 1];
            [self playSoundWithName:@"sfx_wing.caf"];
            NSString *burstPath =
            [[NSBundle mainBundle]
             pathForResource:@"MyParticle" ofType:@"sks"];
            SKEmitterNode *burstNode =
            [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
            burstNode.position = secondBody.node.position;
            [secondBody.node removeFromParent];
            [self addChild:burstNode];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [burstNode runAction:[SKAction removeFromParent]];
            });
        }
    }
}
- (void) didEndContact:(SKPhysicsContact *)contact{
    if (_isGameOver) {
        return;
    }
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    return;

}
@end




