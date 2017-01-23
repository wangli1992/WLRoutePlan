//
//  WLPublicVC.m
//  Xocde7.2
//
//  Created by Ernie Liu on 17/1/16.
//  Copyright © 2017年 Ernie Liu. All rights reserved.
//

#import "WLPublicVC.h"

@interface WLPublicVC ()

@end

@implementation WLPublicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setBarTintColor:TMGlobalBg];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc]init];
    item1.title = @"返回";
    //item1.tintColor = [UIColor whiteColor];
    
    self.navigationItem.backBarButtonItem = item1;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
