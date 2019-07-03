//
//  requestData.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 7. 2..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum PAY_METHOD {
    NONE_CARD = 0x00,
    DIRECT_CARD = 0x01,   //DC
    AGENCY_CARD = 0x02,     //AC
    CASH_CARD = 0x03        //CC
} PAY_METHOD;

typedef enum CALL_STATUS {
    CALL_STATUS_NONE = 0x00,
    CALL_STATUS_ACCEPT = 0x01,
    CALL_STATUS_CANCEL = 0x02,
    CALL_STATUS_WAITING = 0x03,
    CALL_STATUS_CONNECTED = 0x04,
    CALL_STATUS_DONE = 0x05,
    CALL_STATUS_VALET = 0x06,
    CALL_STATUS_VALET_STATUS = 0x07,
    CALL_STATUS_VALET_PARKED = 0x08,
    CALL_STATUS_VALET_READY = 0x09,
    CALL_STATUS_VALET_ARRIVED = 0x0a,
    CALL_STATUS_VALET_PAYNOW = 0x0b,
    CALL_STATUS_VALET_ALREADY = 0x0c,
    CALL_STATUS_VALET_CHAUFFEUR = 0x0d,
    CALL_STATUS_VALET_ALERT = 0x0e,
} CALL_STATUS;

typedef enum PHOTO_ORDER_TYPE {
    PHOTO_ORDER_TYPE_NONE = 0x00,
    PHOTO_ORDER_TYPE_PARKING = 0x01,
    PHOTO_ORDER_TYPE_RELEASE = 0x02,
} PHOTO_ORDER_TYPE;

typedef enum VALET_STATUS {
    VALET_STATUS_NONE = 0x00,
    VALET_STATUS_PARKING = 0x01,
    VALET_STATUS_DELIVERY = 0x02,
    VALET_STATUS_PAY = 0x03,
    VALET_STATUS_RELEASE = 0x04,
} VALET_STATUS;

@interface responseData : NSObject
{
    NSDictionary *dataDictinary;
}

@property (readwrite) NSString *request_id;
@property (readwrite) NSString *response_yn;
@property (readwrite) NSString *message;

- (void) parseData:(NSDictionary*)dictionary;
- (NSDictionary*) getDataFormDictionary;

@end

@interface callData : responseData

@property (readwrite) NSString *response_id;
@property (readwrite) NSInteger driver_charge;
@property (readwrite) NSInteger member_mileage;
@property (readwrite) NSInteger max_use_mileage;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface callInfoData : responseData

@property (readwrite) NSString *response_id;
@property (readwrite) NSString *start_addr;
@property (readwrite) NSDecimalNumber *start_lat;
@property (readwrite) NSDecimalNumber *start_lon;
@property (readwrite) NSString *target_addr;
@property (readwrite) NSDecimalNumber *target_lat;
@property (readwrite) NSDecimalNumber *target_lon;
@property (readwrite) NSString *relay_addr;
@property (readwrite) NSDecimalNumber *relay_lat;
@property (readwrite) NSDecimalNumber *relay_lon;
@property (readwrite) NSInteger value;
@property (readwrite) NSInteger mileage;
@property (readwrite) NSInteger meter;
@property (readwrite) PAY_METHOD paymethod;
@property (readwrite) CAR_TYPE car_type;
@property (readwrite) NSString *memo;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface callDriverData : responseData

@property (readwrite) NSString *response_id;
@property (readwrite) NSDecimalNumber *driver_lat;
@property (readwrite) NSDecimalNumber *driver_lon;

@end

@interface callCheckMadeData : responseData

@property (readwrite) NSString *driver_name;
@property (readwrite) NSString *driver_join_date;
@property (readwrite) NSString *driver_insurance;
@property (readwrite) NSString *driver_photo_url;
@property (readwrite) NSString *stitle;
@property (readwrite) NSString *saddr;
@property (readwrite) NSDecimalNumber *slat;
@property (readwrite) NSDecimalNumber *slon;
@property (readwrite) NSString *dtitle;
@property (readwrite) NSString *daddr;
@property (readwrite) NSDecimalNumber *dlat;
@property (readwrite) NSDecimalNumber *dlon;
@property (readwrite) NSString *rtitle;
@property (readwrite) NSString *raddr;
@property (readwrite) NSDecimalNumber *rlat;
@property (readwrite) NSDecimalNumber *rlon;
@property (readwrite) NSDecimalNumber *driver_lat;
@property (readwrite) NSDecimalNumber *driver_lon;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface callHistoryData : responseData
//usageData
@property (readwrite) NSMutableArray *usageList;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface payHistoryData : responseData
//paymentData
@property (readwrite) NSMutableArray *paymentList;

