//
//  AllMenusTableViewController.h
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "AllMenusDisplayTableViewController.h"
#import "AllMenusDisplayTableViewControllerSubclass.h"

#import "Menu.h"

@interface AllMenusTableViewController : AllMenusDisplayTableViewController

- (void)reloadMenuData;
- (void)reloadMenuDataAndTableView;

@end
