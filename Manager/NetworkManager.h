//
//  NetworkManager.h
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 8. 31..
//  Copyright © 2017년 m4nc. All rights reserved.
//
//  * 통신 모듈

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ReachablityView.h"

@class callDriverData;
@class callHistoryData;
@class payHistoryData;
@class MemberModifyData;
@class callData;
@class callInfoData;
@class mileageHistoryData;
@class CheckUpdateData;
@class callCheckMadeData;
@class IntroData;
@class valetListData;
@class photoListData;
@class valetData;
@class valetStatusData;
@class valetCancelData;

@class responseData;

@interface NetworkManager : NSObject

typedef enum PAYMENT_TYPE {
    PAYMENT_TYPE_NONE = 0,
    PAYMENT_TYPE_CARD = 1,
    PAYMENT_TYPE_CASH = 2
} PAYMENT_TYPE;

typedef enum CALL_ORDER_TYPE {
    CALL_ORDER_TYPE_NONE = 0,
    CALL_ORDER_TYPE_NEW = 1,
    CALL_ORDER_TYPE_COMPLETE = 2,
    CALL_ORDER_TYPE_CHECK = 3
} CALL_ORDER_TYPE;

typedef enum CARD_DIRECT_ORDER_TYPE {
    CARD_DIRECT_ORDER_TYPE_NONE = 0,
    CARD_DIRECT_ORDER_TYPE_OK = 1,
    CARD_DIRECT_ORDER_TYPE_NO = 2
} CARD_DIRECT_ORDER_TYPE;

typedef enum CALL_CANCEL_ORDER_TYPE {
    CALL_CANCEL_ORDER_TYPE_NONE = 0,
    CALL_CANCEL_ORDER_TYPE_INVALIDITY = 1,
    CALL_CANCEL_ORDER_TYPE_CANCEL = 2,
    CALL_CANCEL_ORDER_TYPE_DONE = 3
} CALL_CANCEL_ORDER_TYPE;

typedef enum HISTORY_ORDER_TYPE {
    HISTORY_ORDER_TYPE_NONE = 0,
    HISTORY_ORDER_TYPE_LIST = 1,
    HISTORY_ORDER_TYPE_DELETE = 2
} HISTORY_ORDER_TYPE;

typedef enum MEMBER_JOIN_ORDER_TYPE {
    MEMBER_JOIN_ORDER_TYPE_NONE = 0,
    MEMBER_JOIN_ORDER_TYPE_ADD = 1,
    MEMBER_JOIN_ORDER_TYPE_MODIFY = 2
} MEMBER_JOIN_ORDER_TYPE;

typedef enum VALET_CANCEL_ORDER_TYPE {
    VALET_CANCEL_ORDER_TYPE_NONE = 0,
    VALET_CANCEL_ORDER_TYPE_ORDER = 1,
    VALET_CANCEL_ORDER_TYPE_CANCEL = 2,
    VALET_CANCEL_ORDER_TYPE_ARRVIED = 3,
    VALET_CANCEL_ORDER_TYPE_CHECK = 4
} VALET_CANCEL_ORDER_TYPE;


@property (nonatomic) ReachablityView *reachablityView;

@property (nonatomic) CLLocationCoordinate2D latestUserLocation;
@property (nonatomic) int latestMapID;
@property (nonatomic) int AR_PATH_TOLERANCE;

@property (nonatomic) double myLatitude;
@property (nonatomic) double myLongitude;
@property (readwrite) NSString *myAddress;
@property (readwrite) NSString *destinatiion;

@property (readwrite) NSString * _Nullable fcmToken;

@property (readwrite) NSString *responseId;
@property (readwrite) NSString *requestId;

@property (readwrite) NSString *callCenterTel;

@property (readwrite) NSString *uuid;

+ (NetworkManager *)sharedInstance;

//+ (NSString *) getMetadataVersion;
+ (NSString *) getDeviceUUID;   //디바이스아이디
+ (NSString *) getAppID;
+ (NSString *) getAppVersion;   //앱버전(check_update)
+ (NSString *) getSDKVersion;   //디바이스모델명
+ (NSString *) getAppOS;       //디바이스운영체제
+ (NSString *) getOSVersion;   //디바이스OS버전
+ (NSString *) getDeviceModel;

