//
//  requestData.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 7. 2..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "responseData.h"

@implementation responseData

- (void) parseData:(NSDictionary*)dictinary
{
    dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
     }];
}

- (NSDictionary*) getDataFormDictionary
{
    return dataDictinary;
}


+ (CAR_TYPE) getCarType:(NSString *)obj
{
    if ([obj isKindOfClass:[NSNull class]])
        return CAR_TYPE_NONE;
    else if ([obj isEqualToString:@"auto"])
        return CAR_TYPE_AUTO;
    else if ([obj isEqualToString:@"manual"])
        return CAR_TYPE_MANUAL;
    
    return CAR_TYPE_NONE;
}

+ (CALL_STATUS) getCallStatus:(NSString *)obj
{
    if ([obj isKindOfClass:[NSNull class]])
        return CALL_STATUS_NONE;
    else if ([obj isEqualToString:@"accept"])
        return CALL_STATUS_ACCEPT;
    else if ([obj isEqualToString:@"cancel"])
        return CALL_STATUS_CANCEL;
    else if ([obj isEqualToString:@"waiting"])
        return CALL_STATUS_WAITING;
    else if ([obj isEqualToString:@"connected"])
        return CALL_STATUS_CONNECTED;
    else if ([obj isEqualToString:@"done"])
        return CALL_STATUS_DONE;
    else if ([obj isEqualToString:@"valet"])
        return CALL_STATUS_VALET;
    else if ([obj isEqualToString:@"status"])
        return CALL_STATUS_VALET_STATUS;
    else if ([obj isEqualToString:@"parked"])
        return CALL_STATUS_VALET_PARKED;
    else if ([obj isEqualToString:@"ready"])
        return CALL_STATUS_VALET_READY;
    else if ([obj isEqualToString:@"arrived"])
        return CALL_STATUS_VALET_ARRIVED;
    else if ([obj isEqualToString:@"paynow"])
        return CALL_STATUS_VALET_PAYNOW;
    else if ([obj isEqualToString:@"already"])
        return CALL_STATUS_VALET_ALREADY;
    else if ([obj isEqualToString:@"chauffeur"])
        return CALL_STATUS_VALET_CHAUFFEUR;
    else if ([obj isEqualToString:@"alert"])
        return CALL_STATUS_VALET_ALERT;
    return CALL_STATUS_NONE;
}

+ (PAY_METHOD) getPayMethodType:(NSString *)obj
{
    if ([obj isKindOfClass:[NSNull class]])
        return NONE_CARD;
    else if ([obj isEqualToString:@"DC"])
        return DIRECT_CARD;
    else if ([obj isEqualToString:@"AC"])
        return AGENCY_CARD;
    else if ([obj isEqualToString:@"CC"])
        return CASH_CARD;
    
    return NONE_CARD;
}

//사용 하는지 모름
+ (VALET_STATUS) getValetStatus:(NSString *)obj
{
    if ([obj isKindOfClass:[NSNull class]])
        return VALET_STATUS_NONE;
    else if ([obj isEqualToString:@""])
        return VALET_STATUS_PAY;
    else if ([obj isEqualToString:@""])
        return VALET_STATUS_PARKING;
    else if ([obj isEqualToString:@""])
        return VALET_STATUS_RELEASE;
    
    return VALET_STATUS_NONE;
}

@end


@implementation callData

- (void) parseData:(NSDictionary*)dictinary
{
     self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"response_id"])
             self.response_id = obj;
         else if ([key isEqualToString:@"driver_charge"])
             self.driver_charge = [obj integerValue];
         else if ([key isEqualToString:@"member_mileage"])
             self.member_mileage = [obj integerValue];
         else if ([key isEqualToString:@"max_use_mileage"])
             self.max_use_mileage = [obj integerValue];
     }];
}

@end

@implementation callInfoData

- (void) parseData:(NSDictionary*)dictinary
{
     self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"response_id"])
             self.response_id = obj;
         else if ([key isEqualToString:@"start_addr"])
             self.start_addr = obj;
         else if ([key isEqualToString:@"start_lat"])
             self.start_lat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"start_lon"])
             self.start_lon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"target_addr"])
             self.start_addr = obj;
         else if ([key isEqualToString:@"target_lat"])
             self.start_lat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"target_lon"])
             self.start_lon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"relay_addr"])
             self.start_addr = obj;
         else if ([key isEqualToString:@"relay_lat"])
             self.start_lat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"relay_lon"])
             self.start_lon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"value"])
             self.value = [obj intValue];
         else if ([key isEqualToString:@"mileage"])
             self.mileage = [obj intValue];
         else if ([key isEqualToString:@"meter"])
             self.meter = [obj intValue];
         else if ([key isEqualToString:@"paymethod"])
             self.paymethod = [responseData getPayMethodType:obj];
         else if ([key isEqualToString:@"car_type"])
             self.car_type = [responseData getCarType:obj];
         else if ([key isEqualToString:@"memo"])
             self.memo = obj;
     }];
}


