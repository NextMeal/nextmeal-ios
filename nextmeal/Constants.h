//
//  Constants.h
//  nextmeal
//
//  Created by Anson Liu on 3/9/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#ifndef Constants_h

#define kDebug NO
#define kSampleFilename1 @"sampleMenu1.json"
#define kSampleFilename2 @"sampleMenu2.json"

#define kNumberOfNextMealsShown 3
#define kMaxItemsShownNextMeal 3

#define kServerProtocol @"https"
#define kServerHost @"navy.herokuapp.com"
#define kServerMenu1Path @"/menu"
#define kServerMenu2Path @"/menu2"

#define kMenuLastUpdatedKey @"menuLastUpdated"
#define kMenuLastSavedFilename @"menuLatest"

#define kNMParseErrorDomain @"NMParseErrorDomain"

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

typedef enum {
    foreground,
    background
} RequestOriginType;

#define Constants_h


#endif /* Constants_h */
