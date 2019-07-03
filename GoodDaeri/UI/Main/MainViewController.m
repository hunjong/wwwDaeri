//
//  MainViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "MainViewController.h"
#import "TMap.h"
#import "NetworkManager.h"
#import "DestinationTabViewController.h"
#import "DestinationMapViewController.h"
#import "DestinationViewController.h"
#import "FavoriteViewController.h"
#import "CommonMessageView.h"
#import "responseData.h"
#import "PayingViewController.h"
#import "CancelViewController.h"
#import "TerminationViewController.h"
#import "NavigationController.h"
#import "AppDelegate.h"

@import Firebase;



@interface MainViewController () <TMapViewDelegate,CLLocationManagerDelegate,UITextFieldDelegate,RouteSearchDelegate>
{
    TMapView* _mapView;
    CLLocationManager *locationManager;
    CGRect routeViewAreaFrame;
    BOOL isMyLocationSet;
    double latestMyLat;
    double latestMyLon;
    TMapMarkerItem *depatureMarker;
    TMapMarkerItem *wayPointMarker;
    TMapMarkerItem *destinationMarker;
    TMapMarkerItem *driverMarker;
    NSInteger optionDistance;
    NSInteger optionCost;
    NSInteger optionOriginalCost;
    NSInteger waitingCost;
    PAYMENT_TYPE payMethod;
    CAR_TYPE carType;
    NSInteger optionMileage;
    NSInteger useMileage;
    NSString *response_id;
    BOOL useMileageOnceClicked;
    NSTimer *driverTimer;
    NSTimer *locationTimer;
    NSInteger currentZoomLevel;
    CGRect guideViewFrame;
    BOOL isTextFieldClear;
}

@end


@implementation MainViewController

typedef enum _MAIN_STATE {
    MAIN_STATE_NONE = 0x00,
    MAIN_STATE_OPTION_SELECT = 0x01,
    MAIN_STATE_MILEAGE_USE = 0x02,
    MAIN_STATE_CARD = 0x03,
    MAIN_STATE_CONFIRM = 0x04,
    MAIN_STATE_WAITING_DRIVER = 0x05,
    MAIN_STATE_MOVING_DRIVER = 0x06
} MAIN_STATE;

static volatile MAIN_STATE _pageWaitUserSelection = MAIN_STATE_NONE;
static NSString *depatureMarkerId = @"pin_dark_blue2";
static NSString *waypoinMarkerId = @"pin_gray2";
static NSString *destinationMarkerId = @"pin_red2";
static NSString *driverMarkerId = @"chauffeur2";

int DEFAULT_COST = 10000;
int MIN_COST = 6000;

- (void)initCardSelectState
{
    if([[NSUserDefaults standardUserDefaults]boolForKey:SAVEKEY_PREFER_CARD]){
        [_optionSettingSegmented setSelectedSegmentIndex:1];
        _pageWaitUserSelection = MAIN_STATE_CARD;
        
    }else{
        [_optionSettingSegmented setSelectedSegmentIndex:0];
        payMethod = PAYMENT_TYPE_CASH;
        _pageWaitUserSelection = MAIN_STATE_CONFIRM;
    }
}

- (void)initMethodSelectState
{
    if([[NSUserDefaults standardUserDefaults]boolForKey:SAVEKEY_PREFER_MANUAL]){
        [_opntionTransmisionSegmented setSelectedSegmentIndex:1];
        carType = CAR_TYPE_MANUAL;
        
    }else{
        [_opntionTransmisionSegmented setSelectedSegmentIndex:0];
        carType = CAR_TYPE_MANUAL;
    }
}

- (void)setMainView
{
    switch (_pageWaitUserSelection) {
        case MAIN_STATE_NONE:
            _bottomButtonAreaView.hidden = NO;
            
            //routeViewAreaFrame = CGRectMake(0, _titleView.frame.size.height, _routeSearchView.frame.size.width, _routeSearchView.frame.size.height);
            if(!_routeSearchView){
                routeViewAreaFrame = CGRectMake(0, _titleView.frame.size.height, _titleView.frame.size.width, 151);
                _routeSearchView = [[[NSBundle mainBundle] loadNibNamed:@"RouteSearchView" owner:self options:nil] objectAtIndex:0];
                
            }
            
            if(![_routeSearchView isDescendantOfView:self.view]){
                [self.view addSubview:_routeSearchView];
                _routeSearchView.frame = routeViewAreaFrame;
                [_routeSearchView reset];
                _routeSearchView.delegate = self;
            }
            _guideViewArea.hidden = NO;
            _guideViewLabel.text = NSLocalizedString(@"main_search_box_hint", nil);
            guideViewFrame = _guideViewArea.frame;
            
            if([_waitingView isDescendantOfView:self.view]){
                _waitingView.hidden = NO;
                [_waitingView removeFromSuperview];
            }
            if([_confirmationAreaView isDescendantOfView:self.view]){
                [_confirmationAreaView removeFromSuperview];
            }
            //가격설정
            optionCost = DEFAULT_COST;
            optionOriginalCost = DEFAULT_COST;
            _optionSettingAreaView.hidden = YES;
            _chauffeurWaitingDetailView.hidden = YES;
            _chauffeurMovingDetailView.hidden = YES;
            _refreshButton.hidden = NO;
            _chauffeurMovingAreaView.hidden = NO;
            if([_chauffeurMovingAreaView isDescendantOfView:self.view]){
                [_chauffeurMovingAreaView removeFromSuperview];
            }
            [_callButton setTitle:NSLocalizedString(@"main_order_action", nil) forState:UIControlStateNormal];
            locationManager.allowsBackgroundLocationUpdates = NO;
            break;
            
        case MAIN_STATE_OPTION_SELECT:
            _optionSettingAreaView.hidden = NO;
            [_confirmationAreaView removeFromSuperview];
            _guideViewArea.hidden = YES;
            //거리설정
            _optionSettingDistanceLabel.text=[NSString stringWithFormat:@"%.2fkm",optionDistance/1000.00];
            
            _optionSettingCostLabel.text = [NSString stringWithFormat:@"%d,%@",optionCost/1000,@"000"];
            [_callButton setTitle:NSLocalizedString(@"main_order_action2", nil) forState:UIControlStateNormal];
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_0",nil);
            [self initCardSelectState];
            [self initMethodSelectState];
            //from waiting
            _waitingView.hidden = YES;
            
            locationManager.allowsBackgroundLocationUpdates = NO;
            
            _bottomButtonAreaView.hidden = NO;
            break;
        case MAIN_STATE_MILEAGE_USE:
            [self.view addSubview:_confirmationAreaView];
            _confirmationAreaView.frame = self.view.frame;
            _confirmationCenterButton.hidden = YES;
            break;
        case MAIN_STATE_CARD:
            
            
            [self performSegueWithIdentifier:@"seguePaying" sender:self];
            
            
            break;
        case MAIN_STATE_CONFIRM:
            
            break;
        case MAIN_STATE_WAITING_DRIVER:
            
            _optionSettingAreaView.hidden = YES;
            
            _chauffeurWaitingDetailView.hidden = NO;
            CGRect startFrame = _chauffeurWaitingDetailView.frame;
            CGFloat startY = _titleView.frame.size.height + [_routeSearchView getVisibleHeight];
            _chauffeurWaitingDetailView.frame = CGRectMake(startFrame.origin.x,startY , startFrame.size.width, startFrame.size.height);
            [self.view bringSubviewToFront:_chauffeurWaitingDetailView];
            
            [self.view addSubview:_waitingView];
            _waitingView.frame = self.view.frame;
            _waitingView.hidden = NO;
            [_waitingView setDriverWaitingViewWithCost:optionCost depature:_routeSearchView.depature wayPoint:_routeSearchView.wayPoint destination:_routeSearchView.destination];
            
            
            _bottomButtonAreaView.hidden = YES;
            ////[_routeSearchView removeFromSuperview];
            _guideViewArea.hidden = NO;
            _guideViewLabel.text = NSLocalizedString(@"main_search_box_hint_waiting", nil);
            CGRect frame = _guideViewArea.frame;
            frame.origin.y = self.view.frame.size.height - _guideViewArea.frame.size.height;
            _guideViewArea.frame = frame;
            _refreshButton.hidden = YES;
            locationManager.allowsBackgroundLocationUpdates = YES;
            break;
        case MAIN_STATE_MOVING_DRIVER:
            [_routeSearchView removeFromSuperview];
            
            _guideViewArea.hidden = YES;
            [_waitingView removeFromSuperview];
            [self.view addSubview:_chauffeurMovingAreaView];
            _chauffeurMovingAreaView.frame = self.view.frame;
            _chauffeurMovingAreaView.hidden = NO;
            _chauffeurWaitingDetailView.hidden = YES;
            _chauffeurMovingDetailView.hidden = NO;
            locationManager.allowsBackgroundLocationUpdates = YES;
            break;
            
        default:
            break;
    }
}

