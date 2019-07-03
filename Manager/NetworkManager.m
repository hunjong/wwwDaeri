//
//  NetworkManager.m
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 8. 31..
//  Copyright © 2017년 m4nc. All rights reserved.
//

#import "NetworkManager.h"

#import "AFNetworking.h"
#import "NavigationController.h"

#include <sys/sysctl.h>

#import "responseData.h"
#import "ReachablityView.h"
#import "TMap.h"

@interface NetworkManager ()
{
    UIActivityIndicatorView *activityIndicator;
    
    AFHTTPSessionManager *manager;
    AFHTTPSessionManager *managerForGoogleAPI;
    AFHTTPSessionManager *managerForLog;
    BOOL isCheckUpdate;
    
}

@end

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    static NetworkManager *_default = nil;
    if (_default != nil) {
        return _default;
    }
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [NetworkManager new];
    });
    return _default;
}

- (id) init
{
    if ((self = [super init])) {
        _responseId = @"";
        activityIndicator = nil;
    }
    
    return self;
}


#pragma mark - Network Module

- (void) call:(NSString *)start_addr start:(CLLocationCoordinate2D)start target_addr:(NSString *)target_addr target:(CLLocationCoordinate2D)target relay_addr:(NSString *)relay_addr relay:(CLLocationCoordinate2D)relay value:(NSInteger)value mileage:(NSInteger)mileage meter:(NSInteger)meter paymethod:(PAYMENT_TYPE)paymethod car_type:(CAR_TYPE)car_type memo:(NSString *)memo order_type:(CALL_ORDER_TYPE)order_type complete:(void(^)(BOOL, callData*))complete
{
    NSLog(@"NetworkManager call");
    /*
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:_myLatitude longitude:_myLongitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:start.latitude longitude:start.longitude];
    CLLocationDistance start_distance = [locA distanceFromLocation:locB];
    start_distance = round(start_distance);
    CLLocationDistance relay_distance;
    CLLocationDistance target_distance;
    if(![relay_addr isEqualToString:@""]){
        CLLocation *locC = [[CLLocation alloc] initWithLatitude:relay.latitude longitude:relay.longitude];
        relay_distance = [locB distanceFromLocation:locC]+start_distance;
        relay_distance = round(relay_distance);
        CLLocation *locD = [[CLLocation alloc] initWithLatitude:target.latitude longitude:target.longitude];
        target_distance = [locC distanceFromLocation:locD]+relay_distance+start_distance;
        target_distance = round(target_distance);
    }else{
        relay_distance = 0;
        CLLocation *locD = [[CLLocation alloc] initWithLatitude:target.latitude longitude:target.longitude];
        target_distance = [locB distanceFromLocation:locD]+start_distance;
        target_distance = round(target_distance);
    }
     */
    CLLocationDistance start_distance = 0;
    CLLocationDistance relay_distance = 0;
    CLLocationDistance target_distance = meter;
    
    NSDictionary *request_parameter;
    
    if(relay_addr && ![relay_addr isEqualToString:@""]){
    /* request parameter */
    request_parameter = @{@"request_id" : _requestId,
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                          @"start_addr" : [self urlEncoding:start_addr],
                                        @"start_lat" : [NSNumber numberWithDouble:start.latitude],
                                        @"start_lon" : [NSNumber numberWithDouble:start.longitude],
                                        @"start_distance" : [NSNumber numberWithDouble:start_distance],
                                        @"target_addr" : [self urlEncoding:target_addr],
                                        @"target_lat" : [NSNumber numberWithDouble:target.latitude],
                                        @"target_lon" : [NSNumber numberWithDouble:target.longitude],
                                        @"target_distance" : [NSNumber numberWithDouble:target_distance],
                                        @"relay_addr" : [self urlEncoding:relay_addr],
                                        @"relay_lat" : [NSNumber numberWithDouble:relay.latitude],
                                        @"relay_lon" : [NSNumber numberWithDouble:relay.longitude],
                                        @"relay_distance" : [NSNumber numberWithDouble:relay_distance],
                                        @"value" : [NSNumber numberWithInteger:value],
                                        @"mileage" : [NSNumber numberWithInteger:mileage],
                                        @"meter" : [NSNumber numberWithInteger:meter],
                                        @"paymethod" : [self getPayType:paymethod],
                                        @"car_type" :[self getCarType:car_type],
                                        @"order_type" : [self getCallOrder:order_type],
                                        @"response_id" : _responseId,
                                        @"memo" : [self urlEncoding:memo]
                                        };
    }else{
        /* request parameter */
    request_parameter = @{@"request_id" : _requestId,
                                            @"device_id" : _uuid,
                                            @"request_type" : REQUEST_TYPE,
                                            @"request_locale" : REQUEST_LOCALE,
                                            @"device_model" : [NetworkManager getSDKVersion],
                                            @"device_platform" : [NetworkManager getAppOS],
                                            @"device_version" : [NetworkManager getOSVersion],
                                            @"start_addr" : [self urlEncoding:start_addr],
                                            @"start_lat" : [NSNumber numberWithDouble:start.latitude],
                                            @"start_lon" : [NSNumber numberWithDouble:start.longitude],
                                            @"start_distance" : [NSNumber numberWithDouble:start_distance],
                                            @"target_addr" : [self urlEncoding:target_addr],
                                            @"target_lat" : [NSNumber numberWithDouble:target.latitude],
                                            @"target_lon" : [NSNumber numberWithDouble:target.longitude],
                                            @"target_distance" : [NSNumber numberWithDouble:target_distance],
                                            @"value" : [NSNumber numberWithInteger:value],
                                            @"mileage" : [NSNumber numberWithInteger:mileage],
                                            @"meter" : [NSNumber numberWithInteger:meter],
                                            @"paymethod" : [self getPayType:paymethod],
                                            @"car_type" :[self getCarType:car_type],
                                            @"order_type" : [self getCallOrder:order_type],
                                            @"response_id" : _responseId,
                                            @"memo" : [self urlEncoding:memo]
                                            };
    }
    
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            callData *data = [callData new];
            [data parseData:dictionaryData];
            //self.responseId = data.response_id ?: @"";
            complete(YES, data);
        }
        else
        {
            
            if(![self connected] && [self startReachablityView]){
                
                [self.reachablityView setRefreshCallback:^{
                    
                    [weakSelf call:start_addr start:start target_addr:target_addr target:target relay_addr:relay_addr relay:relay value:value mileage:mileage meter:meter paymethod:paymethod car_type:car_type memo:memo order_type:order_type complete:complete];
                }];
            }else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CALL_URL parameters:request_parameter complete:completion];
}