@end


@implementation callDriverData

- (void) parseData:(NSDictionary*)dictinary
{
     self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"driver_lat"])
             self.driver_lat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"driver_lon"])
             self.driver_lon = (NSDecimalNumber*)obj;
     }];
}

@end

@implementation callCheckMadeData

- (void) parseData:(NSDictionary*)dictinary
{
     self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"driver_name"])
             self.driver_name = obj;
         else if ([key isEqualToString:@"driver_join_date"])
             self.driver_join_date = obj;
         else if ([key isEqualToString:@"driver_insurance"])
             self.driver_insurance = obj;
         else if ([key isEqualToString:@"driver_photo_url"])
             self.driver_photo_url = obj;
         else if ([key isEqualToString:@"stitle"])
             self.stitle = obj;
         else if ([key isEqualToString:@"saddr"])
             self.saddr = obj;
         else if ([key isEqualToString:@"slat"])
             self.slat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"slon"])
             self.slon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"dtitle"])
             self.dtitle = obj;
         else if ([key isEqualToString:@"daddr"])
             self.daddr = obj;
         else if ([key isEqualToString:@"dlat"])
             self.dlat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"dlon"])
             self.dlon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"rtitle"])
             self.rtitle = obj;
         else if ([key isEqualToString:@"raddr"])
             self.raddr = obj;
         else if ([key isEqualToString:@"rlat"])
             self.rlat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"rlon"])
             self.rlon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"driver_lat"])
             self.driver_lat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"driver_lon"])
             self.driver_lon = (NSDecimalNumber*)obj;
     }];
}

@end

@implementation callHistoryData

- (void) parseData:(NSDictionary*)dictinary
{
     self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"list"])
         {
             NSArray *array = [dictinary objectForKey:key];
             
             if(![array isKindOfClass:[NSNull class]]){
                 
                 self.usageList = [NSMutableArray array];
                 
                 for (NSDictionary *dic in array)
                 {
                     usageData *data = [usageData new];
                     [data parseData:dic];
                     [self.usageList addObject:data];
                 }
             }
         }
     }];
}

@end

@implementation payHistoryData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"list"])
         {
             NSArray *array = [dictinary objectForKey:key];
             
             if(![array isKindOfClass:[NSNull class]]){
                 
                 self.paymentList = [NSMutableArray array];
                 
                 for (NSDictionary *dic in array)
                 {
                     paymentData *data = [paymentData new];
                     [data parseData:dic];
                     [self.paymentList addObject:data];
                 }
             }
         }
     }];
}

@end


@implementation mileageHistoryData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"list"])
         {
             NSArray *array = [dictinary objectForKey:key];
             
             if(![array isKindOfClass:[NSNull class]]){
                 
                 self.mileageList = [NSMutableArray array];
                 
                 for (NSDictionary *dic in array)
                 {
                     mileageData *data = [mileageData new];
                     [data parseData:dic];
                     [self.mileageList addObject:data];
                 }
             }
         }
     }];
}

@end


@implementation usageData

- (void) parseData:(NSDictionary*)dataDictionary
{
    [dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"start_addr"])
             self.start_addr = obj;
         else if ([key isEqualToString:@"target_addr"])
             self.target_addr = obj;
         else if ([key isEqualToString:@"target_lat"])
             self.target_lat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"target_lon"])
             self.target_lon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"order_value"])
             self.order_value = [obj integerValue];
         else if ([key isEqualToString:@"datetime"])
             self.datetime = obj;
         else if ([key isEqualToString:@"parking_value"])
             self.parkingValue = [obj integerValue];
     }];
}

@end

@implementation paymentData

- (void) parseData:(NSDictionary*)dataDictionary
{
    [dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"datetime"])
             self.datetime = obj;
         else if ([key isEqualToString:@"summary"])
             self.summary = obj;
         else if ([key isEqualToString:@"paymethod"])
             self.paymethod = [responseData getPayMethodType:obj];
         else if ([key isEqualToString:@"value"])
             self.value = [obj integerValue];
     }];
}

@end


@implementation mileageData

- (void) parseData:(NSDictionary*)dataDictionary
{
    [dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"datetime"])
             self.idx = [obj integerValue];
         else if ([key isEqualToString:@"summary"])
             self.m_list_day = obj;
         else if ([key isEqualToString:@"paymethod"])
             self.m_list_title = obj;
         else if ([key isEqualToString:@"value"])
             self.m_list_value = [obj integerValue];
     }];
}

