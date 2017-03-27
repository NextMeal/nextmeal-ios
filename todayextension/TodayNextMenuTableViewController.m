//
//  TodayViewController.m
//  todayextension
//
//  Created by Anson Liu on 3/24/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "TodayNextMenuTableViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "Constants.h"

#import "ReadWriteLocalData.h"
#import "ParseMenu.h"

@interface TodayNextMenuTableViewController () <NCWidgetProviding>

@property void (^widgetPerformUpdateCompletionHandler)(NCUpdateResult);

@end

@implementation TodayNextMenuTableViewController

#pragma mark - ParseMenuProtocol methods

//Call on main thread!
- (void)getMenuOnlineResultWithMenu:(Menu *)outputMenu withURLResponse:(NSURLResponse *)response withError:(NSError *)error {
    NCUpdateResult updateResult = NCUpdateResultNoData;
    
    if (error) {
        NSLog(@"Error getting menu %@", [error localizedDescription]);
        self.navigationItem.prompt = [error localizedDescription];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(5);
            if ([self.navigationItem.prompt isEqual:[error localizedDescription]])
                self.navigationItem.prompt = nil;
        });
        updateResult = NCUpdateResultFailed;
    } else {
        Menu *responseMenu = outputMenu;
        if (responseMenu) {
            self.loadedMenu = responseMenu;
            
            //Update menu date in preferences
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kMenuLastUpdatedKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //Block for saving menu to disk
            void (^saveMenu)(Menu *) = ^void(Menu *outputMenu) {
                NSData *menuData = [NSKeyedArchiver archivedDataWithRootObject:outputMenu];
                [ReadWriteLocalData saveData:menuData withFilename:kMenuLastSavedFilename];
            };
            saveMenu(responseMenu);
            
            [self setRefreshControlTitle];
            
            self.navigationItem.prompt = nil;
            
            [self.tableView reloadData];
            
            updateResult = NCUpdateResultNewData;
        }
    }
    
    [self stopRefreshingElements];
    
    if (self.loadedMenu) {
        [self findNextMenus];
        [self.tableView reloadData];
    }
    
    [self computePreferredSize];
    
    if (_widgetPerformUpdateCompletionHandler != nil) {
        _widgetPerformUpdateCompletionHandler(updateResult);
        _widgetPerformUpdateCompletionHandler = nil;
    }
}

#pragma mark - UI methods CUSTOM

- (void)computePreferredSize {
    self.preferredContentSize = CGSizeMake(0, [self.tableView numberOfRowsInSection:0] * self.tableView.rowHeight);
}

#pragma mark - Reload data and UI methods

- (void)startRefreshingElements {
    [self.refreshControl beginRefreshing];
}

- (void)stopRefreshingElements {
    [self.refreshControl endRefreshing];
}

- (void)setRefreshControlTitle {
    //Setup UIRefreshControl initially
    if (!self.refreshControl) {
        self.refreshControl = [UIRefreshControl new];
        [self.refreshControl addTarget:self action:@selector(reloadMenuDataAndTableView) forControlEvents:UIControlEventValueChanged];
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
    NSError *error;
    Menu *savedMenu = [ParseMenu retrieveSavedMenusWithError:&error];
    if (!error)
        self.loadedMenu = savedMenu;
    else
        self.navigationItem.prompt = [error localizedDescription];
    
    [self.tableView reloadData];
    
    [ParseMenu retrieveMenusWithDelegate:self withOriginType:NMForeground];
    
    
    if ([self.loadedMenu allWeeksValid]) {
        [self findNextMenus];
        [self.tableView reloadData];
    } else {
        NSLog(@"Menu did not pass allWeeksValid check.\n%@", self.loadedMenu);
    }
    
    [self computePreferredSize];
}

- (void)reloadMenuDataAndTableView {
    [self startRefreshingElements];
    [self reloadMenuData];
}

#pragma mark - Table view data source. MODIFIED FROM NEXTMENUSDISPLAY CLASS

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNumberOfNextMealsShownWidget;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self mealForSection:section].items.count < kMaxItemsShownNextMealWidget + 1 ? [self mealForSection:section].items.count : kMaxItemsShownNextMealWidget + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"NextMenusReuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (indexPath.row == kMaxItemsShownNextMealWidget) {
        cell.textLabel.text = @"View more";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.textLabel.text = [self itemForIndexPath:indexPath].title;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"clicked");
}

#pragma mark - VC lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRefreshControlTitle];
    [self reloadMenuDataAndTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    //Save completion handler to call when update is done. This is sort of a one off class, so we will not deal with passing it as a parameter.
    _widgetPerformUpdateCompletionHandler = completionHandler;
    [self reloadMenuDataAndTableView];
}

@end
