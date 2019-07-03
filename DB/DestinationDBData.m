//
//  DestinationDBData.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 7. 1..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "DestinationDBData.h"
#import "NetworkManager.h"

@implementation DestinationDBData

+ (NSString *) getDestinationTableName
{
    return @"desination";
}

+ (NSString *) getFavoriteTableName
{
    return @"favorite";
}

#pragma mark NSCoding

#define keySeq           @"seq"
#define keyTitle         @"title"
#define keyAddress       @"address"
#define keyRDate           @"rdate"
#define keyLat           @"lat"
#define keyLon           @"lon"

- (void) setData:(NSString*)key data:(NSObject*)data
{
    if ([key isEqualToString:keySeq]){
        _seq = (NSString*)data;
    }else if ([key isEqualToString:keyTitle]){
        _title = (NSString*)data;
    }else if ([key isEqualToString:keyAddress]){
        _address = (NSString*)data;
    }else if ([key isEqualToString:keyRDate]){
        _rdate = (NSDate *)data;
    }else if ([key isEqualToString:keyLat]){
        _lat = (NSDecimalNumber *)data;
    }else if ([key isEqualToString:keyLon]){
        _lon = (NSDecimalNumber *)data;
    }
}




- (id) initWithCoder:(NSCoder *)aDecoder
{
    if( (self = [super init]) ) {
        _seq = [aDecoder decodeObjectForKey:keySeq];
        _title = [aDecoder decodeObjectForKey:keyTitle];
        _address = [aDecoder decodeObjectForKey:keyAddress];
        _rdate = [aDecoder decodeObjectForKey:keyRDate];
        _lat = [aDecoder decodeObjectForKey:keyLat];
        _lon =[aDecoder decodeObjectForKey:keyLon];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_seq forKey:keySeq];
    [aCoder encodeObject:_title forKey:keyTitle];
    [aCoder encodeObject:_address forKey:keyAddress];
    [aCoder encodeObject:_rdate forKey:keyRDate];
    [aCoder encodeObject:_lat forKey:keyLat];
    [aCoder encodeObject:_lon forKey:keyLon];
}

- (id) copyWithZone:(NSZone *)zone
{
    DestinationDBData *copy = [[[self class] allocWithZone:zone] init];
    copy.seq = self.seq;
    copy.title = self.title;
    copy.address = self.address;
    copy.rdate = self.rdate;
    copy.lat = self.lat;
    copy.lon = self.lon;
    return copy;
}

- (CLLocationDistance) getDistanceFromHere
{
    double lat = [NetworkManager sharedInstance].myLatitude;
    double lon = [NetworkManager sharedInstance].myLongitude;
    
    CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:[_lat doubleValue] longitude:[_lon doubleValue]];
    CLLocationDistance distance = [startLocation distanceFromLocation:endLocation]; // aka double
    return distance;
}

@end
