//
//  MainViewController.h
//  catcat
//
//  Created by gongwenkai on 2017/7/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController : UIViewController<UITextFieldDelegate, AVAudioPlayerDelegate>
@property (nonatomic, copy) NSString *leaderboardIdentifier;

@end
