//
//  NextMenusDisplayTableViewControllerSubclass.h
//  nextmeal
//
//  Created by Anson Liu on 3/25/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#ifndef NextMenusDisplayTableViewControllerSubclass_h
#define NextMenusDisplayTableViewControllerSubclass_h

@class Menu;
@class Item;

@interface NextMenusDisplayTableViewController ()

@property NSArray<Meal *> *nextMenus;

#pragma mark - Logic methods

//Make sure valid menu is loaded when calling.
- (void)findNextMenus;

//Finds the week/day/meal index of the immediate next meal depending on device time.
- (void)nextMealWeekIndex:(NSInteger *)weekIndex dayIndex:(NSInteger *)dayIndex mealIndex:(NSInteger *)mealIndex;

//Finds the next meal indices based on the passed indices.
- (void)nextMealIndicesWeekIndex:(NSInteger *)weekIndex dayIndex:(NSInteger *)dayIndex mealIndex:(NSInteger *)mealIndex;

- (NSArray<Meal *> *)nextNthMealsN:(NSInteger)n previousNextMeals:(NSArray<Meal *> *)previousNextMeals weekIndex:(NSInteger)weekIndex dayIndex:(NSInteger)dayIndex mealIndex:(NSInteger)mealIndex;

- (Meal *)mealForSection:(NSInteger)section;

//Same as parent class method
- (Item *)itemForIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* NextMenusDisplayTableViewControllerSubclass_h */
