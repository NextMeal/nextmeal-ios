//
//  AllMenusDisplayTableViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/25/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "AllMenusDisplayTableViewController.h"
#import "AllMenusDisplayTableViewControllerSubclass.h"

#import "Constants.h"
#import "Menu.h"

@interface AllMenusDisplayTableViewController ()


@end

@implementation AllMenusDisplayTableViewController

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;
    
    return self;
}

#pragma mark - ParseMenuProtocol methods

- (void)getMenuOnlineResultWithMenu:(Menu *)outputMenu withUpdateDate:(NSDate *)updateDate withURLResponse:(NSURLResponse *)response withError:(NSError *)error {
    
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
    //Setup date formatter
    NSDateFormatter *allMenuSectionHeaderDateFormatter = [[NSDateFormatter alloc] init];
    allMenuSectionHeaderDateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    allMenuSectionHeaderDateFormatter.dateFormat = @"EEEE MM/dd/yy";
    allMenuSectionHeaderDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    //Determine NSDate of start of current week
    NSCalendar *calenderObj = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *startOfWeek;
    [calenderObj rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfWeek interval:nil forDate:[NSDate date]];
    
    //Determine the date of the section from the section index.
    NSDate *sectionDate = [startOfWeek dateByAddingTimeInterval:1 * 60 * 60 * 24 * (section / 3)];
    
    //Determine which meal the section is for by the section index.
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
            NSLog(@"Section %ld produced %ld. Unknown meal type.", (long)section, (long)section % 3);
            break;
    }
    
    //Build section header title using the date of section and section meal.
    NSString *sectionHeaderTitle = [NSString stringWithFormat:@"%@ %@", [allMenuSectionHeaderDateFormatter stringFromDate:sectionDate], mealTitle];
    
    return sectionHeaderTitle;
}

#pragma mark - VC lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