- (void)updateMainView
{
    
    AppDelegate *delagate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if(delagate.isCallInfo){
        delagate.isCallInfo = FALSE;
        _pageWaitUserSelection = MAIN_STATE_WAITING_DRIVER;
        [self callInfoWithMainViewUpdate:YES];
        [delagate TTS:NSLocalizedString(@"기다리는중음성멘트", nil)];
        NSString *message;
        if(!delagate.isCallCanceled){
            message = NSLocalizedString(@"main_order_before_message",nil);
        }else{
            message = NSLocalizedString(@"connected_driver_from_cancel",nil);
            delagate.isCallCanceled = FALSE;
        }
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithNoticeMessage:message centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
            //[((AppDelegate *)[[UIApplication sharedApplication]delegate]) resetAction];//test
        }];
        
    }else if(delagate.isCallCheckMade){
        delagate.isCallCheckMade = FALSE;
        _pageWaitUserSelection = MAIN_STATE_MOVING_DRIVER;
        [self actionAccecptWithMainViewUpdate:YES];
        [delagate TTS:NSLocalizedString(@"대리기사이동음성멘트", nil)];
    }else if(delagate.isCallDone){
        delagate.isCallDone = FALSE;
        [self initialState];
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithNoticeMessage:NSLocalizedString(@"connected_finish_driver_mesg",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
            
        }];
        
    }else if(delagate.urlParameters){
        //test
        NSString *slat = [delagate.urlParameters objectForKey:@"slat"];
        NSString *slon = [delagate.urlParameters objectForKey:@"slon"];
        NSString *elat = [delagate.urlParameters objectForKey:@"elat"];
        NSString *elon = [delagate.urlParameters objectForKey:@"elon"];
        TMapPoint *sPoint = [[TMapPoint alloc] initWithLon:[slon doubleValue] Lat:[slat doubleValue]];
        NSString *sAddress = [[[TMapPathData alloc] init] convertGpsToAddressAt:sPoint];
        TMapPoint *ePoint = [[TMapPoint alloc] initWithLon:[elon doubleValue] Lat:[elat doubleValue]];
        NSString *eAddress = [[[TMapPathData alloc] init] convertGpsToAddressAt:ePoint];
        [_routeSearchView setDeparture:sAddress];
        [_routeSearchView setDestination:eAddress];
        [self setDepatureMarker:[NSDecimalNumber decimalNumberWithString:slon] lat:[NSDecimalNumber decimalNumberWithString:slat] title:sAddress];
        [self setDestinationMarker:[NSDecimalNumber decimalNumberWithString:elon] lat:[NSDecimalNumber decimalNumberWithString:elat] title:eAddress];
        if([self findPolyLine]){
            _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
            [self setMainView];
            [self callNew];
            [_mapView setTrackingMode:FALSE];
            [_mapView setSightVisible:FALSE];
        }
        delagate.urlParameters = nil;
        
    }else{
        [delagate TTS:NSLocalizedString(@"메인시작음성멘트", nil)];
        
        //[self callCheck];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self memberJoin];
    
    _secondColorBarLine.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    _callButton.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    _confirmationTitleLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationTitleLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationSavePointTitleLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationAvailablePointTitleLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationSavePointLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationAvailablePointLabel.textColor = UIColorFromRGB(SECOND_COLOR);
    _confirmationLeftButton.titleLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationTitleLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationCenterButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _confirmationRightButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _optionSettingMileageButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _chauffeurMovingDetailButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _chauffeurWaitingDetailButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _optionSettingSegmented.tintColor = UIColorFromRGB(BASIC_COLOR);
    _opntionTransmisionSegmented.tintColor = UIColorFromRGB(BASIC_COLOR);
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self initCardSelectState];
    [self initMethodSelectState];
    _pageWaitUserSelection = MAIN_STATE_NONE;
    
    [self setMainView];
    [self updateMainView];
    [self createMapView];
    self.findType = DESTINATION_TWOWAY;
    ///////locationManager.allowsBackgroundLocationUpdates = NO;
    
    
}

- (void) memberJoin
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:SAVEKEY_MEMBERJOIN]){
        
        NSString *phone = [[[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_PHONE_NUMBER] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *recommender = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_RECOMMEND];
        NSString *fcm = [[NetworkManager sharedInstance] fcmToken];
        
        [[NetworkManager sharedInstance] memberJoin:@"" tel:phone email:@"" address:@"" recommander:recommender ?: @"" order_type:MEMBER_JOIN_ORDER_TYPE_ADD fcm_token:fcm complete:^(BOOL success, responseData *data){
            if(success)
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SAVEKEY_MEMBERJOIN];
        }];
        
    }else{
        
        /*
        [[FIRInstanceID instanceID] instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                            NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error fetching remote instance ID: %@", error);
            } else {
                [[NetworkManager sharedInstance] setFcmToken:result.token];
                [[NetworkManager sharedInstance] checkUpdate:^(BOOL success, CheckUpdateData *checkUpdateData)
                 {
                 }];
                
            }
        }];
         */
    }
    
}