- (void) callNew:(NSString *)start_addr start:(CLLocationCoordinate2D)start target_addr:(NSString *)target_addr target:(CLLocationCoordinate2D)target relay_addr:(NSString *)relay_addr relay:(CLLocationCoordinate2D)relay value:(NSInteger)value mileage:(NSInteger)mileage meter:(NSInteger)meter paymethod:(PAYMENT_TYPE)paymethod car_type:(CAR_TYPE)car_type memo:(NSString *)memo complete:(void(^)(BOOL, callData*))complete
{
    NSLog(@"NetworkManager call");
    
    //NSDictionary *startInfo =[self reverseGeocode:[[TMapPoint alloc] initWithCoordinate:start]];
    //NSDictionary *tartgetInfo =[self reverseGeocode:[[TMapPoint alloc] initWithCoordinate:target]];
    //NSDictionary *relayInfo =[self reverseGeocode:[[TMapPoint alloc] initWithCoordinate:relay]];
    
    
    NSDictionary *startInfo = [[[TMapPathData alloc] init] reverseGeocoding:[[TMapPoint alloc] initWithCoordinate:start] addressType:@"A00"];
    NSDictionary *tartgetInfo = [[[TMapPathData alloc] init] reverseGeocoding:[[TMapPoint alloc] initWithCoordinate:target] addressType:@"A00"];
    
    /*
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:_myLatitude longitude:_myLongitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:start.latitude longitude:start.longitude];
    CLLocationDistance start_distance = [locA distanceFromLocation:locB];
    start_distance = round(start_distance);
    CLLocationDistance relay_distance;
    CLLocationDistance target_distance;
    if(relay_addr && ![relay_addr isEqualToString:@""]){
    CLLocation *locC = [[CLLocation alloc] initWithLatitude:relay.latitude longitude:relay.longitude];
        relay_distance = [locB distanceFromLocation:locC]+start_distance;
        relay_distance = round(relay_distance);
        CLLocation *locD = [[CLLocation alloc] initWithLatitude:target.latitude longitude:target.longitude];
        target_distance = [locC distanceFromLocation:locD]+relay_distance+start_distance;
        target_distance = round(target_distance);
    }else{
        relay_distance = 0;
        CLLocation *locD = [[CLLocation alloc] initWithLatitude:target.latitude longitude:target.longitude];
        target_distance = [locB distanceFromLocation:locD]+start_distance;
        target_distance = round(target_distance);
    }
    */
    CLLocationDistance start_distance = 0;
    CLLocationDistance relay_distance = 0;
    CLLocationDistance target_distance = meter;
    
    _requestId = [self getRequestID];
    
    
    
    NSDictionary *request_parameter;
    if(relay_addr && ![relay_addr isEqualToString:@""]){
    /* request parameter */
    request_parameter = @{@"request_id" : _requestId,
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"start_addr" : [self urlEncoding:start_addr],
                                        @"start_lat" : [NSNumber numberWithDouble:start.latitude],
                                        @"start_lon" : [NSNumber numberWithDouble:start.longitude],
                                        @"start_distance" : [NSNumber numberWithDouble:start_distance],
                                        @"target_addr" : [self urlEncoding:target_addr],
                                        @"target_lat" : [NSNumber numberWithDouble:target.latitude],
                                        @"target_lon" : [NSNumber numberWithDouble:target.longitude],
                                        @"target_distance" : [NSNumber numberWithDouble:target_distance],
                                        @"relay_addr" : [self urlEncoding:relay_addr],
                                        @"relay_lat" : [NSNumber numberWithDouble:relay.latitude],
                                        @"relay_lon" : [NSNumber numberWithDouble:relay.longitude],
                                        @"relay_distance" : [NSNumber numberWithDouble:relay_distance],
                                        @"value" : [NSNumber numberWithInteger:value],
                                        @"mileage" : [NSNumber numberWithInteger:mileage],
                                        @"meter" : [NSNumber numberWithInteger:meter],
                                        @"paymethod" : [self getPayType:paymethod],
                                        @"car_type" :[self getCarType:car_type],
                                        @"order_type" : [self getCallOrder:CALL_ORDER_TYPE_NEW],
                                        @"response_id" : @"",
                                        @"start_city_do" : [self urlEncoding:[startInfo objectForKey:@"city_do"]],
                                        @"start_gu_gun" : [self urlEncoding:[startInfo objectForKey:@"gu_gun"]],
                                        @"start_legal_dong" : [self urlEncoding:[startInfo objectForKey:@"legalDong"]],
                                        @"target_city_do" : [self urlEncoding:[tartgetInfo objectForKey:@"city_do"]],
                                        @"target_gu_gun" : [self urlEncoding:[tartgetInfo objectForKey:@"gu_gun"]],
                                        @"target_legal_dong" : [self urlEncoding:[tartgetInfo objectForKey:@"legalDong"]]
                                        };
    }else{
        request_parameter = @{@"request_id" : _requestId,
                              @"device_id" : _uuid,
                              @"request_type" : REQUEST_TYPE,
                              @"request_locale" : REQUEST_LOCALE,
                              @"device_model" : [NetworkManager getSDKVersion],
                              @"device_platform" : [NetworkManager getAppOS],
                              @"device_version" : [NetworkManager getOSVersion],
                              @"start_addr" : [self urlEncoding:start_addr],
                              @"start_lat" : [NSNumber numberWithDouble:start.latitude],
                              @"start_lon" : [NSNumber numberWithDouble:start.longitude],
                              @"start_distance" : [NSNumber numberWithDouble:start_distance],
                              @"target_addr" : [self urlEncoding:target_addr],
                              @"target_lat" : [NSNumber numberWithDouble:target.latitude],
                              @"target_lon" : [NSNumber numberWithDouble:target.longitude],
                              @"target_distance" : [NSNumber numberWithDouble:target_distance],
                              @"value" : [NSNumber numberWithInteger:value],
                              @"mileage" : [NSNumber numberWithInteger:mileage],
                              @"meter" : [NSNumber numberWithInteger:meter],
                              @"paymethod" : [self getPayType:paymethod],
                              @"car_type" :[self getCarType:car_type],
                              @"order_type" : [self getCallOrder:CALL_ORDER_TYPE_NEW],
                              @"response_id" : @"",
                              @"start_city_do" : [self urlEncoding:[startInfo objectForKey:@"city_do"]],
                              @"start_gu_gun" : [self urlEncoding:[startInfo objectForKey:@"gu_gun"]],
                              @"start_legal_dong" : [self urlEncoding:[startInfo objectForKey:@"legalDong"]],
                              @"target_city_do" : [self urlEncoding:[tartgetInfo objectForKey:@"city_do"]],
                              @"target_gu_gun" : [self urlEncoding:[tartgetInfo objectForKey:@"gu_gun"]],
                              @"target_legal_dong" : [self urlEncoding:[tartgetInfo objectForKey:@"legalDong"]]
                              };
    }
    
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            callData *data = [callData new];
            [data parseData:dictionaryData];
            self.responseId = data.response_id ?: @"";
            complete(YES, data);
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                
                [self.reachablityView setRefreshCallback:^{
                    
                    [weakSelf callNew:start_addr start:start target_addr:target_addr target:target relay_addr:relay_addr relay:relay value:value mileage:mileage meter:meter paymethod:paymethod car_type:car_type memo:memo complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CALL_URL parameters:request_parameter complete:completion];
}


- (void) callInfo:(void(^)(BOOL, callInfoData*))complete
{
    NSLog(@"NetworkManager callInfo");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            callInfoData *data = [callInfoData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf callInfo:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CALL_INFO_URL parameters:request_parameter complete:completion];
}



- (void) callCancel:(CALL_CANCEL_ORDER_TYPE)order_type complete:(void(^)(BOOL, responseData*))complete
{
    NSLog(@"NetworkManager callCancel");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId,
                                        @"order_type" : [self getCallCancelOrder:order_type]
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            self->_responseId = @"";
            
            [self stopReachablityView];
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf callCancel:order_type complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CALL_CANCEL_URL parameters:request_parameter complete:completion];
}

- (void) callDriver:(void(^)(BOOL, callDriverData*))complete
{
    NSLog(@"NetworkManager callDriver");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        //[self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            callDriverData *data = [callDriverData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf callDriver:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    //[self startIndicator];
    
    [self requestPOST:CALL_DRIVER_60SEC_URL parameters:request_parameter complete:completion];
}

- (void) callCheckMade:(void(^)(BOOL, callCheckMadeData*))complete
{
    NSLog(@"NetworkManager callCheckMade");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    __block __weak void (^weak_completion)(BOOL,NSDictionary*);
    
    weak_completion = completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            callCheckMadeData *data = [callCheckMadeData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf callCheckMade:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CALL_CHECK_MADE_URL parameters:request_parameter complete:completion];
}

- (void) callHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs  complete:(void(^)(BOOL, callHistoryData*))complete
{
    NSLog(@"NetworkManager callHistory");
    
    NSDictionary *request_parameter;
    if(order_idxs != nil){
    request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"start_tstamp" : start_tstamp,
                                        @"end_tstamp" : end_tstamp,
                                        @"order_type" : [self getHistoryOrder:order_type],
                                        @"order_idxs" : order_idxs
                                        };
    }else{
        request_parameter = @{@"request_id" : [self getRequestID],
                                            @"device_id" : _uuid,
                                            @"request_type" : REQUEST_TYPE,
                                            @"request_locale" : REQUEST_LOCALE,
                                            @"device_model" : [NetworkManager getSDKVersion],
                                            @"device_platform" : [NetworkManager getAppOS],
                                            @"device_version" : [NetworkManager getOSVersion],
                                            @"start_tstamp" : start_tstamp,
                                            @"end_tstamp" : end_tstamp,
                                            @"order_type" : [self getHistoryOrder:order_type]
                                            };
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            callHistoryData *data = [callHistoryData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf callHistory:start_tstamp end:end_tstamp order_type:order_type order_idxs:order_idxs  complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CALL_HISTORY_URL parameters:request_parameter complete:completion];
}

- (void) payHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs complete:(void(^)(BOOL, payHistoryData*))complete
{
    NSLog(@"NetworkManager payHistory");
    
    /* request parameter */
    NSDictionary *request_parameter;
    
    if(order_idxs != nil){
        request_parameter = @{@"request_id" : [self getRequestID],
                               @"device_id" : _uuid,
                               @"request_type" : REQUEST_TYPE,
                               @"request_locale" : REQUEST_LOCALE,
                               @"device_model" : [NetworkManager getSDKVersion],
                               @"device_platform" : [NetworkManager getAppOS],
                               @"device_version" : [NetworkManager getOSVersion],
                               @"start_tstamp" : start_tstamp,
                               @"end_tstamp" : end_tstamp,
                               @"order_type" : [self getHistoryOrder:order_type],
                               @"order_idxs" : order_idxs
                               };
    }else{
        request_parameter = @{@"request_id" : [self getRequestID],
                               @"device_id" : _uuid,
                               @"request_type" : REQUEST_TYPE,
                               @"request_locale" : REQUEST_LOCALE,
                               @"device_model" : [NetworkManager getSDKVersion],
                               @"device_platform" : [NetworkManager getAppOS],
                               @"device_version" : [NetworkManager getOSVersion],
                               @"start_tstamp" : start_tstamp,
                               @"end_tstamp" : end_tstamp,
                               @"order_type" : [self getHistoryOrder:order_type]
                               };
    }
    
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            payHistoryData *data = [payHistoryData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf payHistory:start_tstamp end:end_tstamp order_type:order_type order_idxs:order_idxs complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:PAY_HISTORY_URL parameters:request_parameter complete:completion];
}

- (void) memberInfo:(void(^)(BOOL, MemberModifyData*))complete
{
    NSLog(@"NetworkManager memberModify");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion]
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            MemberModifyData *data = [MemberModifyData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf memberInfo:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:MEMBER_MODIFY_URL parameters:request_parameter complete:completion];
}


