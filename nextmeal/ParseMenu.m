//
//  ParseMenu.m
//  nextmeal
//
//  Created by Anson Liu on 3/12/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "ParseMenu.h"

#import "Constants.h"

#import "ReadWriteLocalData.h"

@implementation ParseMenu

+ (NSData *)readSampleLocalNumber:(NSInteger)number {
    NSString *filename;
    switch (number) {
            case 1:
                filename = kSampleFilename1;
                break;
            case 2:
                filename = kSampleFilename2;
                break;
            default:
            NSLog(@"unhandled sample file number %ld", (long)number);
    }
    return [ReadWriteLocalData readFileFromBundle:filename];
}

+ (Item *)parseItem:(NSObject *)itemData {
    if (![itemData isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parsed itemData is not of kind class NSDictionary.\n%@", itemData);
    }
    
    NSString *itemTitle = [((NSDictionary *)itemData) objectForKey:kMealItemTitleKey];
    
    if (!itemTitle)
        NSLog(@"Parsed itemData has no key %@.\n%@", kMealItemTitleKey, itemData);
    
    if (itemTitle.length == 0)
        //item title is blank, skip
        return nil;
    
    Item *outputItem = [[Item alloc] initWithTitle:itemTitle];
    
    return outputItem;
}

+ (Meal *)parseMeal:(NSObject *)mealData {
    if (![mealData isKindOfClass:[NSArray class]]) {
        NSLog(@"Parsed mealData is not of kind class NSArray.\n%@", mealData);
    }
    
    Meal *outputMeal = [Meal new];
    
    for (NSObject *itemData in (NSArray *)mealData) {
        Item *outputItem = [self parseItem:itemData];
        if (outputItem)
            [outputMeal addItem:outputItem];
    }
    
    return outputMeal;
}

+ (Day *)parseDay:(NSObject *)dayData {
    if (![dayData isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parsed dayData is not of kind class NSDictionary.\n%@", dayData);
    }
    
    Day *outputDay = [Day new];
    
    NSArray<NSString *> *mealKeys = @[kBreakfastKey, kLunchKey, kDinnerKey];
    
    NSArray<NSObject *> *mealDatas = [((NSDictionary *)dayData) objectsForKeys:mealKeys notFoundMarker:[NSObject new]];
    
    for (NSObject *mealData in mealDatas) {
        [outputDay addMeal:[self parseMeal:mealData]];
    }
    
    return outputDay;
}

+ (Week *)parseWeek:(NSObject *)weekData {
    if (![weekData isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parsed object is not of kind class NSDictionary.\n%@", weekData);
    }
    
    NSArray<NSString *> *dayKeys = @[kSundayKey, kMondayKey, kTuesdayKey, kWednesdayKey, kThursdayKey, kFridayKey, kSaturdayKey];
    
    NSArray<NSObject *> *dayDatas = [((NSDictionary *)weekData) objectsForKeys:dayKeys notFoundMarker:[NSObject new]];
    
    Week *outputWeek = [Week new];
    
    for (NSObject *dayData in dayDatas) {
        [outputWeek addDay:[self parseDay:dayData]];
    }
    
    return outputWeek;
}

+ (Week *)parseMenu:(NSData *)menuData {
    NSError *parseError;
    NSObject *weekData = [NSJSONSerialization JSONObjectWithData:menuData options:0 error:&parseError];
    
    if (parseError)
        NSLog(@"Error parsing data.\n%@\n%@", [parseError localizedDescription], menuData);
    
    return [self parseWeek:weekData];
}

+ (Menu *)retrieveMenus {
    Menu *outputMenu = [Menu new];
    
    if (kDebug) {
        for (int i = 1; i < 3; i++) {
            NSData *menuData = [self readSampleLocalNumber:i];
            [outputMenu addWeek:[self parseMenu:menuData]];
        }
    }
    
    return outputMenu;
}

@end