- (void) memoActionSheet
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"main_order_memo_hint",nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_0",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_0",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_1",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_1",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_2",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_2",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_3",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_3",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_4",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_4",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_5",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_5",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_6",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_6",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_7",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_7",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_8",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
            _optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_8",nil);
        //}];
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0)
        {
            continue;
        }
        
        //Select only valid location and also location with good accuracy
        if(newLocation!=nil&&theAccuracy>0
           &&theAccuracy<2000
           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
            
            [[NetworkManager sharedInstance] setMyLatitude:theLocation.latitude];
            [[NetworkManager sharedInstance] setMyLongitude:theLocation.longitude];
            TMapPoint *point = [[TMapPoint alloc] initWithLon:theLocation.longitude Lat:theLocation.latitude];
            latestMyLat = theLocation.latitude;
            latestMyLon = theLocation.longitude;
            if(!isMyLocationSet && _mapView){
                if(_routeSearchView.depature && [_routeSearchView.depature isEqualToString:@""]){
                    //[_mapView setCenterPoint:point];
                    [self setDepatureLocation:point withTimer:YES];
                }
            }
        }
    }
    
}

- (UIImage *)imageWithHalf:(UIImage *)image
{
    CGSize size = image.size;
    size.width = size.width/2;
    size.height = size.height/2;
    
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


-(void) initialState
{
    //[((AppDelegate *)[[UIApplication sharedApplication]delegate]) resetAction];
    [_mapView removeTMapMarkerItemID:depatureMarkerId];
    [_mapView removeTMapMarkerItemID:destinationMarkerId];
    [_mapView removeTMapMarkerItemID:waypoinMarkerId];
    [_mapView removeTMapMarkerItemID:driverMarkerId];
    [_routeSearchView reset];
    isMyLocationSet = FALSE;
    destinationMarker = nil;
    depatureMarker = nil;
    wayPointMarker = nil;
    driverMarker = nil;
    [_mapView removeAllTMapMarkerItems];
    [_mapView removeTMapPath];
    _pageWaitUserSelection = MAIN_STATE_NONE;
    [self setMainView];
    optionMileage = 0;
    useMileage = 0;
    optionOriginalCost = 0;
    waitingCost = 0;
    useMileageOnceClicked = FALSE;
    _isCallCancelledInCarDispatch = FALSE;
    [driverTimer invalidate];
    _optionSettingMemoTextField.text = @"";
    isTextFieldClear = FALSE;
    _mapView.zoomLevel = currentZoomLevel; //줌레벨유지
    [_mapView setTrackingMode:TRUE];
    [_mapView setSightVisible:FALSE];
    if(latestMyLat != 0 && latestMyLon != 0){
        TMapPoint *point = [[TMapPoint alloc] initWithLon:latestMyLon
                                                      Lat:latestMyLat];
        [_mapView setCenterPoint:point];
        [self setDepatureLocation:point withTimer:NO];
    }
    self->_confirmationRightButton.titleLabel.text = NSLocalizedString(@"btn_use", nil);
    
}


#pragma mark - call

//요청
- (void) callNew
{
    [[NetworkManager sharedInstance]callNew:_routeSearchView.depature start:depatureMarker.getTMapPoint.coordinate target_addr:_routeSearchView.destination target:destinationMarker.getTMapPoint.coordinate relay_addr:_routeSearchView.wayPoint relay:wayPointMarker.getTMapPoint.coordinate value:optionCost mileage:optionMileage meter:optionDistance paymethod:payMethod car_type:carType memo:_optionSettingMemoTextField.text complete:^(BOOL success, callData* data){
        
        if(success){
            
            self->optionMileage =  data.member_mileage > data.max_use_mileage? data.max_use_mileage : data.member_mileage;
            self->optionCost = data.driver_charge;
            self->optionOriginalCost = data.driver_charge;
            self->_optionSettingCostLabel.text = [NSString stringWithFormat:@"%d,%@",data.driver_charge/1000,@"000"];
            
            
            self->_confirmationSavePointLabel.text = [NSString stringWithFormat:@"%ld %@", (long)data.member_mileage ,NSLocalizedString(@"dialog_mileage_unit", nil)];
            self->_confirmationAvailablePointLabel.text = [NSString stringWithFormat:@"%ld %@", (long)data.max_use_mileage ,NSLocalizedString(@"dialog_mileage_unit", nil)];
            
            if(self->optionMileage > 0){
            NSString *guide1 = [NSString stringWithFormat:NSLocalizedString(@"dialog_mileage_guide1", nil),(long)data.max_use_mileage];
            //NSString *guide2 = [NSString stringWithFormat:NSLocalizedString(@"dialog_mileage_guide2", nil),(long)data.max_use_mileage];
                NSString *guide2 = @"";
                
                self->_confirmationNowPointLabel.text = [NSString stringWithFormat:@"%@\n%@",guide1,guide2];
                self->_confirmationRightButton.hidden = NO;
                self->_confirmationLeftButton.hidden = NO;
                self->_confirmationCenterButton.hidden = YES;
                self->_confirmationLeftButton.titleLabel.text = NSLocalizedString(@"btn_close", nil);
                self->_confirmationRightButton.titleLabel.text = NSLocalizedString(@"btn_use", nil);
            }else{
                
                self->_confirmationNowPointLabel.text = NSLocalizedString(@"dialog_mileage_empty", nil);
                
                self->_confirmationRightButton.hidden = YES;
                self->_confirmationLeftButton.hidden = YES;
                self->_confirmationCenterButton.hidden = YES;
                self->_confirmationCenterButton.titleLabel.text = NSLocalizedString(@"btn_close", nil);
            }
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
}

- (void) callAdjust
{
    [[NetworkManager sharedInstance]call:_routeSearchView.depature start:depatureMarker.getTMapPoint.coordinate target_addr:_routeSearchView.destination target:destinationMarker.getTMapPoint.coordinate relay_addr:_routeSearchView.wayPoint relay:wayPointMarker.getTMapPoint.coordinate value:optionCost mileage:optionMileage meter:optionDistance paymethod:payMethod car_type:carType memo:_optionSettingMemoTextField.text order_type:CALL_ORDER_TYPE_CHECK complete:^(BOOL success, callData* data){
        if(success){
        }
    }];
}

//기사 위치 확인 위치표시
- (void) callDriver
{
    [[NetworkManager sharedInstance]callDriver:^(BOOL success,callDriverData *data){
        if(success){
            double driverLat = [data.driver_lat doubleValue];
            double driverLon = [data.driver_lon doubleValue];
            double myLat = [NetworkManager sharedInstance].myLatitude;
            double myLon = [NetworkManager sharedInstance].myLongitude;
            
            CLLocation *driverLocation = [[CLLocation alloc] initWithLatitude:driverLat longitude:driverLon];
            CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:myLat longitude:myLon];
            CLLocationDistance distance = [driverLocation distanceFromLocation:myLocation];
            NSLog(@"드라이버와 나의거리: %f",distance);
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
}

//2차확인
- (void) callMakeComplete
{
    [[NetworkManager sharedInstance]call:_routeSearchView.depature start:depatureMarker.getTMapPoint.coordinate target_addr:_routeSearchView.destination target:destinationMarker.getTMapPoint.coordinate relay_addr:_routeSearchView.wayPoint relay:wayPointMarker.getTMapPoint.coordinate value:optionOriginalCost mileage:useMileage meter:optionDistance paymethod:payMethod car_type:carType memo:_optionSettingMemoTextField.text order_type:CALL_ORDER_TYPE_COMPLETE complete:^(BOOL success, callData* data){
        if(success){
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithNoticeMessage:NSLocalizedString(@"main_order_complete_message", nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
            
            waitingCost = 0;
            _pageWaitUserSelection = MAIN_STATE_WAITING_DRIVER;
            [self setMainView];
            [_mapView setTrackingMode:TRUE];
            [_mapView setSightVisible:FALSE];
            [((AppDelegate *)[[UIApplication sharedApplication]delegate])TTS:NSLocalizedString(@"기다리는중음성멘트", nil)];
            
        }];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
}

//시작시 기사대기중인지확인
- (void) callCheck
{
    [[NetworkManager sharedInstance]call:_routeSearchView.depature start:depatureMarker.getTMapPoint.coordinate target_addr:_routeSearchView.destination target:destinationMarker.getTMapPoint.coordinate relay_addr:_routeSearchView.wayPoint relay:wayPointMarker.getTMapPoint.coordinate value:optionOriginalCost mileage:optionMileage meter:optionDistance paymethod:payMethod car_type:carType memo:_optionSettingMemoTextField.text order_type:CALL_ORDER_TYPE_CHECK complete:^(BOOL success, callData* data){
        
        if(success){
            NSString *alarmMessage =data.message;
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:alarmMessage centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
                _pageWaitUserSelection = MAIN_STATE_WAITING_DRIVER;
                [self setMainView];
                [_mapView setTrackingMode:TRUE];
                [_mapView setSightVisible:FALSE];
                [((AppDelegate *)[[UIApplication sharedApplication]delegate])TTS:NSLocalizedString(@"기다리는중음성멘트", nil)];
            }];
        }
        
    }];
}

//기사취소시 기사응답대기
-(void)callInfoWithMainViewUpdate:(BOOL)isUpdate
{
    [self setMainView];
    
    [driverTimer invalidate];
    driverTimer = nil;
    
    [[NetworkManager sharedInstance]callInfo:^(BOOL success, callInfoData *data){
        if(success){
            
            NSString *alarmMessage =data.message;
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:alarmMessage centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
                if(isUpdate){
                    [self->_routeSearchView setDeparture:data.start_addr];
                    [self->_routeSearchView setDestination:data.target_addr];
                    [self setDepatureMarker:data.start_lon lat:data.start_lat title:data.start_addr];
                    [self setDestinationMarker:data.target_lon lat:data.target_lat title:data.target_addr];
                    if(data.relay_addr){
                        [_routeSearchView setWayPoint:data.relay_addr];
                        [self setWaypointMarker:data.relay_lon lat:data.relay_lat title:data.relay_addr];
                        
                    }else{
                        [_routeSearchView setWayPoint:nil];
                    }
                    self->optionMileage = data.mileage;
                    self->optionCost = data.value;
                    self->optionOriginalCost = data.value;
                    self->optionDistance = data.meter;
                    self->_optionSettingMemoTextField.text = data.memo;
                    if(data.paymethod == NONE_CARD){
                        self->payMethod = PAYMENT_TYPE_NONE;
                    }else if(data.paymethod == DIRECT_CARD || data.paymethod == AGENCY_CARD){
                        self->payMethod = PAYMENT_TYPE_CARD;
                    }else{
                        self->payMethod = PAYMENT_TYPE_CASH;
                    }
                    self->carType = data.car_type;
                    
                   
                }
                
                [((AppDelegate *)[[UIApplication sharedApplication]delegate])TTS:NSLocalizedString(@"기다리는중음성멘트", nil)];
                
            }];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                [self callCheck];
            }];
        }
    }];
}

//고객취소
- (void)callCancel
{
    [[NetworkManager sharedInstance]callCancel:CALL_CANCEL_ORDER_TYPE_INVALIDITY complete:^(BOOL success, responseData* data){
        if(success){
        NSString *alarmMessage =data.message;
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithNoticeMessage:alarmMessage centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
            
            [self initialState];
        }];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
    
}

//배차중고객취소
- (void)callCancelCarDispatch
{
    [[NetworkManager sharedInstance]callCancel:CALL_CANCEL_ORDER_TYPE_CANCEL complete:^(BOOL success, responseData* data){
        if(success){
            
            if([data.response_yn isEqualToString:@"Y"] || [data.response_yn isEqualToString:@"y"]){
                
                [self initialState];
                
            }else{
                //죄송합니다 지금은 취소를 할수 없습니다. 등
                
                if(data.message && data.message.length > 0){
                    NSString *alarmMessage =data.message;
                    CommonMessageView *messageView = [CommonMessageView createView:self.view];
                    [messageView initWithNoticeMessage:alarmMessage centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                        //[self initialState];
                        
                    }];
                }else{
                    CommonMessageView *messageView = [CommonMessageView createView:self.view];
                    [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                        //[self initialState];
                    }];
                    
                }
                
            }
            
            
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
    
}

//완료
- (void)callDone
{
    [[NetworkManager sharedInstance]callCancel:CALL_CANCEL_ORDER_TYPE_DONE complete:^(BOOL success, responseData* data){
        if(success){
            [self initialState];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
    
}

-(void) driverPosition
{
    [[NetworkManager sharedInstance] callDriver:^(BOOL success, callDriverData *data){
        if(success){
            [self setDriverMarker:data.driver_lon lat:data.driver_lat title:nil];
            
            TMapPoint *point = [[TMapPoint alloc] initWithLon:[data.driver_lon doubleValue] Lat:[data.driver_lat doubleValue]];
            NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:point];
            [self.chauffeurMovingAreaView updateDriverPosition:address];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
}


#pragma mark - Click event

- (IBAction)refreshClick:(id)sender {
    [self initialState];
}

//옵션버튼
- (IBAction)minusClick:(id)sender {
    //가격설정
    if(optionCost == MIN_COST){
        return;
    }
    optionCost = optionCost -1000;
    optionOriginalCost -= 1000;
    _optionSettingCostLabel.text = [NSString stringWithFormat:@"%d,%@",optionCost/1000,@"000"];
}
- (IBAction)plusClick:(id)sender {
    optionCost = optionCost +1000;
    optionOriginalCost += 1000;
    _optionSettingCostLabel.text = [NSString stringWithFormat:@"%d,%@",optionCost/1000,@"000"];
}
- (IBAction)payMethodChanged:(id)sender {
    UISegmentedControl *s = (UISegmentedControl *)sender;
    
    if (s.selectedSegmentIndex == 0)
    {
        payMethod = PAYMENT_TYPE_CASH;
        _pageWaitUserSelection = MAIN_STATE_CONFIRM;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SAVEKEY_PREFER_CARD];
    }
    else
    {
        payMethod = PAYMENT_TYPE_CARD;
        _pageWaitUserSelection = MAIN_STATE_CARD;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SAVEKEY_PREFER_CARD];
    }
}
- (IBAction)transmisionChanged:(id)sender {
    
    UISegmentedControl *s = (UISegmentedControl *)sender;
    
    if (s.selectedSegmentIndex == 0)
    {
        carType = CAR_TYPE_AUTO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SAVEKEY_PREFER_MANUAL];
    }
    else
    {
        carType = CAR_TYPE_MANUAL;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SAVEKEY_PREFER_MANUAL];
    }
}

- (IBAction)mileageClick:(id)sender {
    
    //NSString *message = [NSString stringWithFormat:NSLocalizedString(@"dialog_mileage_already_use", nil),mileageUsePerCall];
    //NSString *message = [NSString stringWithFormat:@"%@:%d %@\n%@",NSLocalizedString(@"dialog_mileage_saved", nil),0,NSLocalizedString(@"dialog_mileage_saved", nil), NSLocalizedString(@"dialog_mileage_empty", nil)];
    
    NSString *message = NSLocalizedString(@"dialog_mileage_empty", nil);
    
    if(optionMileage <= 0 && !useMileageOnceClicked){
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:NSLocalizedString(@"dialog_mileage_title", nil) message:message centerButtonText:NSLocalizedString(@"btn_close", nil) centerButtonCallback:^{
            
        }];
        return;
    }else if(useMileageOnceClicked){
        
        if(useMileage == 0){
            
            optionCost = optionCost - optionMileage;
            _optionSettingCostLabel.text = [NSString stringWithFormat:@"%ld,%@",optionCost/1000,@"000"];
            _confirmationRightButton.titleLabel.text = [NSString stringWithFormat:@"+%ld%@",(long)optionMileage,koreaMoney];
            useMileage = optionMileage;
            
        }else{
            
            optionCost = optionCost + optionMileage;
            _optionSettingCostLabel.text = [NSString stringWithFormat:@"%ld,%@",optionCost/1000,@"000"];
            _confirmationRightButton.titleLabel.text = [NSString stringWithFormat:@"0%@",koreaMoney];
            useMileage = 0;
        }
        
        
    }else{
        _pageWaitUserSelection = MAIN_STATE_MILEAGE_USE;
        [self setMainView];
    }
    //if(!useMileage){
    
        /*
    }else{
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:NSLocalizedString(@"dialog_mileage_title", nil) message:message centerButtonText:NSLocalizedString(@"btn_close", nil) centerButtonCallback:^{
            
        }];
    
    }
         */
    
}

- (IBAction)memoClick:(id)sender {
    [self memoActionSheet];
}

//하단처음버튼
- (IBAction)phoneCallClick:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NetworkManager sharedInstance].callCenterTel ?: cscenter_phone_number]];
}
- (IBAction)callClick:(id)sender {
    
    if(_pageWaitUserSelection == MAIN_STATE_CARD){
        [self setMainView];
        [((AppDelegate *)[[UIApplication sharedApplication]delegate])TTS:NSLocalizedString(@"카드음성멘트", nil)];
    }else if(_pageWaitUserSelection == MAIN_STATE_CONFIRM){
        
        [self callMakeComplete];
    }else if(_pageWaitUserSelection == MAIN_STATE_OPTION_SELECT){
        [self initMethodSelectState];
        [self initCardSelectState];
        [self callMakeComplete];
    }else{
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        NSString *titleMessage = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = NSLocalizedString(@"main_destnation_box_hint",nil);
        NSString *centerButtonText = NSLocalizedString(@"btn_ok",nil);
        [messageView initWithTitle:titleMessage message:message centerButtonText:centerButtonText centerButtonCallback:nil];
    }
}

