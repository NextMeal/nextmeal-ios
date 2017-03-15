//
//  Item.h
//  nextmeal
//
//  Created by Anson Liu on 3/11/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (readonly) NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end
