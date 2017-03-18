//
//  NextThreeTableViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/14/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "NextThreeTableViewController.h"

#import "Menu.h"

@interface NextThreeTableViewController ()

@property NSArray<Meal *> *nextThreeMenus;

@end

@implementation NextThreeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reload data and UI methods

- (void)findNextThreeMenus {
    NSInteger weekIndex = 0;
    NSInteger dayIndex = 0;
    NSInteger mealIndex = 0;
    
    [self nextMealWeekIndex:&weekIndex dayIndex:&dayIndex mealIndex:&mealIndex];
    
    //Only load the next three meal indexes into an array if the menu has been loaded. On initial run there will be no menu.
    if (self.loadedMenu)
        _nextThreeMenus = [self nextNthMealsN:3 previousNextMeals:[NSArray<Meal *> new] weekIndex:weekIndex dayIndex:dayIndex mealIndex:mealIndex];
}

- (void)reloadMenuData {
    [super reloadMenuData];
    
    [self findNextThreeMenus];
}

- (void)reloadMenuDataAndTableView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [self reloadMenuData];
        [self findNextThreeMenus];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Logic methods

//Finds the week/day/meal index of the next meal depending on device time.
- (void)nextMealWeekIndex:(NSInteger *)weekIndex dayIndex:(NSInteger *)dayIndex mealIndex:(NSInteger *)mealIndex {
    //Calculate days since start of week is today.
    NSCalendar *calenderObj = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *startOfWeek;
    [calenderObj rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfWeek interval:nil forDate:[NSDate date]];
    NSTimeInterval secondsSinceStartOfWeek = [[NSDate date] timeIntervalSinceDate:startOfWeek];
    NSInteger daysSinceStartOfWeek = secondsSinceStartOfWeek / (60 * 60 * 24);
    
    //Determine which index of day is today. If next meal is tomorrow, we handle it further below.
    *dayIndex = daysSinceStartOfWeek;
    

    //Calculate seconds since previous midnight.
    NSCalendar *gregorianCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [gregorianCal components: (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
    NSInteger currentSecondsSinceMidnight = [dateComps hour] * 60 * 60 + [dateComps minute] * 60 + [dateComps minute];
    
    //Determine which type/index of meal is next.
    if (currentSecondsSinceMidnight < 60 * 60 * 8) { //0800
        *mealIndex = 0;
    } else if (currentSecondsSinceMidnight < 60 * 60 * 13 + 60 * 30) { //1330
        *mealIndex = 1;
    } else if (currentSecondsSinceMidnight < 60 * 60 * 20) { //2000
        *mealIndex = 2;
    } else { //2000-2359
        *mealIndex = 0;
        
        //The next meal is tomorrow so increment the dayIndex.
        *dayIndex += 1;
        //If the day in next week, set dayIndex to 0 and increment weekIndex.
        if (*dayIndex > 6) {
            *dayIndex = 0;
            *weekIndex += 1;
        }
    }
}

- (NSArray<Meal *> *)nextNthMealsN:(NSInteger)n previousNextMeals:(NSArray<Meal *> *)previousNextMeals weekIndex:(NSInteger)weekIndex dayIndex:(NSInteger)dayIndex mealIndex:(NSInteger)mealIndex {
    if (n > 0) {
        if (mealIndex > 2) {
            mealIndex = 0;
            dayIndex += 1;
            if (dayIndex > 6) {
                dayIndex = 0;
                weekIndex += 1;
            }
        }
        return [self nextNthMealsN:n - 1 previousNextMeals:[previousNextMeals arrayByAddingObject:[[[self.loadedMenu.weeks objectAtIndex:weekIndex].days objectAtIndex:dayIndex].meals objectAtIndex:mealIndex]] weekIndex:weekIndex dayIndex:dayIndex mealIndex:mealIndex + 1];
    } else {
        return previousNextMeals;
    }
}

- (Meal *)mealForSection:(NSInteger)section {
    return [_nextThreeMenus objectAtIndex:section];
}

//Same as parent class method
- (Item *)itemForIndexPath:(NSIndexPath *)indexPath {
    Item *indexPathItem = [[self mealForSection:indexPath.section].items objectAtIndex:indexPath.row];
    
    return indexPathItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfMeals = 0;
    for (Week *week in self.loadedMenu.weeks)
        for (Day *day in week.days)
            numberOfMeals += day.meals.count;
                
    return numberOfMeals < 3 ? numberOfMeals : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self mealForSection:section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"NextThreeReuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self itemForIndexPath:indexPath].title;
    return cell;
}

@end
