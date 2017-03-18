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
    if (!_weeks)
        _weeks = [NSMutableArray array];
    
    //If array is not large enough, create space for enough additional weeks.
    while (_weeks.count < index + 1)
        [_weeks addObject:[Week new]];
    
    [_weeks replaceObjectAtIndex:index withObject:week];
}

@end
