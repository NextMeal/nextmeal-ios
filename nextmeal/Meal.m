//
//  Meal.m
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "Meal.h"

@interface Meal ()

@property (readwrite) NSArray<Item *> *items;

@end

@implementation Meal

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _items = [decoder decodeObjectForKey:@"items"];
    
    return self;
}

- (void)addItem:(Item *)item {
    if (!_items)
        _items = [NSArray array];
    
    _items = [_items arrayByAddingObject:item];
}

@end
