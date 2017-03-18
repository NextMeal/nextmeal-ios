//
//  Week.m
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "Week.h"

@interface Week ()

@property (readwrite) NSArray<Day *> *days;

@end

@implementation Week

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
    
    _days = [decoder decodeObjectForKey:@"days"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_days forKey:@"days"];
}

- (void)addDay:(Day *)day {
    if (!_days)
        _days = [NSArray array];
    
    _days = [_days arrayByAddingObject:day];
}

@end
