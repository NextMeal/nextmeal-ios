//
//  Meal.h
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Item.h"

@interface Meal : NSObject

@property (readonly) NSArray<Item *> *items;

- (void)addItem:(Item *)item;

@end
