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
#import "NMMultipeer.h"
#import "ReadWriteLocalData.h"

#import "ParseMenu.h"

@interface NextMenusTableViewController ()

@property NMMultipeer *localPeerManager;

@end

@implementation NextMenusTableViewController

#pragma mark - WCSession methods

- (void)sendMealToWatch:(Meal *)targetMeal {
    if ([[WCSession defaultSession] isPaired]) {
        NSError *sessionError;
        NSData *mealData = [NSKeyedArchiver archivedDataWithRootObject:targetMeal];
        [[WCSession defaultSession] updateApplicationContext:@{kNextMealKey : mealData} error:&sessionError];
        //NSLog(@"length %lu", (unsigned long)[NSKeyedArchiver archivedDataWithRootObject:targetMeal].length);
        //[[WCSession defaultSession] updateApplicationContext:@{kNextMealKey : @"test text"} error:&sessionError];
        if (sessionError) {
            NSLog(@"Error updating app context to WCSession %@", sessionError.localizedDescription);
        }
    }
}

- (void)setupWatchConnection {
    //Initialize WCSession
    if ([WCSession isSupported]) {
        WCSession *watchSession = [WCSession defaultSession];
        watchSession.delegate = self;
        [watchSession activateSession];
    }
}

#pragma mark - WCSession Delegate

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    if (error) {
        NSLog(@"Error activating session %@", error.localizedDescription);
    }
}

- (void)sessionDidDeactivate:(WCSession *)session {
    NSLog(@"session deactivate");
}

- (void)sessionDidBecomeInactive:(WCSession *)session {
    NSLog(@"session inactive");
    
}

#pragma mark - P2P methods

- (void)startAndUpdateLocalPeerManager {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingsP2PKey] == YES) {
        if (!_localPeerManager) {
            _localPeerManager = [NMMultipeer new];
            _localPeerManager.delegate = self;
        }
        [_localPeerManager startAdvertisingAndBrowsingWithMenu:self.loadedMenu andDate:[[NSUserDefaults standardUserDefaults] objectForKey:kMenuLastUpdatedKey]];
    } else {
        if (_localPeerManager) {
            [_localPeerManager stopAdvertisingAndBrowsing];
            _localPeerManager = nil;
        }
    }
}

#pragma mark - ParseMenuProtocol methods

//Call on main thread!
- (void)getMenuOnlineResultWithMenu:(Menu *)outputMenu withUpdateDate:(NSDate *)updateDate withURLResponse:(NSURLResponse *)response withError:(NSError *)error {
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
        if (responseMenu.allWeeksValid) {
            self.loadedMenu = responseMenu;
            
            //Update menu date in preferences
            [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:kMenuLastUpdatedKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //Block for saving menu to disk
            void (^saveMenu)(Menu *) = ^void(Menu *outputMenu) {
                NSData *menuData = [NSKeyedArchiver archivedDataWithRootObject:outputMenu];
                [ReadWriteLocalData saveData:menuData withFilename:kMenuLastSavedFilename];
            };
            saveMenu(responseMenu);
            
            [self setRefreshControlTitle];
            
            self.navigationItem.prompt = nil;
            
            [self findNextMenus];
            [self.tableView reloadData];
            
            //Send the next meal to the watch
            [self sendMealToWatch:self.nextMenus.count > 0 ? self.nextMenus[0] : nil];
            
            //Update and restart P2P. We only need to do this if we have new valid data to update the discovery info with. Otherwise, we already restarted P2P right after local menu refresh in reloadMenuDataLocalAndRemote.
            [self startAndUpdateLocalPeerManager];
        } else {
            NSLog(@"Menu did not pass allWeeksValid check.\n%@", responseMenu);
        }
    }
    
    [self stopRefreshingElements];
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

- (void)refreshControlPulled {
    //Retrieve last updated time from preferences
    NSUserDefaults *userDefaultsInstance = [NSUserDefaults standardUserDefaults];
    //[userDefaultsInstance registerDefaults:@{ kMenuLastUpdatedKey : [NSNull null] }];
    id menuLastUpdatedObject = [userDefaultsInstance objectForKey:kMenuLastUpdatedKey];
    //If last updated time is within 10 seconds of current time, do not update.
    if (menuLastUpdatedObject && [[NSDate date] timeIntervalSinceDate:menuLastUpdatedObject] < 10) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    [self reloadMenuDataAndTableView];
}

- (void)setRefreshControlTitle {
    //Setup UIRefreshControl initially
    if (!self.refreshControl) {
        self.refreshControl = [UIRefreshControl new];
        [self.refreshControl addTarget:self action:@selector(refreshControlPulled) forControlEvents:UIControlEventValueChanged];
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

- (void)reloadMenuDataFromLocal {
    NSError *error;
    Menu *savedMenu = [ParseMenu retrieveSavedMenusWithError:&error];
    if (!error)
        self.loadedMenu = savedMenu;
    else
        self.navigationItem.prompt = [error localizedDescription];
}

- (void)reloadMenuDataLocalAndRemote {
    if (!self.loadedMenu) {
        [self reloadMenuDataFromLocal];
    }
    
    if ([self.loadedMenu allWeeksValid]) {
        [self findNextMenus];
        [self.tableView reloadData];
        
        //Send the next meal to the watch
        [self sendMealToWatch:self.nextMenus ? self.nextMenus[0] : nil];
        
    } else {
        NSLog(@"Menu did not pass allWeeksValid check.\n%@", self.loadedMenu);
    }
    
    [self startAndUpdateLocalPeerManager];
    
    [ParseMenu retrieveMenusWithDelegate:self withOriginType:NMForeground];
}

- (void)reloadMenuDataAndTableView {
    [self startRefreshingElements];
    [self reloadMenuDataLocalAndRemote];
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


- (void)showSection:(NSNotification *)notification {
    [self reloadMenuDataLocalAndRemote];
    
    NSUInteger targetSection = [[notification.userInfo valueForKey:kSelectedSectionKey] unsignedIntegerValue];
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:targetSection] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self performSegueWithIdentifier:@"MealDetailSegue" sender:self];
}

#pragma mark - VC lifecycle methods

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWatchConnection];
    
    [self setRefreshControlTitle];
    [self reloadMenuDataAndTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSection:) name:kNotificationLoadSection object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
