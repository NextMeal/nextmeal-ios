//
//  Menu.m
//  nextmeal
//
//  Created by Anson Liu on 3/13/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "Menu.h"

@interface Menu ()

@property (readwrite) NSMutableArray<Week *> *weeks;

@end

@implementation Menu

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
    
    _weeks = [decoder decodeObjectForKey:@"weeks"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_weeks forKey:@"weeks"];
}

- (void)addWeek:(Week *)week {
    if (!_weeks)
        _weeks = [NSMutableArray array];
    
    [_weeks addObject:week];
}

- (void)updateWeekIndex:(NSInteger)index withWeek:(Week *)week {
    //If array is not large enough, create space for enough additional weeks.
    while (!_weeks || _weeks.count < index + 1)
        [self addWeek:[Week new]];
    
    [_weeks replaceObjectAtIndex:index withObject:week];
}

//Check day count and meal counts.
- (BOOL)allWeeksValid {
    for (Week *week in _weeks) {
        if (!week || week.days.count != 7)
            return NO;
        for (Day *day in week.days) {
            if (!day || day.meals.count != 3)
                return NO;
            for (Meal *meal in day.meals)
                if (!meal)
                    return NO;
        }
    }
         
    return YES;
}

/*
- (BOOL)allWeeksLoadedWithSevenDays {
    for (Week *week in _weeks)
        if (week.days.count != 7)
            return NO;
    
    return YES;
}
 */

@end
