//
//  Week.h
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Day.h"

@interface Week : NSObject

@property (readonly) NSArray<Day *> *days;

- (void)addDay:(Day *)day;

@end
