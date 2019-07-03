//
//  DestinationDBData.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 7. 1..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DestinationDBData : NSObject <NSCoding, NSCopying>


@property (readwrite) NSString *seq;

@property (readwrite) NSString *title;
@property (readwrite) NSString *address;

@property (readwrite) NSDate *rdate;

@property (readwrite) NSDecimalNumber *lat;
@property (readwrite) NSDecimalNumber *lon;

+ (NSString*) getDestinationTableName;
+ (NSString *) getFavoriteTableName;

- (void) setData:(NSString*)key data:(NSObject*)data;

- (CLLocationDistance) getDistanceFromHere;

@end
