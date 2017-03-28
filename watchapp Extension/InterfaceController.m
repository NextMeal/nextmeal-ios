//
//  NextMealInterfaceController.m
//  nextmeal
//
//  Created by Anson Liu on 3/27/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "InterfaceController.h"

#import "Constants.h"

#import "ItemRow.h"

#import "Menu.h"

@import WatchConnectivity;

@interface InterfaceController () <WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *noMenusLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *itemTable;

@property (nonatomic) Meal *nextMeal;

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if ([WCSession isSupported]) {
        WCSession *watchSession = [WCSession defaultSession];
        watchSession.delegate = self;
        [watchSession activateSession];
    }
    
    // Configure interface objects here.
    //Load and set user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kCachedMealKey:[NSData new]}];
    
    _nextMeal = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kCachedMealKey]];
    
    [self setupItemTable];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - UI setup methods

- (void)setupItemTable {
    if (!_nextMeal || _nextMeal.items.count == 0) {
        [_noMenusLabel setHidden:NO];
        [_itemTable setNumberOfRows:0 withRowType:@"ItemRow"];
        return;
    } else
        [_noMenusLabel setHidden:YES];
    
    [_itemTable setNumberOfRows:_nextMeal.items.count withRowType:@"ItemRow"];
    
    for (NSInteger i = 0; i < _nextMeal.items.count; i++) {
        ItemRow *row = [_itemTable rowControllerAtIndex:i];
        [row.itemTitleLabel setText:_nextMeal.items[i].title];
    }
}

#pragma mark - WCSession delegate

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    if (error)
        NSLog(@"error activationDidCompleteWithState %@", error.localizedDescription);
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    _nextMeal= [NSKeyedUnarchiver unarchiveObjectWithData:[applicationContext objectForKey:kNextMealKey]];
    
    //Save note array for future use
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_nextMeal] forKey:kCachedMealKey];
    
    [self setupItemTable];
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    NSLog(@"Did receive message %@", message);
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    
    return @{kItemTitleKey : _nextMeal.items.count > rowIndex ? [_nextMeal.items objectAtIndex:rowIndex].title : @"Out of bounds item."};
}


@end
