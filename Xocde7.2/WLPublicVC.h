//
//  WLPublicVC.h
//  Xocde7.2
//
//  Created by Ernie Liu on 17/1/16.
//  Copyright © 2017年 Ernie Liu. All rights reserved.
//
#define UD   [NSUserDefaults standardUserDefaults]
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height self.view.bounds.size.height
#define TMColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:0.9]
#define TMGlobalBg TMColor(40, 110, 236)
#import <UIKit/UIKit.h>

@interface WLPublicVC : UIViewController

@end
