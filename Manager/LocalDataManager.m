//
//  LocalDataManager.m
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 5..
//  Copyright © 2017년 m4nc. All rights reserved.
//

#import "LocalDataManager.h"

#import "DestinationDBData.h"

@implementation LocalDataManager

const int MAX_ROUTING_PATH_COUNT = 100;

+ (LocalDataManager *)sharedInstance
{
    static LocalDataManager *_default = nil;
    if (_default != nil) {
        return _default;
    }
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [LocalDataManager new];
    });
    return _default;
}

- (NSString*) DataFilePath:(NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

#pragma mark - destination

#define RECENT_DESTINATION_DB_HISTORY       @"RecentDestinationHistory"
#define RECENT_FAVORITE_DB_HISTORY       @"RecentFavoriteHistory"

- (void) pushRecentDestData:(DestinationDBData*)data
{
    NSDate *today = [NSDate date];
    [data setRdate:today];
    
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_DESTINATION_DB_HISTORY];
    
    if (originalArray != nil)
    {
        // 6개월 지난 데이터 체크
        for (NSInteger i = originalArray.count - 1; i >= 0; i--)
        {
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components: (NSCalendarUnitDay | NSCalendarUnitSecond)
                                                                fromDate:[[originalArray objectAtIndex:i] rdate]
                                                                  toDate:today
                                                                 options:0];
            //NSLog(@"passed seconds : %ld", [components second]);
            //NSLog(@"passed day : %ld", [components day]);
            
            // 6개월이 지났으면 삭제
            if ([components day] >= 180)
            {
                [originalArray removeObjectAtIndex:i];
            }
        }
        
        // 맨 뒤에 새로운 데이터 추가
        [originalArray addObject:data];
        
        // 최근 100개만 남김
        NSArray *recentArray = [originalArray subarrayWithRange:NSMakeRange(MAX((int)originalArray.count - MAX_ROUTING_PATH_COUNT, 0), MIN((int)originalArray.count, MAX_ROUTING_PATH_COUNT))];

        [self saveDataToFile:recentArray withPath:RECENT_DESTINATION_DB_HISTORY];
    }
    else
    {
        [self saveDataToFile:@[data] withPath:RECENT_DESTINATION_DB_HISTORY];
    }
}

- (NSArray*) getRecentDestData:(int)recentCount
{
    NSDate *today = [NSDate date];
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_DESTINATION_DB_HISTORY];
    if (originalArray == nil)
    {
        NSLog(@"No saved routing path data");
        return nil;
    }

    BOOL removedAtLeastOne = NO;
    
    // 6개월 지난 데이터 체크
    for (NSInteger i = originalArray.count - 1; i >= 0; i--)
    {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components: (NSCalendarUnitDay | NSCalendarUnitSecond)
                                                            fromDate:[[originalArray objectAtIndex:i] rdate]
                                                              toDate:today
                                                             options:0];
        //NSLog(@"passed seconds : %ld", [components second]);
        //NSLog(@"passed day : %ld", [components day]);
        
        if ([components day] >= 180)
        {
            [originalArray removeObjectAtIndex:i];
            
            removedAtLeastOne = YES;
        }
    }
    
    // 6개월이 지나서 필터링 된 내용이 있으면 결과 저장
    if (removedAtLeastOne)
        [self saveDataToFile:originalArray withPath:RECENT_DESTINATION_DB_HISTORY];
    
    // 날짜로 내림 차순 정렬
    NSArray *orderedArray = [originalArray sortedArrayUsingComparator:^NSComparisonResult(DestinationDBData *obj1, DestinationDBData *obj2)
                             {
                                 if ([[obj1 rdate] compare:[obj2 rdate]] == NSOrderedAscending)
                                     return NSOrderedDescending;
                                 else if ([[obj1 rdate] compare:[obj2 rdate]] == NSOrderedDescending)
                                     return NSOrderedAscending;
                                 
                                 return NSOrderedSame;
                             }];

    // 지정된 개수가 있으면, 최근순으로 잘라옴
    if (recentCount > 0)
        orderedArray = [orderedArray subarrayWithRange:NSMakeRange(0, MIN((int)orderedArray.count, recentCount))];
    
    return orderedArray;
}

