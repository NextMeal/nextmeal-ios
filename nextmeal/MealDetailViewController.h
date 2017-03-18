//
//  MenuDetailViewController.h
//  nextmeal
//
//  Created by Anson Liu on 3/18/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Meal;

@interface MealDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSString *mealDateAndTitle;
@property Meal *loadedMeal;

@end