//대기시버튼
- (IBAction)registrationDetailCloseClick:(id)sender {
    _waitingView.hidden = YES;
}

- (IBAction)registrationCancelClick:(id)sender {
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    NSString *titleMessage = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *message = NSLocalizedString(@"waitcall_question_cancel",nil);
    NSString *noButtonText = NSLocalizedString(@"btn_no",nil);
    NSString *yesButtonText = NSLocalizedString(@"btn_yes",nil);
    
    [messageView initWithTitle:titleMessage message:message leftButtonText:noButtonText leftButtonCallback:^{
        
    } rightButtonText:yesButtonText rightButtonCallback:^
     {
         [self callCancel];
     }];
}

- (IBAction)registrationCostAdjustClick:(id)sender {
    waitingCost = optionCost;
    _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
    [self setMainView];
    [self initCardSelectState];
    [self initMethodSelectState];
}


- (IBAction)movingDriverDetailClick:(id)sender {
    _chauffeurMovingAreaView.hidden = NO;
}
- (IBAction)movingDriverDetailCloseClick:(id)sender {
    _chauffeurMovingAreaView.hidden = YES;
}
- (IBAction)movingAppFinishClick:(id)sender {
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    NSString *titleMessage = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *message = NSLocalizedString(@"connected_finish_message",nil);
    NSString *noButtonText = NSLocalizedString(@"btn_no",nil);
    NSString *yesButtonText = NSLocalizedString(@"btn_yes",nil);
    
    [messageView initWithTitle:titleMessage message:message leftButtonText:noButtonText leftButtonCallback:^{
       
    } rightButtonText:yesButtonText rightButtonCallback:^
     {
         exit(0);
     }];
}