- (void) memberJoin:(NSString *)name tel:(NSString *)tel email:(NSString *)email address:(NSString *)address recommander:(NSString *)recommander order_type:(MEMBER_JOIN_ORDER_TYPE)order_type fcm_token:(NSString *)fcm_token complete:(void(^)(BOOL, responseData*))complete
{
    if ([email isEqualToString:@""]) {
        email = [NSString stringWithFormat:@"%@@goodriver.co.kr",_uuid];
    }
    
    NSLog(@"NetworkManager memberJoin");
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"member_name" : [self urlEncoding:name],
                                        @"member_tel" : tel,
                                        @"member_email" : email,
                                        @"member_addr" : [self urlEncoding:address],
                                        @"member_recommander" : [self urlEncoding:recommander],
                                        @"order_type" : [self getMemberJoinOrder:order_type],
                                        @"fcm_token" : _fcmToken? _fcmToken : @""
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf memberJoin:name tel:tel email:email address:address recommander:recommander order_type:order_type fcm_token:fcm_token complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:MEMBER_JOIN_URL parameters:request_parameter complete:completion];
}

- (void) agentRecommender:(NSString *)recommender_id complete:(void(^)(BOOL, responseData*))complete
{
    NSLog(@"NetworkManager agentRecommender");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"recommender_id" : recommender_id
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf agentRecommender:recommender_id complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:AGENT_RECOMMENDER_URL parameters:request_parameter complete:completion];
}

