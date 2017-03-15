//
//  AllMenusTableViewController.h
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Menu.h"

@interface AllMenusTableViewController : UITableViewController

@property (nonatomic, copy, readwrite) Menu *loadedMenu;

- (void)reloadMenuData;
- (void)reloadMenuDataAndTableView;

@end
