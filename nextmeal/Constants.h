//
//  Constants.h
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#ifndef Constants_h

#pragma mark - Debug constants

#define kDebug NO
#define kSampleFilename1 @"sampleMenu1.json"
#define kSampleFilename2 @"sampleMenu2.json"


#pragma mark - Menu display configurable options

#define kNumberOfNextMealsShown 3
#define kMaxItemsShownNextMeal 3

#define kNumberOfNextMealsShownWidget 1
#define kMaxItemsShownNextMealWidget 3


#pragma mark - Saved keys and filenames

#define kMenuLastUpdatedKey @"menuLastUpdated"
#define kMenuLastSavedFilename @"menuLatest"


#pragma mark - Connectivity constants

#define kServerProtocol @"https"
#define kServerHost @"navy.herokuapp.com"
#define kServerMenu1Path @"/menu"
#define kServerMenu2Path @"/menu2"

#define kNMParseErrorDomain @"NMParseErrorDomain"
#define kNMRetrieveSavedErrorDomain @"NMRetrieveSavedErrorDomain"

#define kNMServiceType @"NMMultipeerMenu"
#define kNMDiscoveryInfoMenuUpdateDate @"menuUpdateDate"


#pragma mark - Menu JSON key constants

#define kSundayKey @"U"
#define kMondayKey @"M"
#define kTuesdayKey @"T"
#define kWednesdayKey @"W"
#define kThursdayKey @"R"
#define kFridayKey @"F"
#define kSaturdayKey @"S"

#define kBreakfastKey @"B"
#define kLunchKey @"L"
#define kDinnerKey @"D"

#define kMealItemTitleKey @"title"

#define kMorningMealTitle @"Breakfast"
#define kNoonMealTitle @"Lunch"
#define kEveningMealTitle @"Dinner"


#pragma mark - Type definitions

typedef enum {
    NMForeground,
    NMBackground
} NMRequestOriginType;

#define Constants_h


#endif /* Constants_h */
