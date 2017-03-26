//
//  TodayViewController.m
//  todayextension
//
//  Created by Anson Liu on 3/24/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "TodayNextMenuTableViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "Menu.h"
#import "ReadWriteLocalData.h"
#import "ParseMenuProtocol.h"
#import "ParseMenu.h"

@interface TodayNextMenuTableViewController () <NCWidgetProviding>

@end

@implementation TodayNextMenuTableViewController

#pragma mark - VC lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