//마일리지창 버튼
- (IBAction)confirmationLeftClick:(id)sender {
    
    if(useMileageOnceClicked){
        optionCost = optionCost + optionMileage;
        _optionSettingCostLabel.text = [NSString stringWithFormat:@"%ld,%@",optionCost/1000,@"000"];
        self->_confirmationRightButton.titleLabel.text = NSLocalizedString(@"btn_use", nil);
    }
    optionMileage = 0;
    useMileageOnceClicked = FALSE;
    _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
    [self setMainView];
}
- (IBAction)confirmationRightClick:(id)sender {
    optionCost = optionCost - optionMileage;
    _optionSettingCostLabel.text = [NSString stringWithFormat:@"%ld,%@",optionCost/1000,@"000"];
    _confirmationRightButton.titleLabel.text = [NSString stringWithFormat:@"+%ld",(long)optionMileage];
    useMileage = optionMileage;
    useMileageOnceClicked = TRUE;
    _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
    [self setMainView];
}
- (IBAction)confirmationCenterClick:(id)sender {
    optionMileage = 0;
    useMileageOnceClicked = FALSE;
    _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
    [self setMainView];
}

//기사 이동중 하단버튼
- (IBAction)movingCallCenterClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NetworkManager sharedInstance].callCenterTel ?: cscenter_phone_number]];
    
}
- (IBAction)movingFinishClick:(id)sender {
    
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    NSString *titleMessage = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *message = NSLocalizedString(@"connected_cancel_message",nil);
    NSString *noButtonText = NSLocalizedString(@"btn_no",nil);
    NSString *yesButtonText = NSLocalizedString(@"btn_yes",nil);
    
    [messageView initWithTitle:titleMessage message:message leftButtonText:noButtonText leftButtonCallback:^{
        
    } rightButtonText:yesButtonText rightButtonCallback:^
     {
         [self callCancelCarDispatch];
     }];
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    //    [self performSegueWithIdentifier:@"segueCancel" sender:self];
    //});
}

- (IBAction)registrationDetailClick:(id)sender {
    _waitingView.hidden = NO;
}



#pragma mark - TMAP