- (void) mileageHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs  complete:(void(^)(BOOL, mileageHistoryData*))complete
{
    NSLog(@"NetworkManager mileageHistory");
    NSDictionary *request_parameter;
    /* request parameter */
    if(order_idxs != nil){
        request_parameter = @{@"request_id" : [self getRequestID],
                              @"device_id" : _uuid,
                              @"request_type" : REQUEST_TYPE,
                              @"request_locale" : REQUEST_LOCALE,
                              @"device_model" : [NetworkManager getSDKVersion],
                              @"device_platform" : [NetworkManager getAppOS],
                              @"device_version" : [NetworkManager getOSVersion],
                              @"start_tstamp" : start_tstamp,
                              @"end_tstamp" : end_tstamp,
                              @"order_type" : [self getHistoryOrder:order_type],
                              @"order_idxs" : order_idxs
                              };
    }else{
        request_parameter = @{@"request_id" : [self getRequestID],
                              @"device_id" : _uuid,
                              @"request_type" : REQUEST_TYPE,
                              @"request_locale" : REQUEST_LOCALE,
                              @"device_model" : [NetworkManager getSDKVersion],
                              @"device_platform" : [NetworkManager getAppOS],
                              @"device_version" : [NetworkManager getOSVersion],
                              @"start_tstamp" : start_tstamp,
                              @"end_tstamp" : end_tstamp,
                              @"order_type" : [self getHistoryOrder:order_type]
                              };
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            mileageHistoryData *data = [mileageHistoryData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf mileageHistory:start_tstamp end:end_tstamp order_type:order_type order_idxs:order_idxs complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:MILEAGE_URL parameters:request_parameter complete:completion
     ];
}

#pragma mark - valet

- (void) memberJoinValet:(NSString *)name tel:(NSString *)tel email:(NSString *)email address:(NSString *)address order_type:(MEMBER_JOIN_ORDER_TYPE)order_type car_number:(NSString *)car_number fcm_token:(NSString *)fcm_token complete:(void(^)(BOOL, responseData*))complete
{
    NSLog(@"NetworkManager memberJoin with Car Number");
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"member_name" : [self urlEncoding:name],
                                        @"car_number" : [self urlEncoding:car_number],
                                        @"member_tel" : tel,
                                        @"member_email" : email,
                                        @"member_addr" : [self urlEncoding:address],
                                        @"order_type" : [self getMemberJoinOrder:order_type],
                                        @"fcm_token" : _fcmToken? _fcmToken : @""
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    
                    [weakSelf memberJoinValet:name tel:tel email:email address:address order_type:order_type car_number:car_number fcm_token:fcm_token complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:MEMBER_JOIN_URL parameters:request_parameter complete:completion];
}


- (void) valetList:(CLLocationCoordinate2D)location request_range:(NSInteger)request_range complete:(void(^)(BOOL, valetListData*))complete
{
    NSLog(@"NetworkManager valetList");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"location_lat" : [NSNumber numberWithDouble:location.latitude],
                                        @"location_lon" : [NSNumber numberWithDouble:location.longitude],
                                        @"request_range" : [NSNumber numberWithInteger:request_range]
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            valetListData *data = [valetListData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetList:location request_range:request_range complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:VALET_LIST_URL parameters:request_parameter complete:completion];
    
}

- (void) valetCancel:(VALET_CANCEL_ORDER_TYPE)type center_idx:(NSString *)center_idx complete:(void(^)(BOOL, valetCancelData*))complete
{
    NSLog(@"NetworkManager valetCancel");
    NSDictionary *request_parameter;
    if(type == VALET_CANCEL_ORDER_TYPE_ORDER){
        _responseId = [self getRequestID];
        request_parameter = @{@"request_id" : [self getRequestID],
                              @"device_id" : _uuid,
                              @"request_type" : REQUEST_TYPE,
                              @"request_locale" : REQUEST_LOCALE,
                              @"device_model" : [NetworkManager getSDKVersion],
                              @"device_platform" : [NetworkManager getAppOS],
                              @"device_version" : [NetworkManager getOSVersion],
                              @"order_type" : [NSNumber numberWithInt:type],
                              @"center_idx" : center_idx
                              };
    }else{
        request_parameter = @{@"request_id" : [self getRequestID],
                              @"device_id" : _uuid,
                              @"request_type" : REQUEST_TYPE,
                              @"request_locale" : REQUEST_LOCALE,
                              @"device_model" : [NetworkManager getSDKVersion],
                              @"device_platform" : [NetworkManager getAppOS],
                              @"device_version" : [NetworkManager getOSVersion],
                              @"order_type" : [NSNumber numberWithInt:type],
                              @"center_idx" : center_idx,
                              @"response_id" : _responseId
                              };
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            valetCancelData *data = [valetCancelData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetCancel:type center_idx:center_idx complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:VALET_CANCEL_URL parameters:request_parameter complete:completion];
    
}

- (void) valetRelease:(NSString *)req_addr req_location:(CLLocationCoordinate2D)req_location req_release_time:(NSInteger)req_release_time req_memo:(NSString *)req_memo complete:(void(^)(BOOL, responseData*))complete
{
    NSLog(@"NetworkManager valetRelease");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId,
                                        @"req_addr" : [self urlEncoding:req_addr],
                                        @"req_lat" : [NSNumber numberWithDouble:req_location.latitude],
                                        @"req_lon" : [NSNumber numberWithDouble:req_location.longitude],
                                        @"req_release_time" : [NSNumber numberWithInteger:req_release_time],
                                        @"req_memo" : [self urlEncoding:req_memo]
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetRelease:req_addr req_location:req_location req_release_time:req_release_time req_memo:req_memo complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:VALET_RELEASE_URL parameters:request_parameter complete:completion];
    
}

- (void) valetDriverInfo:(void(^)(BOOL, valetData*))complete
{
    NSLog(@"NetworkManager valetDriverInfo");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId,
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            valetData *data = [valetData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetDriverInfo:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:VALET_DRIVER_INFO_URL parameters:request_parameter complete:completion];
    
}

- (void) valetLastAgree:(NSString *)addr location:(CLLocationCoordinate2D)location carNum:(NSString *)carNum name:(NSString *)name yn:(NSString *)yn complete:(void(^)(BOOL))complete
{
    NSLog(@"NetworkManager lastAgree");
    
    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy년 MM월 dd일  HH시 mm분"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString *theDate = [dateFormatter stringFromDate:date];
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId,
                                        @"la_addr" : [self urlEncoding:addr],
                                        @"la_lat" : [NSNumber numberWithDouble:location.latitude],
                                        @"la_lon" : [NSNumber numberWithDouble:location.latitude],
                                        @"car_number" : [self urlEncoding:carNum],
                                        @"la_subject" : [self urlEncoding:@"차량 인수동의"],
                                        @"la_plain_text" : [self urlEncoding:@"발렛주차를 맡긴 본인의 차량은 손상된 곳 없이 처음 상태 그대로 인계 받는 것에 동의합니다."],
                                        @"la_date" : [self urlEncoding:theDate],
                                        @"la_name" : [self urlEncoding:name],
                                        @"agree_yn" : yn,
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            complete(YES);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetLastAgree:addr location:location carNum:carNum name:name yn:yn complete:complete];
                }];
            }
            else{
                complete(NO);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:VALET_LAST_AGREE_URL parameters:request_parameter complete:completion];
}

