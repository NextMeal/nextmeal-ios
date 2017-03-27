//
//  NextMenusTableViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/14/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "NextMenusTableViewController.h"

#import "Constants.h"
#import "Menu.h"
#import "MealDetailViewController.h"
#import "NMMultiPeer.h"
#import "ReadWriteLocalData.h"

#import "ParseMenu.h"

@interface NextMenusTableViewController ()

@property NMMultipeer *localPeerManager;

@end

@implementation NextMenusTableViewController

#pragma mark - ParseMenuProtocol methods

//Call on main thread!
- (void)getMenuOnlineResultWithMenu:(Menu *)outputMenu withURLResponse:(NSURLResponse *)response withError:(NSError *)error {
    if (error) {
        NSLog(@"Error getting menu %@", [error localizedDescription]);
        self.navigationItem.prompt = [error localizedDescription];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(5);
            if ([self.navigationItem.prompt isEqual:[error localizedDescription]])
                self.navigationItem.prompt = nil;
        });
        
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
        }
    }
    
    [self stopRefreshingElements];
    
    if (self.loadedMenu) {
        [self findNextMenus];
        [self.tableView reloadData];
    }
    
    if (!_localPeerManager) {
        _localPeerManager = [NMMultipeer new];
        _localPeerManager.delegate = self;
    }
    [_localPeerManager startAdvertisingAndBrowsingWithMenu:self.loadedMenu andDate:[[NSUserDefaults standardUserDefaults] objectForKey:kMenuLastUpdatedKey]];
}

#pragma mark - Reload data and UI methods

- (void)startRefreshingElements {
    [self.refreshControl beginRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopRefreshingElements {
    [self.refreshControl endRefreshing];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    
    if (!_localPeerManager) {
        _localPeerManager = [NMMultipeer new];
        _localPeerManager.delegate = self;
    }
    [_localPeerManager startAdvertisingAndBrowsingWithMenu:self.loadedMenu andDate:[[NSUserDefaults standardUserDefaults] objectForKey:kMenuLastUpdatedKey]];
}

- (void)reloadMenuDataAndTableView {
    [self startRefreshingElements];
    [self reloadMenuData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"MealDetailSegue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MealDetailViewController *mealDetailVC = [segue destinationViewController];
    mealDetailVC.mealDateAndTitle = [self tableView:self.tableView titleForHeaderInSection:self.tableView.indexPathForSelectedRow.section];
    mealDetailVC.loadedMeal = [self.nextMenus objectAtIndex:self.tableView.indexPathForSelectedRow.section];
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

@end
