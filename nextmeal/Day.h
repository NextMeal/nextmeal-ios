//
//  Day.h
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Meal.h"

@interface Day : NSObject

@property (readonly) NSArray<Meal *> *meals;

- (void)addMeal:(Meal *)meal;

@end