- (void) removeDestData:(NSString*)seq
{
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_DESTINATION_DB_HISTORY];
    
    if (originalArray != nil)
    {
        for (DestinationDBData *data in originalArray)
        {
            if ([[data seq] isEqualToString:seq])
            {
                [originalArray removeObject:data];
                
                [self saveDataToFile:originalArray withPath:RECENT_DESTINATION_DB_HISTORY];
                
                return;
            }
        }
    }
}

- (void) removeDestDatum:(NSArray*)destDBArray
{
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_DESTINATION_DB_HISTORY];
    
    if (originalArray != nil)
    {
        for (NSInteger i = originalArray.count - 1; i >= 0; i--)
        {
            for (DestinationDBData *data in destDBArray)
            {
                if ([[[originalArray objectAtIndex:i] seq] isEqualToString:[data seq]])
                {
                    [originalArray removeObject:[originalArray objectAtIndex:i]];
                    
                    break;
                }
            }
        }
    }
    
    [self saveDataToFile:originalArray withPath:RECENT_DESTINATION_DB_HISTORY];
}

- (void) removeAllDestData;
{
    [self saveDataToFile:@[] withPath:RECENT_DESTINATION_DB_HISTORY];
}




#pragma - favorite

- (BOOL) pushRecentFavData:(DestinationDBData*)data
{
    BOOL isInserted;
    NSDate *today = [NSDate date];
    [data setRdate:today];
    
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_FAVORITE_DB_HISTORY];
    
    if (originalArray != nil)
    {
        // 6개월 지난 데이터 체크
        for (NSInteger i = originalArray.count - 1; i >= 0; i--)
        {
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components: (NSCalendarUnitDay | NSCalendarUnitSecond)
                                                                fromDate:[[originalArray objectAtIndex:i] rdate]
                                                                  toDate:today
                                                                 options:0];
            //NSLog(@"passed seconds : %ld", [components second]);
            //NSLog(@"passed day : %ld", [components day]);
            
            // 6개월이 지났거나, 추가하려는 DB와 ID가 같으면 삭제
            if ([components day] >= 180 || [[data seq] isEqualToString:[[originalArray objectAtIndex:i] seq]])
            {
                [originalArray removeObjectAtIndex:i];
            }
        }
        
        // 맨 뒤에 새로운 데이터 추가
        [originalArray addObject:data];
        
        // 최근 100개만 남김
        NSArray *recentArray = [originalArray subarrayWithRange:NSMakeRange(MAX((int)originalArray.count - MAX_ROUTING_PATH_COUNT, 0), MIN((int)originalArray.count, MAX_ROUTING_PATH_COUNT))];
        
        [self saveDataToFile:recentArray withPath:RECENT_FAVORITE_DB_HISTORY];
        isInserted = YES;
    }
    else
    {
        [self saveDataToFile:@[data] withPath:RECENT_FAVORITE_DB_HISTORY];
        isInserted = YES;
    }
    return isInserted;
}

- (NSArray*) getRecentFavData:(int)recentCount
{
    NSDate *today = [NSDate date];
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_FAVORITE_DB_HISTORY];
    if (originalArray == nil)
    {
        NSLog(@"No saved routing path data");
        return nil;
    }
    
    BOOL removedAtLeastOne = NO;
    
    // 6개월 지난 데이터 체크
    for (NSInteger i = originalArray.count - 1; i >= 0; i--)
    {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components: (NSCalendarUnitDay | NSCalendarUnitSecond)
                                                            fromDate:[[originalArray objectAtIndex:i] rdate]
                                                              toDate:today
                                                             options:0];
        //NSLog(@"passed seconds : %ld", [components second]);
        //NSLog(@"passed day : %ld", [components day]);
        
        if ([components day] >= 180)
        {
            [originalArray removeObjectAtIndex:i];
            
            removedAtLeastOne = YES;
        }
    }
    
    // 6개월이 지나서 필터링 된 내용이 있으면 결과 저장
    if (removedAtLeastOne)
        [self saveDataToFile:originalArray withPath:RECENT_FAVORITE_DB_HISTORY];
    
    // 날짜로 내림 차순 정렬
    NSArray *orderedArray = [originalArray sortedArrayUsingComparator:^NSComparisonResult(DestinationDBData *obj1, DestinationDBData *obj2)
                             {
                                 if ([[obj1 rdate] compare:[obj2 rdate]] == NSOrderedAscending)
                                     return NSOrderedDescending;
                                 else if ([[obj1 rdate] compare:[obj2 rdate]] == NSOrderedDescending)
                                     return NSOrderedAscending;
                                 
                                 return NSOrderedSame;
                             }];
    
    // 지정된 개수가 있으면, 최근순으로 잘라옴
    if (recentCount > 0)
        orderedArray = [orderedArray subarrayWithRange:NSMakeRange(0, MIN((int)orderedArray.count, recentCount))];
    
    return orderedArray;
}

