//
//  NextMealTabBarController.m
//  nextmeal
//
//  Created by Anson Liu on 3/30/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "NextMealTabBarController.h"

#import "Constants.h"

#import "Firebase.h"

@interface NextMealTabBarController () <UITabBarControllerDelegate>

@end

@implementation NextMealTabBarController

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController{
    NSUInteger indexOfTab = [tabBarController.viewControllers indexOfObject:viewController];
    
    switch (indexOfTab) {
        case 0:
            [FIRAnalytics logEventWithName:@"SelectedTab"
                                parameters:@{
                                             kFIRParameterItemID:[NSString stringWithFormat:@"id-%@", self.title],
                                             @"tabName":@"NextMenus"
                                             }];
            /*
            //Fabric Answers activity logging for detecting when user selects tab
            [Answers logCustomEventWithName:@"SelectedTab"
                           customAttributes:@{
                                              @"tabName" : @"NextMenus"}];
             */
            break;
        case 1:
            [FIRAnalytics logEventWithName:@"SelectedTab"
                                parameters:@{
                                             kFIRParameterItemID:[NSString stringWithFormat:@"id-%@", self.title],
                                             @"tabName":@"ExtendedMenu"
                                             }];
            /*
            //Fabric Answers activity logging for detecting when user selects tab
            [Answers logCustomEventWithName:@"SelectedTab"
                           customAttributes:@{
                                              @"tabName" : @"ExtendedMenu"}];
             */
            break;
        case 2:
            [FIRAnalytics logEventWithName:@"SelectedTab"
                                parameters:@{
                                             kFIRParameterItemID:[NSString stringWithFormat:@"id-%@", self.title],
                                             @"tabName":@"Extras"
                                             }];
            /*
            //Fabric Answers activity logging for detecting when user selects tab
            [Answers logCustomEventWithName:@"SelectedTab"
                           customAttributes:@{
                                              @"tabName" : @"Extras"}];
             */
            break;
        default:
            NSLog(@"Index %lu of tabbar selected. Is viewController of class %@", (unsigned long)indexOfTab, [viewController class]);
            break;
    }
}

- (void)switchToIndex:(NSNotification *)notification {
    NSUInteger targetIndex = [[notification.userInfo valueForKey:kSelectedViewIndexKey] unsignedIntegerValue];
    self.selectedIndex = targetIndex < self.viewControllers.count ? targetIndex : 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
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
