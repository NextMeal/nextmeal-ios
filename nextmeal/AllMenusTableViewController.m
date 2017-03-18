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

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ParseMenuProtocol methods

- (void)getMenuOnlineResultWithMenu:(Menu *)outputMenu withURLResponse:(NSURLResponse *)response withError:(NSError *)error {
    Menu *responseMenu = outputMenu;
    if (responseMenu) {
        _loadedMenu = responseMenu;
     
        //Update menu date in preferences
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kMenuLastUpdatedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self setRefreshControlTitle];
        
        if (self.tableView) {
            [self.tableView reloadData];
            
        }
    }
    
    //If the table view is not loaded yet, do nothing else.
    [self.refreshControl endRefreshing];
}


#pragma mark - Reload data and UI methods

- (void)setRefreshControlTitle {
    //Setup UIRefreshControl initially
    if (!self.refreshControl) {
        self.refreshControl = [UIRefreshControl new];
        [self.refreshControl addTarget:self action:@selector(reloadMenuData) forControlEvents:UIControlEventValueChanged];
    }
    
    //Retrieve last updated time from preferences
    NSUserDefaults *userDefaultsInstance = [NSUserDefaults standardUserDefaults];
    //[userDefaultsInstance registerDefaults:@{ kMenuLastUpdatedKey : [NSNull null] }];
    id menuLastUpdatedObject = [userDefaultsInstance objectForKey:kMenuLastUpdatedKey];
    
    //Setup date formatter
    NSDateFormatter *refreshControlTimeFormatter = [[NSDateFormatter alloc] init];
    refreshControlTimeFormatter.locale = [NSLocale autoupdatingCurrentLocale];
    refreshControlTimeFormatter.dateFormat = @"EEEE @ HH:mm";
    refreshControlTimeFormatter.timeZone = [NSTimeZone systemTimeZone];
    
    //Determine refresh control title text
    NSString *timeString = [NSString stringWithFormat:@"Last Updated %@", menuLastUpdatedObject ? [NSString stringWithFormat:@"on %@", [refreshControlTimeFormatter stringFromDate:menuLastUpdatedObject]] : @"Never"];
    
    //Set refresh control title
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:timeString];

}

- (void)reloadMenuData {
    _loadedMenu = [ParseMenu retrieveSavedMenus];
    [ParseMenu retrieveMenusWithDelegate:self];
}

- (void)reloadMenuDataAndTableView {
    [self.refreshControl beginRefreshing];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [self reloadMenuData];
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