- (void) valetUserLocation:(CLLocationCoordinate2D)userLocation driverCenterLocation:(CLLocationCoordinate2D)driverCenterLocation centerId:(NSString *)centerId distance:(NSInteger)distance complete:(void(^)(BOOL, responseData*))complete
{
    NSLog(@"NetworkManager valetUserLocation");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"response_id" : _responseId,
                                        @"user_lat" : [NSNumber numberWithDouble:userLocation.latitude],
                                        @"user_lon" : [NSNumber numberWithDouble:userLocation.longitude],
                                        @"center_lat" : [NSNumber numberWithInteger:driverCenterLocation.latitude],
                                        @"center_lon" : [NSNumber numberWithInteger:driverCenterLocation.longitude],
                                        @"center_idx" : centerId,
                                        @"distance" : [NSNumber numberWithInteger:distance]
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        //[self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetUserLocation:userLocation driverCenterLocation:driverCenterLocation centerId:centerId distance:distance complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    //[self startIndicator];
    
    [self requestPOST:VALET_USER_LOCATION_URL parameters:request_parameter complete:completion];
    
}
- (void) valetStatus:(void(^)(BOOL, valetStatusData*))complete
{
    NSLog(@"NetworkManager valetStatus");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion]
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            valetStatusData *data = [valetStatusData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetStatus:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:VALET_CHECK_STATUS_URL parameters:request_parameter complete:completion];
}
- (void) valetHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs complete:(void(^)(BOOL, callHistoryData*))complete
{
    NSLog(@"NetworkManager valetHistory");
    
    NSDictionary *request_parameter;
    if(order_idxs != nil){
        request_parameter = @{@"request_id" : [self getRequestID],
                              @"device_id" : _uuid,
                              @"request_type" : REQUEST_TYPE,
                              @"request_locale" : REQUEST_LOCALE,
                              @"device_model" : [NetworkManager getSDKVersion],
                              @"device_platform" : [NetworkManager getAppOS],
                              @"device_version" : [NetworkManager getOSVersion],
                              @"start_tstamp" : start_tstamp,
                              @"end_tstamp" : end_tstamp,
                              @"order_type" : [self getHistoryOrder:order_type],
                              @"order_idxs" : order_idxs
                              };
    }else{
        request_parameter = @{@"request_id" : [self getRequestID],
                              @"device_id" : _uuid,
                              @"request_type" : REQUEST_TYPE,
                              @"request_locale" : REQUEST_LOCALE,
                              @"device_model" : [NetworkManager getSDKVersion],
                              @"device_platform" : [NetworkManager getAppOS],
                              @"device_version" : [NetworkManager getOSVersion],
                              @"start_tstamp" : start_tstamp,
                              @"end_tstamp" : end_tstamp,
                              @"order_type" : [self getHistoryOrder:order_type]
                              };
    }
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            callHistoryData *data = [callHistoryData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf valetHistory:start_tstamp end:end_tstamp order_type:order_type order_idxs:order_idxs  complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:VALET_HISTORY_URL parameters:request_parameter complete:completion];
}

