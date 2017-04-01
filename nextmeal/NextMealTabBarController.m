//
//  NextMealTabBarController.m
//  nextmeal
//
//  Created by Anson Liu on 3/30/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "NextMealTabBarController.h"

#import "Constants.h"

@interface NextMealTabBarController ()

@end

@implementation NextMealTabBarController

- (void)switchToIndex:(NSNotification *)notification {
    NSUInteger targetIndex = [[notification.userInfo valueForKey:kSelectedViewIndexKey] unsignedIntegerValue];
    self.selectedIndex = targetIndex < self.viewControllers.count ? targetIndex : 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToIndex:) name:kNotificationLoadView object:nil];
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
