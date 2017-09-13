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

#import "ReadWriteLocalData.h"

@interface AllMenusTableViewController ()

@end

@implementation AllMenusTableViewController

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;

    return self;
}

#pragma mark - ParseMenuProtocol methods

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
            
            if (self.navigationItem.prompt)
                self.navigationItem.prompt = nil;
            
            [self.tableView reloadData];
        }
    }
    
    //Set class variable to indicate no menu refresh operation in progress.
    self.refreshingMenu = NO;
    
    [self stopRefreshingElements];
}


#pragma mark - Reload data and UI methods

- (void)startRefreshingElements {
    [self.refreshControl beginRefreshing];
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopRefreshingElements {
    [self.refreshControl endRefreshing];
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)refreshControlPulled {
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
    if (!error) {
        self.loadedMenu = savedMenu;
        [self.tableView reloadData];
        if (self.navigationItem.prompt)
            self.navigationItem.prompt = nil;
    } else
        self.navigationItem.prompt = [error localizedDescription];
}

- (void)reloadMenuDataLocalAndRemote {
    if (!self.loadedMenu) {
        [self reloadMenuDataFromLocal];
    }
    
    [ParseMenu retrieveMenusWithDelegate:self withOriginType:NMForeground];
}

- (void)reloadMenuDataAndTableView {
    //If menu refresh operation already in progress, do nothing. Avoid mutating objects while enumerating them in menu parsing methods. Found in Fabric crashlytics
    if (self.refreshingMenu == YES) {
        //Do not "stop" refreshing elements, let UI keep "refreshing" state
        return;
    }
    
    //Retrieve last updated time from preferences
    NSUserDefaults *userDefaultsInstance = [NSUserDefaults standardUserDefaults];
    //[userDefaultsInstance registerDefaults:@{ kMenuLastUpdatedKey : [NSNull null] }];
    id menuLastUpdatedObject = [userDefaultsInstance objectForKey:kMenuLastUpdatedKey];
    //If last updated time is within 10 seconds of current time, do not update.
    if (menuLastUpdatedObject && [[NSDate date] timeIntervalSinceDate:menuLastUpdatedObject] < 10) {
        [self stopRefreshingElements];
        [self reloadMenuDataFromLocal]; //reload table in case view just loaded and table isn't populated.
        return;
    }
    
    //Set class variable to indicate refresh in progress.
    self.refreshingMenu = YES;
    
    [self startRefreshingElements];
    [self reloadMenuDataLocalAndRemote];
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
