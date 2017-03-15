//
//  NextThreeViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "NextThreeViewController.h"

#import "NextThreeTableViewController.h"

@interface NextThreeViewController ()

@property (nonatomic) NextThreeTableViewController *menuTableVC;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@end

@implementation NextThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _menuTableVC = [[NextThreeTableViewController alloc] init];
    _menuTableVC.tableView = _menuTableView;
    [_menuTableVC reloadMenuData];
    
    _menuTableView.dataSource = _menuTableVC;
    _menuTableView.delegate = _menuTableVC;
    
    [_menuTableView reloadData];
    
    NSCalendar *calenderObj = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *startOfWeek;
    [calenderObj rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfWeek interval:nil forDate:[NSDate date]];
    
    NSLog(@"start %@ now %@", startOfWeek, [NSDate date]);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