@end


@implementation MemberModifyData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"member_name"])
             self.member_name = obj;
         else if ([key isEqualToString:@"car_number"])
             self.member_car_number = obj;
         else if ([key isEqualToString:@"member_tel"])
             self.member_tel = obj;
         else if ([key isEqualToString:@"member_email"])
             self.member_email = obj;
         else if ([key isEqualToString:@"member_addr"])
             self.member_addr = obj;
         
     }];
}

@end

@implementation IntroData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"ad_id"])
             self.ad_id = obj;
         else if ([key isEqualToString:@"ad_image_url"])
             self.ad_image_url = obj;
         else if ([key isEqualToString:@"ad_url"])
             self.ad_url = obj;
     }];
}

@end

@implementation CheckUpdateData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"recommender_yn"])
             self.recommender_yn = obj;
         else if ([key isEqualToString:@"member_yn"])
             self.member_yn = obj;
         else if ([key isEqualToString:@"update_yn"])
             self.update_yn = obj;
         else if ([key isEqualToString:@"call_status"])
             self.call_status = [responseData getCallStatus:obj];
         else if ([key isEqualToString:@"response_id"])
             self.response_id = obj;
         else if ([key isEqualToString:@"callcenter_tel"])
             self.callcenterTel = obj;
     }];
}

@end


@implementation valetListData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"list"])
         {
             NSArray *array = [dictinary objectForKey:key];
             
             if(![array isKindOfClass:[NSNull class]]){
                 
                 self.valetList = [NSMutableArray array];
                 
                 for (NSDictionary *dic in array)
                 {
                     valetData *data = [valetData new];
                     [data parseData:dic];
                     [self.valetList addObject:data];
                 }
             }
         }
     }];
}

@end


@implementation valetData

- (void) parseData:(NSDictionary*)dataDictionary
{
    [dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"valet_center"])
             self.valet_center = obj;
         else if ([key isEqualToString:@"valet_tel"])
             self.valet_tel = obj;
         else if ([key isEqualToString:@"valet_value"])
             self.valet_value = [obj integerValue];
         else if ([key isEqualToString:@"valet_insurance"])
             self.valet_insurance = obj;
         else if ([key isEqualToString:@"valet_addr"])
             self.valet_addr = obj;
         else if ([key isEqualToString:@"valet_lat"])
             self.valet_lat = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"valet_lon"])
             self.valet_lon = (NSDecimalNumber*)obj;
         else if ([key isEqualToString:@"response_id"])
             self.response_id = obj;
         else if ([key isEqualToString:@"valet_parking_times"])
             self.response_id = obj;
         else if ([key isEqualToString:@"driver_tel"])
             self.driverTel = obj;
         else if ([key isEqualToString:@"valet_color"])
             self.valetColor = obj;
         else if ([key isEqualToString:@"valet_name"])
             self.valetName = obj;
         else if ([key isEqualToString:@"valet_photo_url"])
             self.valetPhotoUrl = obj;
     }];
}

@end

@implementation photoListData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"message"])
             self.message = obj;
         else if ([key isEqualToString:@"list"])
         {
             NSArray *array = [dictinary objectForKey:key];
             
             if(![array isKindOfClass:[NSNull class]]){
                 
                 self.photoList = [NSMutableArray array];
                 
                 for (NSDictionary *dic in array)
                 {
                     photoData *data = [photoData new];
                     [data parseData:dic];
                     [self.photoList addObject:data];
                 }
             }
         }
     }];
}

@end

@implementation photoData

- (void) parseData:(NSDictionary*)dataDictionary
{
    [dataDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"photo_idx"])
             self.photo_idx = obj;
         else if ([key isEqualToString:@"photo_name"])
             self.photo_name = obj;
         else if ([key isEqualToString:@"photo_url"])
             self.photo_url = obj;
     }];
}

@end

@implementation valetCancelData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
     }];
}

@end

@implementation valetStatusData

- (void) parseData:(NSDictionary*)dictinary
{
    self->dataDictinary = dictinary;
    [dictinary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([key isEqualToString:@"request_id"])
             self.request_id = obj;
         else if ([key isEqualToString:@"response_yn"])
             self.response_yn = obj;
         else if ([key isEqualToString:@"response_id"])
             self.response_id = obj;
         else if ([key isEqualToString:@"valet_status"])
             self.valet_status = (VALET_STATUS)obj; //확실히 모름
         else if ([key isEqualToString:@"parking_cost"])
             self.parking_cost = [obj integerValue];
         else if ([key isEqualToString:@"valet_center_idx"])
             self.valetCenterIdx = obj;
         else if ([key isEqualToString:@"valet_driver_idx"])
             self.valetDriverIdx = obj;
         
     }];
}

@end

