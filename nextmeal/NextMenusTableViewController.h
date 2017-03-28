//
//  NextMenusTableViewController.h
//  nextmeal
//
//  Created by Anson Liu on 3/14/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "AllMenusDisplayTableViewControllerSubclass.h"
#import "NextMenusDisplayTableViewController.h"
#import "NextMenusDisplayTableViewControllerSubclass.h"

@import WatchConnectivity;

@interface NextMenusTableViewController : NextMenusDisplayTableViewController <WCSessionDelegate>

@end
