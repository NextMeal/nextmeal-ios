//
//  AllMenusViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "AllMenusViewController.h"

#import "AllMenusTableViewController.h"

@interface AllMenusViewController ()

@property (nonatomic) AllMenusTableViewController *menuTableVC;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@end

@implementation AllMenusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _menuTableVC = [[AllMenusTableViewController alloc] init];
    _menuTableVC.tableView = _menuTableView;
    [_menuTableVC reloadMenuData];
    
    _menuTableView.dataSource = _menuTableVC;
    _menuTableView.delegate = _menuTableVC;
    
    [_menuTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
