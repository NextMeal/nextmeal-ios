//
//  Item.m
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "Item.h"

@interface Item ()

@property (readwrite) NSString *title;

@end

@implementation Item

- (instancetype)init {
    self = [super init];
    if (!self)
        return nil;
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [self init];
    if (!self)
        return nil;
    
    _title = title;
    
    return self;
}


- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _title = [decoder decodeObjectForKey:@"itemTitle"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_title forKey:@"itemTitle"];
}

@end
