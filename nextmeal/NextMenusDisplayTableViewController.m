//
//  NextMenusDisplayTableViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/25/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "NextMenusDisplayTableViewController.h"
#import "NextMenusDisplayTableViewControllerSubclass.h"

#import "Constants.h"
#import "Menu.h"

@interface NextMenusDisplayTableViewController ()

@end

@implementation NextMenusDisplayTableViewController

#pragma mark - Logic methods

//Make sure valid menu is loaded when calling.
- (void)findNextMenus {
    NSInteger weekIndex = 0;
    NSInteger dayIndex = 0;
    NSInteger mealIndex = 0;
    
    [self nextMealWeekIndex:&weekIndex dayIndex:&dayIndex mealIndex:&mealIndex];
    
    //Only load the next three meal indexes into an array if the menu has been loaded. On initial run there will be no menu.
    if (self.loadedMenu)
        _nextMenus = [self nextNthMealsN:kNumberOfNextMealsShown previousNextMeals:[NSArray<Meal *> new] weekIndex:weekIndex dayIndex:dayIndex mealIndex:mealIndex];
}

//Finds the week/day/meal index of the immediate next meal depending on device time.
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

//Finds the next meal indices based on the passed indices.
- (void)nextMealIndicesWeekIndex:(NSInteger *)weekIndex dayIndex:(NSInteger *)dayIndex mealIndex:(NSInteger *)mealIndex {
    *mealIndex += 1;
    if (*mealIndex > 2) {
        *mealIndex = 0;
        *dayIndex += 1;
        if (*dayIndex > 6) {
            *dayIndex = 0;
            *weekIndex += 1;
        }
    }
}

- (NSArray<Meal *> *)nextNthMealsN:(NSInteger)n previousNextMeals:(NSArray<Meal *> *)previousNextMeals weekIndex:(NSInteger)weekIndex dayIndex:(NSInteger)dayIndex mealIndex:(NSInteger)mealIndex {
    if (n > 0) {
        //Add the next meal to the meal array
        previousNextMeals = [previousNextMeals arrayByAddingObject:[[[self.loadedMenu.weeks objectAtIndex:weekIndex].days objectAtIndex:dayIndex].meals objectAtIndex:mealIndex]];
        
        //Compute the next meal indices
        [self nextMealIndicesWeekIndex:&weekIndex dayIndex:&dayIndex mealIndex:&mealIndex];
        
        //Recurse
        return [self nextNthMealsN:n - 1 previousNextMeals:previousNextMeals weekIndex:weekIndex dayIndex:dayIndex mealIndex:mealIndex];
    } else {
        return previousNextMeals;
    }
}

- (Meal *)mealForSection:(NSInteger)section {
    return [_nextMenus objectAtIndex:section];
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
    
    //Add one additional section for the version number.
    return (numberOfMeals < kNumberOfNextMealsShown ? numberOfMeals : kNumberOfNextMealsShown) + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Return 0 rows for the last section which shows the app version number.
    if (section == tableView.numberOfSections - 1)
        return 0;
    
    return [self mealForSection:section].items.count < kMaxItemsShownNextMeal + 1 ? [self mealForSection:section].items.count : kMaxItemsShownNextMeal + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"NextMenusReuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (indexPath.row == kMaxItemsShownNextMeal) {
        cell.textLabel.text = @"View more";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.textLabel.text = [self itemForIndexPath:indexPath].title;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //Return app version number for the last section which shows the app version number.
    if (section == tableView.numberOfSections - 1)
        return [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    //Setup date formatter
    NSDateFormatter *allMenuSectionHeaderDateFormatter = [[NSDateFormatter alloc] init];
    allMenuSectionHeaderDateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    allMenuSectionHeaderDateFormatter.dateFormat = @"EEEE";
    allMenuSectionHeaderDateFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    //Determine NSDate of start of current week
    NSCalendar *calenderObj = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *startOfWeek;
    [calenderObj rangeOfUnit:NSCalendarUnitWeekOfYear startDate:&startOfWeek interval:nil forDate:[NSDate date]];
    
    //Determine the immediate next meal indices
    NSInteger weekIndex = 0;
    NSInteger dayIndex = 0;
    NSInteger mealIndex = 0;
    [self nextMealWeekIndex:&weekIndex dayIndex:&dayIndex mealIndex:&mealIndex];
    
    //Continue finding the next meal indices if needed based on the section index.
    for (NSInteger i = 0; i < section; i++)
        [self nextMealIndicesWeekIndex:&weekIndex dayIndex:&dayIndex mealIndex:&mealIndex];
    
    //Determine the date of the section from the next weekIndex and dayIndex.
    NSDate *sectionDate = [startOfWeek dateByAddingTimeInterval:60 * 60 * 24 * 7 * weekIndex + 60 * 60 * 24 * dayIndex];
    
    //Determine which meal the section is for by the mealIndex.
    NSString *mealTitle;
    switch (mealIndex) {
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
            NSLog(@"Section %ld %% 3 produced %ld. Unknown meal type.", (long)section, section % 3);
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
    // Dispose of any resources that can be recreated.
}

@end
