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
@property (readwrite) NSMutableArray<NSValue *> *weeksSet;

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
    _weeksSet = [decoder decodeObjectForKey:@"weeksSet"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_weeks forKey:@"weeks"];
    [encoder encodeObject:_weeksSet forKey:@"weeksSet"];
}

- (void)addWeek:(Week *)week {
    if (!_weeks)
        _weeks = [NSMutableArray array];
    
    if (!_weeksSet)
        _weeksSet = [NSMutableArray array];
    
    [_weeks addObject:week];
    [_weeksSet addObject:[NSNumber numberWithBool:NO]];
}

- (void)updateWeekIndex:(NSInteger)index withWeek:(Week *)week {
    //If array is not large enough, create space for enough additional weeks.
    while (!_weeks || _weeks.count < index + 1)
        [self addWeek:[Week new]];
    
    [_weeks replaceObjectAtIndex:index withObject:week];
    [_weeksSet replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
}

- (BOOL)allWeeksSet {
    if (!_weeksSet)
        return NO;
    
    for (NSValue *value in _weeksSet)
        if ([value isKindOfClass:[NSNumber class]] && ![(NSNumber *)value boolValue])
            return NO;
    
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