#pragma mark - common

- (void) intro:(void(^)(BOOL, IntroData*))complete
{
    NSLog(@"NetworkManager intro");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion]
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            IntroData *data = [IntroData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf intro:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:INTRO_URL parameters:request_parameter complete:completion];
}



- (void) checkUpdate:(void(^)(BOOL, CheckUpdateData*))complete
{
    NSLog(@"NetworkManager checkUpdate");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"app_version" : [NetworkManager getAppVersion],
                                        @"fcm_token" : _fcmToken? _fcmToken : @""
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            CheckUpdateData *data = [CheckUpdateData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf checkUpdate:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CHECK_UPDATE_URL parameters:request_parameter complete:completion];
}

- (void) iOSMobileNum:(NSString *)phone_number complete:(void(^)(BOOL, responseData*))complete
{
    NSLog(@"NetworkManager iOSMobileNum");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"app_version" : [NetworkManager getAppVersion],
                                        @"phone_number" : phone_number
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            [self stopReachablityView];
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf iOSMobileNum:phone_number complete:complete];
                }];
            }else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:MOBILE_CHECK_URL parameters:request_parameter complete:completion];
}

- (void) cardDirect:(CARD_DIRECT_ORDER_TYPE)order_type c_name:(NSString *)c_name c_phone:(NSString *)c_phone c_card:(NSString *)c_card c_card_number:(NSString *)c_card_number c_expire_date:(NSString *)c_expire_date complete:(void(^)(BOOL, responseData*))complete
{
    NSLog(@"NetworkManager cardDirect");
    
    /* request parameter */
    NSDictionary *request_parameter = @{@"request_id" : [self getRequestID],
                                        @"device_id" : _uuid,
                                        @"request_type" : REQUEST_TYPE,
                                        @"request_locale" : REQUEST_LOCALE,
                                        @"device_model" : [NetworkManager getSDKVersion],
                                        @"device_platform" : [NetworkManager getAppOS],
                                        @"device_version" : [NetworkManager getOSVersion],
                                        @"order_type" : [self getCardDirectOrder:order_type],
                                        @"c_name" : c_name,
                                        @"c_phone" : c_phone,
                                        @"c_card" : c_card,
                                        @"c_card_number" : c_card_number,
                                        @"c_expire_date" : c_expire_date
                                        };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL,NSDictionary*);
    
    completion = ^(BOOL success, NSDictionary *dictionaryData)
    {
        // HIDE Indicator
        [self stopIndicator];
        if (success)
        {
            responseData *data = [responseData new];
            [data parseData:dictionaryData];
            complete(YES, data);
            
        }
        else
        {
            if(![self connected] && [self startReachablityView]){
                [self.reachablityView setRefreshCallback:^{
                    [weakSelf cardDirect:order_type c_name:c_name c_phone:c_phone c_card:c_card c_card_number:c_card_number c_expire_date:c_expire_date complete:complete];
                }];
            }
            else{
                complete(NO, nil);
            }
        }
    };
    
    // SHOW Indicator
    [self startIndicator];
    
    [self requestPOST:CARD_DIRECT_URL parameters:request_parameter complete:completion];
}

