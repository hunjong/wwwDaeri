//
//  Header.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 5. 18..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#ifndef Header_h
#define Header_h

static NSString *TMAP_APPKEY_TEST = @"4d3cdf9d-a556-483e-a046-eac292fc2304";
static NSString *TMAP_APPKEY = @"794c8eca-1976-4573-b3db-271796d24eb7";

static NSString *SAVEKEY_POPUP = @"popup";
static NSString *SAVEKEY_POPUP_URL = @"popupURL";
static NSString *SAVEKEY_APP_VER = @"appVersion";
static NSString *SAVEKEY_ALARM = @"alarm";
static NSString *SAVEKEY_PHONE_NUMBER = @"number";
static NSString *SAVEKEY_SMS = @"sms";
static NSString *SAVEKEY_LANGUAGE = @"Language";
static NSString *SAVEKEY_AGREEMENT = @"Agreement";
static NSString *SAVEKEY_RECOMMEND = @"Recommend";
static NSString *SAVEKEY_MEMBERJOIN = @"MemberJoin";
static NSString *SAVEKEY_MY_LAT = @"MyLat";
static NSString *SAVEKEY_MY_LON = @"MyLon";
static NSString *SAVEKEY_CARD_NUMBER1 = @"cardNum1";
static NSString *SAVEKEY_CARD_NUMBER2 = @"cardNum2";
static NSString *SAVEKEY_CARD_NUMBER3 = @"cardNum3";
static NSString *SAVEKEY_CARD_NUMBER4 = @"cardNum4";
static NSString *SAVEKEY_CARD_MONTH = @"cardMonth";
static NSString *SAVEKEY_CARD_YEAR = @"cardYear";
static NSString *SAVEKEY_PREFER_CARD = @"preferCard";
static NSString *SAVEKEY_PREFER_MANUAL = @"preferManual";
static NSString *SAVEKEY_USAGE_SEARCH_MONTH = @"usageMonth";
static NSString *SAVEKEY_MILEAGE_SEARCH_MONTH = @"mileageMonth";
static NSString *SAVEKEY_PAY_SEARCH_MONTH = @"payMonth";
static NSString *SAVEKEY_CAR_NUMBER = @"carNumber";
static NSString *SAVEKEY_DESTINATION_NAME = @"destination";

static NSString *LANGUAGE_CODE_KOREAN = @"ko";
static NSString *LANGUAGE_CODE_ENGLISH = @"en";
static NSString *LANGUAGE_CODE_CHINESE = @"zh";
static NSString *LANGUAGE_CODE_JAPANESE = @"jp";

static NSString *SERVER_URL = @"https://goodriver.co.kr/COM1026/_admin";
static NSString *TERMS_USE = @"terms_of_use.txt";
static NSString *TERMS_PRIVACY = @"privacy_policy.txt";
static NSString *TERMS_GPS = @"gps_agreement.txt";

#define TERMS_USE_URL [NSString stringWithFormat:@"%@/%@",SERVER_URL,TERMS_USE]
#define TERMS_PRIVACY_URL [NSString stringWithFormat:@"%@/%@",SERVER_URL,TERMS_PRIVACY]
#define TERMS_GPS_URL [NSString stringWithFormat:@"%@/%@",SERVER_URL,TERMS_GPS]
#define SERVER_API_URL [NSString stringWithFormat:@"%@/_API/%@",SERVER_URL,REQUEST_TYPE]

//대리고객
#define CALL_URL                                @"/call.asp"
#define CALL_INFO_URL                           @"/call_info.asp"
#define CARD_DIRECT_URL                         @"/card_direct.asp"
#define CALL_CANCEL_URL                         @"/call_cancel.asp"
#define CALL_DRIVER_60SEC_URL                   @"/call_driver.asp"
#define CALL_CHECK_MADE_URL                     @"/call_check_made.asp"
#define CALL_HISTORY_URL                        @"/call_history.asp"
#define PAY_HISTORY_URL                         @"/pay_history.asp"
#define MEMBER_MODIFY_URL                       @"/member_modify.asp"
#define MEMBER_JOIN_URL                         @"/member_join.asp"