- (void)createMapView {
    _mapView = [[TMapView alloc] initWithFrame:self.mapAreaView.bounds];
    [_mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_mapView setDelegate:self]; // 지도이벤트 델리게이트 연결
    //[_mapView setGpsManagersDelegate:self];
    [_mapView setSKTMapApiKey:TMAP_APPKEY];     // 발급 받은 apiKey 설정
    [self.mapAreaView addSubview:_mapView];
    [_mapView setTrackingMode:TRUE];
    [_mapView setSightVisible:FALSE];
    //currentZoomLevel = [_mapView getZoomLevel];
    [_mapView setZoomLevel:15];
    latestMyLat = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LAT];
    latestMyLon = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LON];
    
    BOOL valid = NO;
    valid = [_mapView isValidTMapPoint:[TMapPoint mapPointWithCoordinate:CLLocationCoordinate2DMake(latestMyLat,latestMyLon)]];
    
    if(latestMyLat != 0 && latestMyLon != 0 && valid){
        TMapPoint *point = [[TMapPoint alloc]initWithLon:latestMyLon Lat:latestMyLat];
        [_mapView setCenterPoint:point];
        [self setDepatureLocation:point withTimer:NO];
        
    }
    /*
    UIImage* image = [UIImage imageNamed:@"TrackingDot"];
    
    TMapPoint* mapPoint = [[TMapPoint alloc]initWithLon:latestMyLon Lat:latestMyLat];
    //TMapPoint* mapPoint = [[[TMapPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.566474, 126.985022)] autorelease];
    TMapMarkerItem* marker1 = [[TMapMarkerItem alloc] init];
    [marker1 setTMapPoint:mapPoint];
    [marker1 setIcon:image anchorPoint:CGPointMake(0.5, 1.0)];
    [marker1 setCanShowCallout:YES];
    [marker1 setCalloutTitle:@"CallOut 타이틀"];
    [marker1 setCalloutSubtitle:@"CallOut 서브타이틀"];
    [marker1 setCalloutLeftImage:[UIImage imageNamed:@"minus.png"]];
    [marker1 setCalloutRightButtonImage:[UIImage imageNamed:@"tmap_pass"]];
    [marker1 setName:[NSString stringWithFormat:@"name %@", @"test"]];
    
    [marker1 setEnableClustering:YES];
    [_mapView addTMapMarkerItemID:@"test" Marker:marker1 animated:YES];
     */
    //bringMarkerToFront
}

//클릭이벤트
- (void)onClick:(TMapPoint *)TMP
{
    NSLog(@"onClick: %@", TMP);
}


//롱클릭이벤트
- (void)onLongClick:(TMapPoint*)TMP
{
    NSLog(@"onLongClick: %@", TMP);
    [self setDepatureLocation:TMP withTimer:NO];
    isMyLocationSet = TRUE;
    [_mapView setTrackingMode:FALSE];
    [_mapView setSightVisible:FALSE];
}

//오브젝트(marker, polyline, polygon) 클릭이벤트
- (void)onCustomObjectClick:(TMapObject*)obj
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"TMapMarkerItem clicked:%@", obj);
    }
}

//오브젝트 롱클릭이벤트
- (void)onCustomObjectLongClick:(TMapObject*)obj
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"TMapMarkerItem clicked:%@", obj);
    }
}

- (void)onCustomObjectClick:(TMapObject*)obj screenPoint:(CGPoint)point
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"onCustomObjectClick :%@ screenPoint:{%f, %f}", obj, point.x, point.y);
    }
}

- (void)onCustomObjectLongClick:(TMapObject*)obj screenPoint:(CGPoint)point
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"onCustomObjectLongClick :%@ screenPoint:{%f, %f}", obj, point.x, point.y);
    }
}

- (void)onDidScrollWithZoomLevel:(NSInteger)zoomLevel centerPoint:(TMapPoint*)mapPoint
{
    //NSLog(@"zoomLevel: %d point: %@", zoomLevel, mapPoint);
    currentZoomLevel = zoomLevel;
}

- (void)onDidEndScrollWithZoomLevel:(NSInteger)zoomLevel centerPoint:(TMapPoint*)mapPoint
{
    //NSLog(@"zoomLevel: %d point: %@", (int)zoomLevel, mapPoint);
    //    NSLog(@"trackingMode %d", [_mapView getIsTracking]);
    
    if(_pageWaitUserSelection < MAIN_STATE_OPTION_SELECT){
        double lat = [NetworkManager sharedInstance].myLatitude;
        double lon = [NetworkManager sharedInstance].myLongitude;
        if(!isMyLocationSet && lat != latestMyLat && lon != latestMyLon){
            NSLog(@"changeLocation %d", [_mapView getIsTracking]);
            latestMyLat = [NetworkManager sharedInstance].myLatitude;
            latestMyLon = [NetworkManager sharedInstance].myLongitude;
            TMapPoint *point = [[TMapPoint alloc] initWithLon:latestMyLon Lat:latestMyLat];
            [self setDepatureLocation:point withTimer:NO];
        }
    }
}

#pragma mark - textField

- (void)depatureShoudClear:(UITextField *)textField
{
    if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER) return;
    
    isMyLocationSet = FALSE;
    [_routeSearchView setDeparture:nil];
    [_mapView removeTMapMarkerItemID:depatureMarkerId];
    depatureMarker = nil;
    [_mapView setTrackingMode:TRUE];
    [_mapView setSightVisible:FALSE];
    TMapPoint *point = [[TMapPoint alloc] initWithLon:latestMyLon Lat:latestMyLat];
    [self setDepatureLocation:point withTimer:NO];
    
    [self setRouteTextField];
}
- (void)destinationShoudClear:(UITextField *)textField
{
    if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER) return;
    
    [_routeSearchView setDestination:nil];
    [_mapView removeTMapMarkerItemID:destinationMarkerId];
    destinationMarker = nil;
    
    [self setRouteTextField];
}
- (void)waypointShoudClear:(UITextField *)textField
{
    if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER) return;
    
    [_routeSearchView setWayPoint:nil];
    [_mapView removeTMapMarkerItemID:waypoinMarkerId];
    wayPointMarker = nil;
    
    [self setRouteTextField];
}
- (void)depatureTextFieldShouldBeginEditing:(UITextField *)textField
{
    if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER) return;
    self.findType = DEPATURE_TWOWAY;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueDestination" sender:self];
    });
}
- (void)destinationTextFieldShouldBeginEditing:(UITextField *)textField
{
    if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER) return;
    self.findType = DESTINATION_TWOWAY;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueDestination" sender:self];
    });
}
- (void)waypointTextFieldShouldBeginEditing:(UITextField *)textField
{
    if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER) return;
    self.findType = WAYPOINT_THREEWAY;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueDestination" sender:self];
    });
}

