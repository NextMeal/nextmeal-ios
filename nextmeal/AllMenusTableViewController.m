//
//  AllMenusTableViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "AllMenusTableViewController.h"

#import "Constants.h"

#import "ParseMenu.h"

@interface AllMenusTableViewController ()

@end

@implementation AllMenusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reload data and UI methods

- (void)reloadMenuData {
    _loadedMenu = [ParseMenu retrieveMenus];
}

- (void)reloadMenuDataAndTableView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [self reloadMenuData];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Logic methods

- (Meal *)mealForSection:(NSInteger)section {
    Day *sectionDay = [[_loadedMenu.weeks objectAtIndex:section / (3 * 7)].days objectAtIndex:(section / 3) % 7];
    
    //NSLog(@"section %ld week index %d day index %d", (long)section, section / (3 * 7), section % 7);
    
    Meal *sectionMeal = [sectionDay.meals objectAtIndex:section % 3];
    
    return sectionMeal;
}

- (Item *)itemForIndexPath:(NSIndexPath *)indexPath {
    Item *indexPathItem = [[self mealForSection:indexPath.section].items objectAtIndex:indexPath.row];
    
    return indexPathItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfMeals = 0;
    NSArray<Day *> *allDays = [NSArray new];
    for (Week *week in _loadedMenu.weeks)
        allDays = [allDays arrayByAddingObjectsFromArray:week.days];
    for (Day *day in allDays)
        numberOfMeals += day.meals.count;
    
    return numberOfMeals;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self mealForSection:section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"AllMenusReuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self itemForIndexPath:indexPath].title;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDateFormatter *allMenuSectionHeaderDateFormatter = [[NSDateFormatter alloc] init];
    allMenuSectionHeaderDateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    allMenuSectionHeaderDateFormatter.dateFormat = @"EEEE MM/dd/yy";
    allMenuSectionHeaderDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    NSCalendar *calenderObj = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *startOfWeek;
    [calenderObj rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfWeek interval:nil forDate:[NSDate date]];
    
    NSDate *sectionDate = [startOfWeek dateByAddingTimeInterval:1 * 60 * 60 * 24 * (section / 3)];
    
    NSString *mealTitle;
    switch (section % 3) {
        case 0:
            mealTitle = kMorningMealTitle;
            break;
        case 1:
            mealTitle = kNoonMealTitle;
            break;
        case 2:
            mealTitle = kEveningMealTitle;
            break;
            
        default:
            NSLog(@"Section %ld %% 3 produced %d. Unknown meal type.", (long)section, section % 3);
            break;
    }
    
    NSString *sectionHeaderTitle = [NSString stringWithFormat:@"%@ %@", [allMenuSectionHeaderDateFormatter stringFromDate:sectionDate], mealTitle];
    
    return sectionHeaderTitle;
}

@end
