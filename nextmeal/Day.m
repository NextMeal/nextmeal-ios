//
//  Day.m
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "Day.h"

@interface Day ()

@property (readwrite) NSArray<Meal *> *meals;

@end

@implementation Day

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
    
    _meals = [decoder decodeObjectForKey:@"meals"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_meals forKey:@"meals"];
}

- (void)addMeal:(Meal *)meal {
    if (!_meals)
        _meals = [NSArray array];
    
    _meals = [_meals arrayByAddingObject:meal];
}

@end