#pragma mark - get type

- (NSString *) getPayType:(PAYMENT_TYPE)type
{
    switch (type) {
        case PAYMENT_TYPE_NONE:
            return @"";
            
        case PAYMENT_TYPE_CARD:
            return @"card";
            
        case PAYMENT_TYPE_CASH:
            return @"cash";
            
        default:
            break;
    }
    return @"";
}

- (NSString *) getCarType:(CAR_TYPE)type
{
    switch (type) {
        case CAR_TYPE_NONE:
            return @"";
            
        case CAR_TYPE_AUTO:
            return @"auto";
            
        case CAR_TYPE_MANUAL:
            return @"manual";
            
        default:
            break;
    }
    return @"";
}

- (NSString *) getCallOrder:(CALL_ORDER_TYPE)type
{
    switch (type) {
        case CALL_ORDER_TYPE_NONE:
            return @"";
            
        case CALL_ORDER_TYPE_NEW:
            return @"new";
            
        case CALL_ORDER_TYPE_COMPLETE:
            return @"complete";
            
        case CALL_ORDER_TYPE_CHECK:
            return @"check";
            
        default:
            break;
    }
    return @"";
}

- (NSString *) getCardDirectOrder:(CARD_DIRECT_ORDER_TYPE)type
{
    switch (type) {
        case CARD_DIRECT_ORDER_TYPE_NONE:
            return @"";
            
        case CARD_DIRECT_ORDER_TYPE_OK:
            return @"0";
            
        case CARD_DIRECT_ORDER_TYPE_NO:
            return @"1";
            
        default:
            break;
    }
    return @"";
}

- (NSString *) getHistoryOrder:(HISTORY_ORDER_TYPE)type
{
    switch (type) {
        case HISTORY_ORDER_TYPE_NONE:
            return @"";
            
        case HISTORY_ORDER_TYPE_LIST:
            return @"0";
            
        case HISTORY_ORDER_TYPE_DELETE:
            return @"1";
            
        default:
            break;
    }
    return @"";
}

- (NSString *) getCallCancelOrder:(CALL_CANCEL_ORDER_TYPE)type
{
    switch (type) {
        case CALL_CANCEL_ORDER_TYPE_NONE:
            return @"";
            
        case CALL_CANCEL_ORDER_TYPE_INVALIDITY:
            return @"invalidity";
            
        case CALL_CANCEL_ORDER_TYPE_CANCEL:
            return @"cancel";
            
        case CALL_CANCEL_ORDER_TYPE_DONE:
            return @"done";
            
        default:
            break;
    }
    return @"";
}

- (NSString *) getMemberJoinOrder:(MEMBER_JOIN_ORDER_TYPE)type
{
    switch (type) {
        case MEMBER_JOIN_ORDER_TYPE_NONE:
            return @"";
            
        case MEMBER_JOIN_ORDER_TYPE_ADD:
            return @"add";
            
        case MEMBER_JOIN_ORDER_TYPE_MODIFY:
            return @"modify";
            
        default:
            break;
    }
    return @"";
}