- (void) setRouteTextField
{
    [_mapView removeTMapPath];
    //[self setTmapPathIcon];//test
    if(_pageWaitUserSelection != MAIN_STATE_NONE){
        _pageWaitUserSelection = MAIN_STATE_NONE;
        [self setMainView];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(isTextFieldClear){
        isTextFieldClear = FALSE;
        return FALSE;
    }
    
    [self editingDidBeginStarted:textField];
    //[textField endEditing:YES];
    return FALSE;  // Hide both keyboard and blinking cursor.
}

-(void) editingDidBeginStarted:(UITextField *)sender{
    NSLog(@"Editing started here %@",sender);
    
    if(_pageWaitUserSelection < MAIN_STATE_WAITING_DRIVER){
        if(sender == _optionSettingMemoTextField){
            [self memoActionSheet];
        }
    }
    //[sender resignFirstResponder];
    //[sender endEditing:YES];
}

#pragma mark - Marker Textfield

- (BOOL) findPolyLine
{
    if(depatureMarker && destinationMarker && !wayPointMarker){
        TMapPathData* path = [[TMapPathData alloc] init];
        TMapPolyLine *polyLine = [path findPathDataWithType:CAR_PATH startPoint:depatureMarker.getTMapPoint endPoint:destinationMarker.getTMapPoint];
        [self setTmapPathIcon];
        if(polyLine){
            
            [_mapView addTMapPath:polyLine];
            [self centerZoomToPath:polyLine];
            
            
            optionDistance = [polyLine getDistance];
            NSLog(@"polyLine optionDistance1:%f", [polyLine getDistance]);
            return TRUE;
        }
    }else if(depatureMarker && destinationMarker && wayPointMarker){
        
        TMapPathData* path = [[TMapPathData alloc] init];
        NSArray *passPoints = @[wayPointMarker.getTMapPoint,];
        
        TMapPolyLine *polyLine = [path findMultiPathDataWithStartPoint:depatureMarker.getTMapPoint endPoint:destinationMarker.getTMapPoint passPoints:passPoints searchOption:0];
        [self setTmapPathIcon];
        if(polyLine){
            
            [_mapView addTMapPath:polyLine];
            [self centerZoomToPath:polyLine];
            optionDistance = [polyLine getDistance];
            NSLog(@"polyLine optionDistance2:%f", [polyLine getDistance]);
            return TRUE;
        }
    }
    return FALSE;
}

- (void) setDepatureLocation:(TMapPoint * )TMP withTimer:(BOOL)withTimer
{
    if(_pageWaitUserSelection < MAIN_STATE_OPTION_SELECT && TMP.getLatitude > 0 && TMP.getLongitude > 0){
        [self->locationTimer invalidate];
        if(withTimer){
            self->locationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(deptureMakerPolylineAndStartCallWithTimer:) userInfo:TMP repeats:NO];
            
        }else{
            [self deptureMakerPolylineAndStartCall:TMP];
        }
    }
}

- (void)deptureMakerPolylineAndStartCall:(TMapPoint *)TMP
{
    NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:TMP];
    if(!address){
        isMyLocationSet = FALSE;
        [_mapView setTrackingMode:TRUE];
        [_mapView setSightVisible:FALSE];
    }
    [_routeSearchView setDeparture:address];
    NSDecimalNumber *lat =[[NSDecimalNumber alloc]initWithDouble:TMP.getLatitude];
    NSDecimalNumber *lon =[[NSDecimalNumber alloc]initWithDouble:TMP.getLongitude];
    [self setDepatureMarker:lon lat:lat title:address];

    
    if([self findPolyLine]){
        _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
        [self setMainView];
        [self callNew];
        [_mapView setTrackingMode:FALSE];
        [_mapView setSightVisible:FALSE];
    }
}

- (void) deptureMakerPolylineAndStartCallWithTimer:(NSTimer *)timer
{
    TMapPoint *TMP = timer.userInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self deptureMakerPolylineAndStartCall:TMP];
    });
    
}


- (void) centerZoomToPath:(TMapPolyLine *)polyLine
{
    /*
    double ltLat, ltLon;
    double rbLat, rbLon;
    
    // set default;
    ltLat = depatureMarker != nil ? depatureMarker.getTMapPoint.getLatitude : _mapView.getCenterPoint.getLatitude;
    ltLon = depatureMarker != nil ? depatureMarker.getTMapPoint.getLongitude : _mapView.getCenterPoint.getLongitude;
    rbLat = depatureMarker != nil ? depatureMarker.getTMapPoint.getLatitude : _mapView.getCenterPoint.getLatitude;
    rbLon = depatureMarker != nil ? depatureMarker.getTMapPoint.getLongitude : _mapView.getCenterPoint.getLongitude;
    
    NSMutableArray *points = [NSMutableArray new];
    
    if (depatureMarker != nil) [points addObject:depatureMarker.getTMapPoint];
    if (destinationMarker != nil) [points addObject:destinationMarker.getTMapPoint];
    if (wayPointMarker != nil) [points addObject:wayPointMarker.getTMapPoint];
    if (polyLine != nil) [points addObjectsFromArray:polyLine.getLinePoint];
    
    for (TMapPoint *p in points) {
        if (p.getLatitude < ltLat) ltLat = p.getLatitude;
        else if (p.getLatitude > rbLat) rbLat = p.getLatitude;
        if (p.getLongitude < ltLon) ltLon = p.getLongitude;
        else if (p.getLongitude > rbLon) rbLon = p.getLongitude;
    }
    
    TMapPoint *leftTop = [[TMapPoint alloc] initWithLon:ltLon Lat:ltLat];
    TMapPoint *rightBottom = [[TMapPoint alloc] initWithLon:rbLon Lat:rbLat];
    
    //[_mapView zoomToTMapPointLeftTop:leftTop rightBottom:rightBottom];
    
    //[_mapView showFullPath:polyLine.getLinePoint];
    // moveCenterPoint
    double cLat = (ltLat + rbLat) / 2.0;
    double cLon = (ltLon + rbLon) / 2.0;
    TMapPoint *center = [[TMapPoint alloc] initWithLon:cLon Lat:cLat];
    [_mapView setCenterPoint:center];
    
    double llon = rbLon - ltLon;
    double llat = rbLat - ltLat;
    
    double least= llon > llat ? llat:llon;
    
    [_mapView zoomToLatSpan:least*2.5 lonSpan:least*2.5];
    */
    
    
    
    
    
    //line에 맞게 화면 조정
    ////[polyLine addLinePoint:depatureMarker.getTMapPoint];
    ////[polyLine addLinePoint:destinationMarker.getTMapPoint];
    
    TMapInfo *mapInfo=[_mapView getDisplayTMapInfo:polyLine.getLinePoint];
    [_mapView setCenterPoint:mapInfo.mapPoint];
    [_mapView setZoomLevel:mapInfo.zoomLevel-1];
}

- (void) setTextFieldAndMarker
{
    if(!_findData){
        return;
    }
    NSString *title = _findData.title;
    NSString *address = _findData.address;
    
    switch (self.findType) {
        case DEPATURE_TWOWAY: {
        case DEPATURE_THREEWAY:
            [_routeSearchView setDeparture:address];
            isMyLocationSet = TRUE;
            [self setDepatureMarker:_findData.lon lat:_findData.lat title:_findData.title];
            [_mapView setTrackingMode:FALSE];
            [_mapView setSightVisible:FALSE];
            break;
        }
        case DESTINATION_TWOWAY: {
        case DESTINATION_THREEWAY:
            [_routeSearchView setDestination:address];
            
            [self setDestinationMarker:_findData.lon lat:_findData.lat title:_findData.title];
            
            break;
        }
        case WAYPOINT_THREEWAY: {
            [_routeSearchView setWayPoint:address];
            
            [self setWaypointMarker:_findData.lon lat:_findData.lat title:_findData.title];
            break;
        }
        default:
            break;
    }
}

- (void) setDepatureMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title
{
    TMapPoint* mapPoint = [[TMapPoint alloc] initWithLon:[lon doubleValue] Lat:[lat doubleValue]];
    if(depatureMarker == nil){
        depatureMarker = [[TMapMarkerItem alloc] init] ;
        [depatureMarker setIcon:[self imageWithHalf:[UIImage imageNamed:depatureMarkerId]]];
    }else{
        [_mapView removeTMapMarkerItemID:depatureMarkerId];
        depatureMarker = [[TMapMarkerItem alloc] init] ;
        [depatureMarker setIcon:[self imageWithHalf:[UIImage imageNamed:depatureMarkerId]]];
    }
    [depatureMarker setTMapPoint:mapPoint];
    //if(title)
    //    [depatureMarker setName:title];
    
    [_mapView addTMapMarkerItemID:depatureMarkerId Marker:depatureMarker];
    //[_mapView bringMarkerToFront:depatureMarker];
}