//대리기사 (사용안함)
#define REQUEST_LIST_URL                        @"/request_list.asp"
#define REQUEST_ORDER_CANCEL_URL                @"/request_cancel.asp"
#define CHARGE_HISTORY_URL                      @"/charge_history.asp"
#define BAECHA_HISTORY_URL                      @"/baecha_history.asp"

//공통사항
#define ERROR_URL                               @"/error.asp"
#define BBS_URL                                 @"/bbs.asp"
#define AGENT_RECOMMENDER_URL                   @"/agent_recommender.asp"
#define INTRO_URL                               @"/intro.asp"
#define MILEAGE_URL                             @"/mileage.asp"
#define CHECK_UPDATE_URL                        @"/check_update.asp"
#define MOBILE_CHECK_URL                        @"/ios_mobile_no.asp"

//발렛
#define VALET_LIST_URL                          @"/request_valet_list.asp"
#define VALET_CANCEL_URL                        @"/valet_cancel.asp"
#define VALET_RELEASE_URL                       @"/request_valet_release.asp"
#define VALET_DRIVER_INFO_URL                   @"/valet_driver_info.asp"
#define VALET_LAST_AGREE_URL                   @"/last_agree.asp"

#define VALET_PHOTO_LIST_URL                   @"/photo_list.asp"
#define VALET_HISTORY_URL                   @"/valet_history.asp"
#define VALET_USER_LOCATION_URL                   @"/user_location.asp"
#define VALET_CHECK_STATUS_URL                   @"/check_valet_status.asp"
//대리호출
//카드결제요청
//대리호출취소요청
//이용내역
//결제내역
//내정보요청
//오류신고
//공지사항
//마일리지내역

#define ChauffeurService_url                    @"/ChauffeurService"

//웹 컨텐츠
#define WEB_CONTENTS_URL @"https://goodriver.co.kr/com1026/%@/_content/%@.asp?vipptsid=%@&latitude=%f&longitude=%f&request_type=%@&request_locale=%@&tel=%@"
//조합소개
#define url_webcontent_intro    @"about"
//공지사항
#define url_webcontent_notice   @"notice"
//Contact-us
#define url_webcontent_contactus    @"contact"
//오류신고
#define url_webcontent_error_report @"error"
//충전내역
#define url_webcontent_account_list @"accountlist"
//현금영수증
#define url_webcontent_cash_receipt @"cash_receipt"

//이용내역
#define url_webcontent_call_history @"call_history"
//마일리지내역
#define url_webcontent_mileage @"mileage"

#define copyright @"Copyright 2018 SmartAppCrop All Rights Reserved"

#define DEFAULT_START_MONTH 6
#define koreaMoney @"원"
#define basicDateFormat @"yyyy년 MM월 dd일"
#define mileageUsePerCall 1
#define vipptsid @"aaa"

#define driverFindMeter 20

typedef enum CAR_TYPE {
    CAR_TYPE_NONE = 0,
    CAR_TYPE_AUTO = 1,
    CAR_TYPE_MANUAL = 2
} CAR_TYPE;

typedef void (^SimpleCallback)(void);

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef enum WEB_CONTENTS_TYPE
{
    WEB_CONTENTS_UNION = 0, //조합소개
    WEB_CONTENTS_NOTICE,     //공지사항
    WEB_CONTENTS_CONTACT,     //Contact
    WEB_CONTENTS_BUG,      //오류신고
    WEB_CONTENTS_CHARGE,      //충전내역
    WEB_CONTENTS_CASH_RECEIPT,      //현금영수증
    WEB_CONTENTS_HISTORY_LIST,      //이용내역
    WEB_CONTENTS_MILEAGE_LIST,      //마일리지내역
} WEB_CONTENTS_TYPE;
/*
typedef enum REQUEST_TYPE
{
    GS = 0, //대리운전고객
    GD,     //대리운전기사
    VS,     //발렛파킹고객
    VD      //발렛파킹기사
} RequestType;
*/


#endif /* Header_h */