@end

@interface mileageHistoryData : responseData
//mileageData
@property (readwrite) NSMutableArray *mileageList;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface usageData : NSObject

@property (readwrite) NSString *start_addr;
@property (readwrite) NSString *target_addr;
@property (readwrite) NSDecimalNumber *target_lat;
@property (readwrite) NSDecimalNumber *target_lon;
@property (readwrite) NSInteger order_value;
@property (readwrite) NSString *datetime;
@property (readwrite) NSInteger parkingValue; //valet

- (void) parseData:(NSDictionary*)dictinary;

@end

@interface paymentData : NSObject

@property (readwrite) NSString *datetime;
@property (readwrite) NSString *summary;
@property (readwrite) PAY_METHOD paymethod;
@property (readwrite) NSInteger value;

- (void) parseData:(NSDictionary*)dictinary;

@end

@interface mileageData : NSObject

@property (readwrite) NSInteger idx;
@property (readwrite) NSString *m_list_day;
@property (readwrite) NSString *m_list_title;
@property (readwrite) NSInteger m_list_value;

- (void) parseData:(NSDictionary*)dictinary;

@end

@interface MemberModifyData : responseData

@property (readwrite) NSString *member_name;
@property (readwrite) NSString *member_tel;
@property (readwrite) NSString *member_email;
@property (readwrite) NSString *member_addr;
@property (readwrite) NSString *member_car_number; //valet

- (void) parseData:(NSDictionary*)dictionary;

@end

@interface IntroData : responseData

@property (readwrite) NSString *ad_id;
@property (readwrite) NSString *ad_image_url;
@property (readwrite) NSString *ad_url;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface CheckUpdateData : responseData

@property (readwrite) NSString *recommender_yn;
@property (readwrite) NSString *member_yn;
@property (readwrite) NSString *update_yn;
@property (readwrite) CALL_STATUS call_status;
@property (readwrite) NSString *response_id;
@property (readwrite) NSString *callcenterTel;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface valetListData : responseData
//valetData
@property (readwrite) NSMutableArray *valetList;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface valetData : NSObject

@property (readwrite) NSString *valet_center;
@property (readwrite) NSString *valet_tel;
@property (readwrite) NSInteger valet_value;
@property (readwrite) NSString *valet_insurance;
@property (readwrite) NSString *valet_addr;
@property (readwrite) NSDecimalNumber *valet_lat;
@property (readwrite) NSDecimalNumber *valet_lon;
@property (readwrite) NSString *response_id;
@property (readwrite) NSString *valet_parking_times;
@property (readwrite) NSString *driverTel;
@property (readwrite) NSString *valetColor;
@property (readwrite) NSString *valetName;
@property (readwrite) NSString *valetPhotoUrl;

- (void) parseData:(NSDictionary*)dictinary;

@end

@interface photoListData : responseData
//photoData
@property (readwrite) NSMutableArray *photoList;
- (void) parseData:(NSDictionary*)dictionary;

@end

@interface photoData : NSObject

@property (readwrite) NSString *photo_idx;
@property (readwrite) NSString *photo_name;
@property (readwrite) NSString *photo_url;

- (void) parseData:(NSDictionary*)dictinary;

@end

@interface valetCancelData : responseData

@property (readwrite) NSString *response_id;

- (void) parseData:(NSDictionary*)dictionary;

@end

@interface valetStatusData : responseData

@property (readwrite) NSString *response_id;
@property (readwrite) VALET_STATUS valet_status;
@property (readwrite) NSInteger parking_cost;
@property (readwrite) NSString *valetCenterIdx;
@property (readwrite) NSString *valetDriverIdx;

- (void) parseData:(NSDictionary*)dictionary;

@end