- (void) call:(NSString *)start_addr start:(CLLocationCoordinate2D)start target_addr:(NSString *)target_addr target:(CLLocationCoordinate2D)target relay_addr:(NSString *)relay_addr relay:(CLLocationCoordinate2D)relay value:(NSInteger)value mileage:(NSInteger)mileage meter:(NSInteger)meter paymethod:(PAYMENT_TYPE)paymethod car_type:(CAR_TYPE)car_type memo:(NSString *)memo order_type:(CALL_ORDER_TYPE)order_type complete:(void(^)(BOOL, callData*))complete;

- (void) callNew:(NSString *)start_addr start:(CLLocationCoordinate2D)start target_addr:(NSString *)target_addr target:(CLLocationCoordinate2D)target relay_addr:(NSString *)relay_addr relay:(CLLocationCoordinate2D)relay value:(NSInteger)value mileage:(NSInteger)mileage meter:(NSInteger)meter paymethod:(PAYMENT_TYPE)paymethod car_type:(CAR_TYPE)car_type memo:(NSString *)memo complete:(void(^)(BOOL, callData*))complete;


- (void) callInfo:(void(^)(BOOL, callInfoData*))complete;

- (void) cardDirect:(CARD_DIRECT_ORDER_TYPE)order_type c_name:(NSString *)c_name c_phone:(NSString *)c_phone c_card:(NSString *)c_card c_card_number:(NSString *)c_card_number c_expire_date:(NSString *)c_expire_date complete:(void(^)(BOOL, responseData*))complete;

- (void) callCancel:(CALL_CANCEL_ORDER_TYPE)order_type complete:(void(^)(BOOL, responseData*))complete;

- (void) callDriver:(void(^)(BOOL, callDriverData*))complete;

- (void) callCheckMade:(void(^)(BOOL, callCheckMadeData*))complete;

- (void) callHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs complete:(void(^)(BOOL, callHistoryData*))complete;

- (void) payHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs complete:(void(^)(BOOL, payHistoryData*))complete;


- (void) memberInfo:(void(^)(BOOL, MemberModifyData*))complete;

- (void) memberJoinValet:(NSString *)name tel:(NSString *)tel email:(NSString *)email address:(NSString *)address order_type:(MEMBER_JOIN_ORDER_TYPE)order_type fcm_token:(NSString *)fcm_token complete:(void(^)(BOOL, responseData*))complete;

- (void) memberJoin:(NSString *)name tel:(NSString *)tel email:(NSString *)email address:(NSString *)address recommander:(NSString *)recommander order_type:(MEMBER_JOIN_ORDER_TYPE)order_type fcm_token:(NSString *)fcm_token complete:(void(^)(BOOL, responseData*))complete;

- (void) agentRecommender:(NSString *)recommender_id complete:(void(^)(BOOL, responseData*))complete;

- (void) intro:(void(^)(BOOL, IntroData*))complete;

- (void) mileageHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs complete:(void(^)(BOOL, mileageHistoryData*))complete;

- (void) checkUpdate:(void(^)(BOOL, CheckUpdateData*))complete;

- (void) iOSMobileNum:(NSString *)phone_number complete:(void(^)(BOOL, responseData*))complete;


//valet
- (void) valetList:(CLLocationCoordinate2D)location request_range:(NSInteger)request_range complete:(void(^)(BOOL, valetListData*))complete;

- (void) valetCancel:(VALET_CANCEL_ORDER_TYPE)type center_idx:(NSString *)center_idx complete:(void(^)(BOOL, valetCancelData*))complete;

- (void) valetRelease:(NSString *)req_addr req_location:(CLLocationCoordinate2D)req_location req_release_time:(NSInteger)req_release_time req_memo:(NSString *)req_memo complete:(void(^)(BOOL, responseData*))complete;

- (void) valetDriverInfo:(void(^)(BOOL, valetData*))complete;
- (void) valetLastAgree:(NSString *)addr location:(CLLocationCoordinate2D)location carNum:(NSString *)carNum name:(NSString *)name yn:(NSString *)yn complete:(void(^)(BOOL))complete;

- (void) valetUserLocation:(CLLocationCoordinate2D)userLocation driverCenterLocation:(CLLocationCoordinate2D)driverCenterLocation centerId:(NSString *)centerId distance:(NSInteger)distance complete:(void(^)(BOOL, responseData*))complete;
- (void) valetStatus:(void(^)(BOOL, valetStatusData*))complete;
- (void) valetHistory:(NSString *)start_tstamp end:(NSString *)end_tstamp order_type:(HISTORY_ORDER_TYPE)order_type order_idxs:(NSString *)order_idxs complete:(void(^)(BOOL, callHistoryData*))complete;
@end