- (void) setDestinationMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title
{
    TMapPoint* mapPoint = [[TMapPoint alloc] initWithLon:[lon doubleValue] Lat:[lat doubleValue]];
    if(destinationMarker == nil){
        destinationMarker = [[TMapMarkerItem alloc] init] ;
        
    }
    NSLog(@"dest : %f, %f",mapPoint.coordinate.latitude,mapPoint.coordinate.longitude);
    [destinationMarker setIcon:[self imageWithHalf:[UIImage imageNamed:destinationMarkerId]]];
    [destinationMarker setTMapPoint:mapPoint];
    //if(title)
    //    [destinationMarker setName:title];
    
    [_mapView addTMapMarkerItemID:destinationMarkerId Marker:destinationMarker animated:YES];
}

- (void) setWaypointMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title
{
    TMapPoint* mapPoint = [[TMapPoint alloc] initWithLon:[lon doubleValue] Lat:[lat doubleValue]];
    if(wayPointMarker == nil){
        wayPointMarker = [[TMapMarkerItem alloc] init] ;
        [wayPointMarker setIcon:[self imageWithHalf:[UIImage imageNamed:waypoinMarkerId]]];
    }
    [wayPointMarker setTMapPoint:mapPoint];
    //if(title)
    //    [wayPointMarker setName:title];
    
    [_mapView addTMapMarkerItemID:waypoinMarkerId Marker:wayPointMarker animated:YES];
    //[_mapView bringMarkerToFront:wayPointMarker];
}

- (void) setDriverMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title
{
    TMapPoint* mapPoint = [[TMapPoint alloc] initWithLon:[lon doubleValue] Lat:[lat doubleValue]];
    if(driverMarker == nil){
        driverMarker = [[TMapMarkerItem alloc] init];
        
        [driverMarker setIcon:[self imageWithHalf:[UIImage imageNamed:driverMarkerId]]];
    }
    [driverMarker setTMapPoint:mapPoint];
    //if(title)
    //    [driverMarker setName:title];
    
    [_mapView addTMapMarkerItemID:driverMarkerId Marker:driverMarker animated:YES];
}

- (void) setTmapPathIcon
{
    if(!wayPointMarker && depatureMarker && destinationMarker){
        [_mapView setTMapPathIconStart:depatureMarker End:destinationMarker];
    }else if(wayPointMarker && depatureMarker && destinationMarker){
        [_mapView setTMapPathIconStart:depatureMarker end:destinationMarker pass:wayPointMarker];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueDestination"])
    {
       
    }else if ([[segue identifier] isEqualToString:@"seguePaying"])
    {
        if ([[segue destinationViewController] isKindOfClass:[PayingViewController class]])
        {
            PayingViewController *nextVC = [segue destinationViewController];
            nextVC.payCost = (NSInteger)optionCost;
            nextVC.productName = PRODUCT_NAME;
            
        }
    }
}


-(IBAction)prepareForUnwindMain:(UIStoryboardSegue *)segue {
    if([segue.sourceViewController isKindOfClass:[DestinationViewController class]]||
       [segue.sourceViewController isKindOfClass:[DestinationTabViewController class]]||[segue.sourceViewController isKindOfClass:[DestinationMapViewController class]]){
        
        [self setTextFieldAndMarker];
        
        
        
        if([self findPolyLine]){
            _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
            [self setMainView];
            [self callNew];
            [_mapView setTrackingMode:FALSE];
            [_mapView setSightVisible:FALSE];
        }
    }else if([segue.sourceViewController isKindOfClass:[FavoriteViewController class]]){
        
        if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER){
            return;
        }
        
            
        [self setTextFieldAndMarker];
        if([self findPolyLine]){
            _pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
            [self setMainView];
        }
    }else if([segue.sourceViewController isKindOfClass:[PayingViewController class]]){
        if(!_isCardCanceled && _isCardPayed){
            
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"main_order_complete_message",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                _pageWaitUserSelection = MAIN_STATE_CONFIRM;
                [self callMakeComplete];
            }];
            
            
            
        }else if(!_isCardCanceled){
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"lost_response_data_card",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
            
        }
    }else if([segue.sourceViewController isKindOfClass:[CancelViewController class]]){
        if(_isCallCancelledInCarDispatch){
            
            [self callCancelCarDispatch];
        }
    }else if([segue.sourceViewController isKindOfClass:[TerminationViewController class]]){
            [self callDone];
        
        if(_withComplain){
            //불만사항접수?
        }
    }
    
    
}


#pragma mark - push message method

//콜이 잡혔음
-(void)actionAccecptWithMainViewUpdate:(BOOL)isUpdate
{
    
    _pageWaitUserSelection = MAIN_STATE_MOVING_DRIVER;
    [self setMainView];
    [((AppDelegate *)[[UIApplication sharedApplication]delegate])TTS:NSLocalizedString(@"대리기사이동음성멘트", nil)];
    [[NetworkManager sharedInstance] callCheckMade:^(BOOL success ,callCheckMadeData *data){
        if(success){
            NSTimeInterval interval = 60.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->driverTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(driverPosition) userInfo:nil repeats:YES];
            });
            
            [self setDriverMarker:data.driver_lon lat:data.driver_lat title:data.driver_name];
            TMapPoint *point = [[TMapPoint alloc] initWithLon:[data.driver_lon doubleValue] Lat:[data.driver_lat doubleValue]];
            NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:point];
            
            if(waitingCost > 0){
                optionCost = waitingCost;
            }
            [self.chauffeurMovingAreaView setRouteInfoWithDriver:address depature:self->_routeSearchView.depature wayPoint:self->_routeSearchView.wayPoint destination:self->_routeSearchView.destination cost:optionCost];
            if(isUpdate){
                //[_routeSearchView setDeparture:data.stitle];
                //[_routeSearchView setDestination:data.dtitle];
                [self setDepatureMarker:data.slon lat:data.slat title:data.stitle];
                [self setDestinationMarker:data.dlon lat:data.dlat title:data.dtitle];
                
                if(data.rtitle){
                    //[_routeSearchView setWayPoint:data.rtitle];
                    [self setWaypointMarker:data.rlon lat:data.rlat title:data.rtitle];
                }else{
                    //[_routeSearchView setWayPoint:nil];
                }
            }
            
            NSString *name = data.driver_name;
            NSString *photo = data.driver_photo_url;
            NSString *insurance = data.driver_insurance;
            //
            [self->_chauffeurMovingAreaView setDriverInfoWithDriverName:name insurance:insurance photo:photo];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
}


//기사가 취소했음
-(void)actionCancel
{
    [self callInfoWithUpdate:NO];
}

//기사도착
-(void)actionDone
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueTermination" sender:self];
    });
}


//vallet

-(void)actionStatusParked
{
    
}
-(void)actionStatusReady
{
    
}
-(void)actionPaynow:(NSInteger)cost;
{
    
}

@end
