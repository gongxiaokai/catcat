//
//  Defines.h
//  catcat
//
//  Created by gongwenkai on 2017/7/20.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//
#define GDT_APPID                       @"1106301022"
#define GDT_OPENAD                      @"7040028454418193"
#define GDT_ADSUPPOT1                   @"2080622474511184"
#define DEVICE_BOUNDS [[UIScreen mainScreen] applicationFrame]
#define DEVICE_SIZE [[UIScreen mainScreen] applicationFrame].size
#define WINDOW_SIZE [[UIApplication sharedApplication] keyWindow].frame.size
#define DELTA_Y ( DEVICE_OS_VERSION >= 7.0f? 20.0f:0.0f)
#define color(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define DEVICE_OS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define HERO_SIZE CGSizeMake(40, 30)
#define WALL_WIDTH 30
#define NODENAME_HERO @"heronode"
#define NODENAME_BRICK @"brick"
#define NODENAME_WALL @"wall"
#define NODENAME_HOLE @"hole"
#define NODENAME_FISH @"fish"
#define ACTIONKEY_ADDWALL @"addwall"
#define ACTIONKEY_MOVEWALL @"movewall"
#define ACTIONKEY_FLY @"fly"
#define ACTIONKEY_ADDFISH @"addfish"
#define ACTIONKEY_MOVEHEAD @"movehead"
#define GROUND_HEIGHT 1.0f
#define TIMEINTERVAL_ADDWALL 2.0f
#define TIMEINTERVAL_MOVEWALL 2.5f
#define FISH_WIDTH 30.0f
#define FISH_HEIGHT 1.0f
#define FISHWIDTH_MIN 2
#define FISHWIDTH_MAX 5
#define FISHCOLOR [UIColor grayColor]
#define COLOR_HERO [UIColor blueColor]
#define COLOR_BG [UIColor colorWithRed:0.204 green:0.286 blue:0.369 alpha:1]
#define COLOR_WALL [UIColor colorWithRed:0.827 green:0.329 blue:0 alpha:1]
#define COLOR_LABEL [UIColor whiteColor]