- (NSArray*) getSearchFavData:(NSString *)text
{
    NSDate *today = [NSDate date];
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_FAVORITE_DB_HISTORY];
    if (originalArray == nil)
    {
        NSLog(@"No saved routing path data");
        return nil;
    }
    
    BOOL removedAtLeastOne = NO;
    
    // 6개월 지난 데이터 체크
    for (NSInteger i = originalArray.count - 1; i >= 0; i--)
    {
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components: (NSCalendarUnitDay | NSCalendarUnitSecond)
                                                            fromDate:[[originalArray objectAtIndex:i] rdate]
                                                              toDate:today
                                                             options:0];
        //NSLog(@"passed seconds : %ld", [components second]);
        //NSLog(@"passed day : %ld", [components day]);
        
        if ([components day] >= 180)
        {
            [originalArray removeObjectAtIndex:i];
            
            removedAtLeastOne = YES;
        }
    }
    
    // 6개월이 지나서 필터링 된 내용이 있으면 결과 저장
    if (removedAtLeastOne)
        [self saveDataToFile:originalArray withPath:RECENT_FAVORITE_DB_HISTORY];
    
    // 날짜로 내림 차순 정렬
    NSArray *orderedArray = [originalArray sortedArrayUsingComparator:^NSComparisonResult(DestinationDBData *obj1, DestinationDBData *obj2)
                             {
                                 if ([[obj1 rdate] compare:[obj2 rdate]] == NSOrderedAscending)
                                     return NSOrderedDescending;
                                 else if ([[obj1 rdate] compare:[obj2 rdate]] == NSOrderedDescending)
                                     return NSOrderedAscending;
                                 
                                 return NSOrderedSame;
                             }];
    
    NSMutableArray *searchedArray = [NSMutableArray new];
    // 지정된 개수가 있으면, 최근순으로 잘라옴
    for (int i = 0; i <[orderedArray count]; i++) {
        DestinationDBData *data =  [orderedArray objectAtIndex:i];
        if([data.title containsString:text]){
            [searchedArray addObject:data];
        }
        
    }
    
    return searchedArray;
}

- (void) removeFavData:(NSString*)seq
{
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_FAVORITE_DB_HISTORY];
    
    if (originalArray != nil)
    {
        for (DestinationDBData *data in originalArray)
        {
            if ([[data seq] isEqualToString:seq])
            {
                [originalArray removeObject:data];
                
                [self saveDataToFile:originalArray withPath:RECENT_FAVORITE_DB_HISTORY];
                
                return;
            }
        }
    }
}

- (void) removeFavDatum:(NSArray*)favDBArray
{
    NSMutableArray *originalArray = [self loadDataFromFile:RECENT_FAVORITE_DB_HISTORY];
    
    if (originalArray != nil)
    {
        for (NSInteger i = originalArray.count - 1; i >= 0; i--)
        {
            for (DestinationDBData *data in favDBArray)
            {
                if ([[(DestinationDBData *)[originalArray objectAtIndex:i] seq] isEqualToString:[data seq]])
                {
                    [originalArray removeObject:[originalArray objectAtIndex:i]];
                    
                    break;
                }
            }
        }
    }
    
    [self saveDataToFile:originalArray withPath:RECENT_FAVORITE_DB_HISTORY];
}

- (void) removeAllFavData;
{
    [self saveDataToFile:@[] withPath:RECENT_FAVORITE_DB_HISTORY];
}


# pragma - common


- (NSMutableArray*) loadDataFromFile:(NSString *)path
{
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[self DataFilePath:path]];
    if(data == nil)
        return nil;

    // NSData에 들어있는 데이터를 디코드하여 GameData 오브젝트에 넣습니다.
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *loadData = [unarchiver decodeObjectForKey:path];
    [unarchiver finishDecoding];

    return [loadData count] > 0 ? [loadData mutableCopy] : nil;
}

- (void) saveDataToFile:(NSArray*)savedata withPath:(NSString *)path
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:savedata forKey:path];
    [archiver finishEncoding];
    [data writeToFile:[self DataFilePath:path] atomically:YES];
}

@end