- (NSString *) getValetCancelOrder:(VALET_CANCEL_ORDER_TYPE)type
{
    switch (type) {
        case VALET_CANCEL_ORDER_TYPE_NONE:
            return @"";
            
        case VALET_CANCEL_ORDER_TYPE_ORDER:
            return @"order";
            
        case VALET_CANCEL_ORDER_TYPE_CANCEL:
            return @"cancel";
            
        case VALET_CANCEL_ORDER_TYPE_ARRVIED:
            return @"arrived";
        
        case VALET_CANCEL_ORDER_TYPE_CHECK:
            return @"check";
            
        default:
            break;
    }
    return @"";
}

- (NSString*) getLanguageCodeForGoogleApis
{
    NSString *languageCode = [[NSUserDefaults standardUserDefaults] objectForKey:SAVEKEY_LANGUAGE];
    
    if ([languageCode isEqualToString:LANGUAGE_CODE_KOREAN])
        return @"ko";
    else if ([languageCode isEqualToString:LANGUAGE_CODE_ENGLISH])
        return @"en";
    else if ([languageCode isEqualToString:LANGUAGE_CODE_CHINESE])
        return @"zh";
    else if ([languageCode isEqualToString:LANGUAGE_CODE_JAPANESE])
        return @"jp";

    
    return @"en";
}


#pragma mark - Acquire Data

//요청아이디
- (NSString*) getRequestID
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = interval;
    return [NSString stringWithFormat:@"%ld",(long)time];
}

//디바이스아이디
+ (NSString *) getDeviceUUID
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *) getAppID
{
    return @"com.kdss.GoodDaeri";
}


+ (NSString *) getAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

//디바이스모델명
+ (NSString *) getSDKVersion
{
    NSMutableCharacterSet *characterSet = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
    [characterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    
    
    // get only those things in characterSet from the SDK name
    
    NSString *SDKName = [[NSBundle mainBundle] infoDictionary][@"DTSDKName"];
    NSArray *components = [[SDKName componentsSeparatedByCharactersInSet:[characterSet invertedSet]] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length != 0"]];
    
    if ([components count])
    return components[0];
    
    return @"";
}

//디바이스운영체제
+ (NSString *) getAppOS
{
    return [[UIDevice currentDevice] systemName];
}

//디바이스OS버전
+ (NSString *) getOSVersion
{
    return [NSString stringWithFormat:@"%0.2f", [[[UIDevice currentDevice] systemVersion] floatValue]];
}

+ (NSString *) getDeviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *model = malloc(size);
    sysctlbyname("hw.machine", model, &size, NULL, 0);
    NSString *deviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
    free(model);
    return deviceModel;
}

#pragma mark - POST

- (void) requestPOST:(NSString*)urlPostfix parameters:(NSDictionary*)parameters complete:(void(^)(BOOL, NSDictionary*))complete
{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_API_URL, urlPostfix]];
    //NSCharacterSet *allowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    //NSURL *url = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@",SERVER_API_URL, urlPostfix] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet]];
    NSLog(@"requestPOST : %@", url);
    
    if (!manager)
    {
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        //manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingSortedKeys];
        //[manager.requestSerializer setTimeoutInterval:30];
        //manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        
        //https://stackoverflow.com/questions/39284150/code-1011-request-failed-internal-server-error-500
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    }
    
    NSData *data = [NSJSONSerialization  dataWithJSONObject:parameters options:0 error:nil];
    NSString *requestData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"parameters : %@", requestData);
    
    [manager POST:url.absoluteString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
         
         NSLog(@"done : %ld", (long)response.statusCode);
         NSLog(@"responseObject : %@", responseObject);
         if (response.statusCode == 200)
         {
             NSError* error;
             NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:kNilOptions
                                                                    error:&error];
             
             complete(YES, json);
         }
         else
         {
             complete(NO, nil);
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         NSLog(@"failed : %@", error);
         complete(NO, nil);
     }];
}

- (NSString *) urlEncoding:(NSString *)requestData
{
    
    requestData = [requestData stringByReplacingOccurrencesOfString:@" "
                                         withString:@"+"];
    //NSLog(@"공백없는 주소: %@",requestData);
    //return requestData;
    NSCharacterSet *allowedCharacterSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encoded = [requestData stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    //NSLog(@"parameters : %@", encoded);
    return encoded;
}


#pragma mark - UI Indicator

- (void) startIndicator
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([rootViewController isKindOfClass:[NavigationController class]])
    {
        NavigationController *navigationController = (NavigationController *)rootViewController;
        [navigationController startIndicator:rootViewController.presentationController.presentedViewController.view withMessage:NO];
    }
    
    
}

- (void) stopIndicator
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([rootViewController isKindOfClass:[NavigationController class]])
    {
        NavigationController *navigationController = (NavigationController *)rootViewController;
        [navigationController stopIndicator];
    }
}

- (BOOL) startReachablityView
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([rootViewController isKindOfClass:[UINavigationController class]])
    {
        UIView *fromView = rootViewController.presentationController.presentedViewController.view;
        
        if(self.reachablityView == nil){
            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ReachablityView" owner:nil options:nil];
            self.reachablityView = [subviewArray lastObject];
            
        }
        
        if (self.reachablityView.superview != nil)
            [self.reachablityView removeFromSuperview];
        
        [self.reachablityView setFrame:fromView.frame];
        [fromView addSubview:self.reachablityView];
        return YES;
    }
    return NO;
}

- (void) stopReachablityView
{
    if (self.reachablityView.superview != nil){
        [self.reachablityView removeFromSuperview];
        self.reachablityView = nil;
    }
}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

@end
