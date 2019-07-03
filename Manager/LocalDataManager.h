//
//  LocalDataManager.h
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 5..
//  Copyright © 2017년 m4nc. All rights reserved.
//
//  * 최근 경로 검색 내역을 저장하고 가져오는 모듈

#import <Foundation/Foundation.h>

@class DestinationDBData;

@interface LocalDataManager : NSObject

+ (LocalDataManager *)sharedInstance;


// 최근 검색한 목적지
- (void) pushRecentDestData:(DestinationDBData*)data;
- (NSArray*) getRecentDestData:(int)recentCount;
- (void) removeDestData:(NSString*)seq;
- (void) removeDestDatum:(NSArray*)destDBArray;
- (void) removeAllDestData;

// 최근 즐겨찾기
- (BOOL) pushRecentFavData:(DestinationDBData*)data;
- (NSArray*) getRecentFavData:(int)recentCount;
- (NSArray*) getSearchFavData:(NSString *)text;
- (void) removeFavData:(NSString*)seq;
- (void) removeFavDatum:(NSArray*)favDBArray;
- (void) removeAllFavData;

@end
