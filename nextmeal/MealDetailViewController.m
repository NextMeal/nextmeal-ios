//
//  MenuDetailViewController.m
//  nextmeal
//
//  Created by Anson Liu on 3/18/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "MealDetailViewController.h"

#import "Meal.h"

@interface MealDetailViewController ()
@property (strong, nonatomic) IBOutlet UITableView *mealDetailTableView;

@end

@implementation MealDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mealDetailTableView.dataSource = self;
    _mealDetailTableView.delegate = self;
    
    self.navigationItem.title = _mealDateAndTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _loadedMeal.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"MealDetailReuseIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_loadedMeal.items objectAtIndex:indexPath.row].title;
    return cell;
}

@end
