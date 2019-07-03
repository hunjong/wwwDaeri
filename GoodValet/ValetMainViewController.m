//
//  ValetMainViewController.m
//  GoodValet
//
//  Created by hunjong choi on 07/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import "ValetMainViewController.h"
#import "ValetMapViewController.h"
#import "ValetListViewController.h"
#import "AppDelegate.h"
#import "CommonMessageView.h"
#import "NetworkManager.h"
#import "TMap.h"
#import "PayingViewController.h"
#import "DestinationViewController.h"
#import "DestinationTabViewController.h"
#import "FavoriteViewController.h"
#import "DestinationMapViewController.h"
#import "CancelViewController.h"
#import "TerminationViewController.h"
#import "CommonMessageView.h"
#import "ValetLastAgreeViewController.h"
#import "SelectNaviViewController.h"
#import "ValetChooseViewController.h"


@interface ValetMainViewController () <CAPSPageMenuDelegate,CLLocationManagerDelegate>
{
    NSMutableArray *resultArray;
    UIEdgeInsets padding;
    CLLocationManager *locationManager;
    double latestMyLat;
    double latestMyLon;
    BOOL isMyLocationSet;
    NSInteger optionCost;
    NSTimer *positionTimer;
}

@property (weak, nonatomic) IBOutlet UIButton *checkBox1;
@property (weak, nonatomic) IBOutlet UIButton *checkBox2;
@property (weak, nonatomic) IBOutlet UIButton *checkBox3;
@property (weak, nonatomic) IBOutlet UIButton *checkBox4;
@property (weak, nonatomic) IBOutlet UIButton *checkBox5;

@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (nonatomic) CAPSPageMenu *pagemenu;

@property (strong, nonatomic) ValetMapViewController *mapController;
@property (strong, nonatomic) ValetListViewController *listController;

@end

@implementation ValetMainViewController

typedef enum _MAIN_STATE {
    MAIN_STATE_NONE = 0x00,
    MAIN_STATE_VALET_SELECT = 0x01,
    MAIN_STATE_VALET_WAITING = 0x02,
    MAIN_STATE_VALET_NAVIGATING = 0x03,
    MAIN_STATE_VALET_ARRIVED = 0x04,
    MAIN_STATE_PUSH_ACTION_VALET = 0x05,
    MAIN_STATE_PUSH_ACTION_STATUS_PARKED = 0x06,
    MAIN_STATE_PUSH_ACTION_STATUS_ALREADY = 0x07,
    MAIN_STATE_PUSH_ACTION_STATUS_PAYNOW = 0x08,
    MAIN_STATE_PUSH_ACTION_CHAUFFEUR = 0x09
} MAIN_STATE;

static volatile MAIN_STATE _pageWaitUserSelection = MAIN_STATE_NONE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    ////self.searchContainer.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Valet" bundle:nil];
    
    // Array to keep track of controllers in page menu
    NSMutableArray *controllerArray = [NSMutableArray array];
    
    // Create variables for all view controllers you want to put in the
    // page menu, initialize them, and add each to the controller array.
    // (Can be any UIViewController subclass)
    // Make sure the title property of all view controllers is set
    // Example:
    //UIViewController *controller = [[UIViewController alloc] initWithNibname:@"controllerNibnName" bundle:nil];
    //controller.title = @"SAMPLE TITLE";
    //[controllerArray addObject:controller];
    
    _mapController = [story instantiateViewControllerWithIdentifier:@"valetMap"];
    _mapController.title = @"검색결과";
    //mapController.backViewController = self;
    //mapController.searchDestinationArray = resultArray;
    [controllerArray addObject:self.mapController];
    _listController =[story instantiateViewControllerWithIdentifier:@"valetList"];
    _listController.title = @"최근목적지";
    //listController.backViewController = self;
    [controllerArray addObject:_listController];
    
    // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
    // Example:
    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.0),
                                 CAPSPageMenuOptionMenuHeight: @(50),
                                 CAPSPageMenuOptionSelectionIndicatorColor: UIColorFromRGB(SECOND_COLOR),
                                 CAPSPageMenuOptionViewBackgroundColor: UIColorFromRGB(BASIC_COLOR),
                                 CAPSPageMenuOptionScrollMenuBackgroundColor:UIColorFromRGB(BASIC_COLOR),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight:@(0.0)
                                 };
    
    //NSDictionary *parameters2 = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
    //                             @"useMenuLikeSegmentedControl": @(YES),
    //                             @"menuItemSeparatorPercentageHeight": @(0.1)
    //                             };
    
    // Initialize page menu with controller array, frame, and optional parameters
    _pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.pageMenuContainer.frame.size.width, self.pageMenuContainer.frame.size.height) options:parameters];
    
    // Lastly add page menu as subview of base view controller view
    // or use pageMenu controller in you view hierachy as desired
    [self.pageMenuContainer addSubview:_pagemenu.view];
    ////padding = UIEdgeInsetsMake(0, 0, 0, self.searchIcon.frame.size.width);
    // _searchTextFieldeld.rightAnchor
    
    ////////////////////////////////////////////////////////////////////////////////
    // Do any additional setup after loading the view.
    [self memberJoin];
    
    ////_secondColorBarLine.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    ////_chauffeurMovingDetailButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    ////_chauffeurWaitingDetailButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    ////payMethod = PAYMENT_TYPE_CASH;
    ////carType = CAR_TYPE_AUTO;
    _pageWaitUserSelection = MAIN_STATE_NONE;
    [self setMainView];
    [self updateMainView];
    ////self.findType = DESTINATION_TWOWAY;
    locationManager.allowsBackgroundLocationUpdates = NO;
    
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    
}

- (void)setMainView
{
    switch (_pageWaitUserSelection) {
        case MAIN_STATE_NONE:{
            [self initialState];
            break;
        }
        case MAIN_STATE_VALET_SELECT:{
            //valetListPopup
            //cluster
            //발렛선택       X
            //icon name cost
            //icon name cost
            //icon name cost
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"segueValetList" sender:self];
            });
            
            break;
        }
        case MAIN_STATE_VALET_WAITING:{
            
            
            [self requestValetInterface:_targetValetData request:YES];
            
            
            break;
        }
        case MAIN_STATE_VALET_NAVIGATING:{
            
            //네비선택창
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"segueSelectNavi" sender:self];
            });
            
            break;
        }
        case MAIN_STATE_VALET_ARRIVED:{
            
            [self checkArrivedValet];
            
            break;
        }
        case MAIN_STATE_PUSH_ACTION_VALET:{
            
            [self receiptCheck:^(valetData *data) {
                if(data){
                    [self receiptComplete:data];
                }
            }];
            
            break;
        }
        case MAIN_STATE_PUSH_ACTION_STATUS_PARKED:{
            
            [self receiptCheck:^(valetData *data) {
                if(data){
                    [self completeValetParking];
                }
            }];
            
            break;
        }
        case MAIN_STATE_PUSH_ACTION_STATUS_ALREADY:{
            
            [self receiptCheck:^(valetData *data) {
                if(data){
                    [self requestValetAgreement:data];
                }
            }];
            
            break;
        }
        case MAIN_STATE_PUSH_ACTION_STATUS_PAYNOW:{
            
            [self receiptCheck:^(valetData *data) {
                if(data.valet_value > 0){
                    [self parkingChargePayment:data];
                }else{
                    [self waitForDeliveryCar:data];
                }
            }];
            
            break;
        }
        case MAIN_STATE_PUSH_ACTION_CHAUFFEUR:{
            
            //pay완료후 실행한다고 함
            break;
        }
        default:{
            
            break;
        }
    }
    
}

- (void) updateMainView
{
    [_pagemenu moveToPage:0];
    
    //[_mapController updateMapView];
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(delegate.isVallet){
        delegate.isVallet = FALSE;
        
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:APP_NAME message:delegate.message ?: NSLocalizedString(@"connected_waiting_and_parked", nil) centerButtonText:NSLocalizedString(@"btn_ok", nil) centerButtonCallback:^{
            delegate.message = nil;
        }];
        
        _pageWaitUserSelection = MAIN_STATE_PUSH_ACTION_VALET;
        [self setMainView];
        
        
    }else if(delegate.isParked){
        delegate.isParked = FALSE;
        _pageWaitUserSelection = MAIN_STATE_PUSH_ACTION_STATUS_PARKED;
        [self setMainView];
    }else if(delegate.isAlready){
       delegate.isAlready = FALSE;
        
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:APP_NAME message:delegate.message ?: NSLocalizedString(@"last_check_car_status", nil) centerButtonText:NSLocalizedString(@"btn_ok", nil) centerButtonCallback:^{
            delegate.message = nil;
        }];
        
        _pageWaitUserSelection = MAIN_STATE_PUSH_ACTION_STATUS_ALREADY;
        [self setMainView];
        
    }else if(delegate.isValetCancel){
        delegate.isValetCancel = FALSE;
        
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:APP_NAME message:delegate.message ?: NSLocalizedString(@"connected_driver_from_cancel", nil) centerButtonText:NSLocalizedString(@"btn_ok", nil) centerButtonCallback:^{
            delegate.message = nil;
            
            _pageWaitUserSelection = MAIN_STATE_NONE;
            [self setMainView];
        }];
        
    }else if(delegate.isReady){
        delegate.isReady = FALSE;
        // 준비상태...
    }else if(delegate.isPayNow){
        delegate.isPayNow = FALSE;
        
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:APP_NAME message:delegate.message ?: [NSString stringWithFormat:NSLocalizedString(@"paynow_mesg", nil),delegate.parkingValue]  centerButtonText:NSLocalizedString(@"btn_ok", nil) centerButtonCallback:^{
            delegate.message = nil;
            
        }];
        
        // 지불안내창
        _pageWaitUserSelection = MAIN_STATE_PUSH_ACTION_STATUS_PAYNOW;
        [self setMainView];
        
    }else if(delegate.isChauffeur){
        delegate.isChauffeur = FALSE;
        // Chauffeur안내 푸시가 도착한다함...
    }else if(delegate.isValetWaiting){
        delegate.isValetWaiting = FALSE;
        
        _pageWaitUserSelection = MAIN_STATE_VALET_WAITING;
        [self receiptCheck:^(valetData *data) {
            [self requestValetInterface:data request:YES];
        }];
        
    }else if(delegate.isArrived){
        delegate.isArrived = FALSE;
        
        //추가
        if(!_targetValetData){
            [self receiptCheck:^(valetData *data) {
                [self doArrivedValet];
            }];
        }else{
            [self doArrivedValet];
        }
        
        
        [self handleDriverLocationReport:FALSE];
         
        
    }else{
        //[self receiptCheck:^(valetData *data) {
       
        //}];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = - [newLocation.timestamp timeIntervalSinceNow];
        
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
            if(!isMyLocationSet && _mapController){
                if(_routeSearchView.depature && [_routeSearchView.depature isEqualToString:@""]){
                    //[_mapView setCenterPoint:point];
                    [_mapController setDepatureLocation:point];
                }
            }
        }
    }
    
}




-(void) initialState
{
    [_mainView removeFromSuperview];
    [_valetDeliveryFinishView removeFromSuperview];
    [_completeValetParkingView removeFromSuperview];
    [_callbackValetParkingView removeFromSuperview];
    
    [self->_mainOrderGo setTitle:NSLocalizedString(@"btn_reserve",nil) forState:UIControlStateNormal];
    [self->_mainOrderClose setTitle:NSLocalizedString(@"btn_cancel",nil) forState:UIControlStateNormal];
    
    [self handleDriverLocationReport:NO];
    //(findViewById(R.id.main_map_location_share_sw)).setVisibility(View.GONE);
}





- (void) memberJoin
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:SAVEKEY_MEMBERJOIN]){
        
        NSString *phone = [[[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_PHONE_NUMBER] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *recommender = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_RECOMMEND];
        NSString *fcm = [[NetworkManager sharedInstance] fcmToken];
        
        [[NetworkManager sharedInstance] memberJoin:@"" tel:phone email:@"" address:@"" recommander:recommender order_type:MEMBER_JOIN_ORDER_TYPE_ADD fcm_token:fcm complete:^(BOOL success, responseData *data){
            if(success)
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SAVEKEY_MEMBERJOIN];
        }];
        
    }
    
}



- (void) memoActionSheet
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"main_order_memo_hint",nil) message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_0",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_0",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_1",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_1",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_2",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_2",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_3",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_3",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_4",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_4",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_5",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_5",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_6",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_6",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_7",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_7",nil);
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"main_order_memo_8",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        ///_optionSettingMemoTextField.text = NSLocalizedString(@"main_order_memo_8",nil);
        //}];
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Click event

- (IBAction)refreshClick:(id)sender {
    [self initialState];
}

//하단처음버튼
- (IBAction)phoneCallClick:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NetworkManager sharedInstance].callCenterTel ?: cscenter_phone_number]];
}
- (IBAction)callClick:(id)sender {
    /*
    if(_pageWaitUserSelection == MAIN_STATE_CARD){
        [self setMainView];
        [((AppDelegate *)[[UIApplication sharedApplication]delegate])TTS:NSLocalizedString(@"카드음성멘트", nil)];
    }else if(_pageWaitUserSelection == MAIN_STATE_CONFIRM){
        
        [self callMakeComplete];
    }else if(_pageWaitUserSelection == MAIN_STATE_OPTION_SELECT){
        payMethod = PAYMENT_TYPE_CASH;
        _pageWaitUserSelection = MAIN_STATE_CONFIRM;
        carType = CAR_TYPE_AUTO;
        [self callMakeComplete];
    }else{
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        NSString *titleMessage = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = NSLocalizedString(@"main_destnation_box_hint",nil);
        NSString *centerButtonText = NSLocalizedString(@"btn_ok",nil);
        [messageView initWithTitle:titleMessage message:message centerButtonText:centerButtonText centerButtonCallback:nil];
    }
     */
}


#pragma mark - click event valet

- (IBAction)mainParkingInfoClick:(id)sender {
    
    if (_pageWaitUserSelection == MAIN_STATE_PUSH_ACTION_STATUS_PARKED) {
        _completeValetParkingView.hidden = NO;
    }else if(_pageWaitUserSelection == MAIN_STATE_PUSH_ACTION_CHAUFFEUR){
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:APP_NAME message:NSLocalizedString(@"please_wait_delivery_car", nil) centerButtonText:NSLocalizedString(@"btn_ok", nil) centerButtonCallback:^{
            
        }];
    }else if(_pageWaitUserSelection >= MAIN_STATE_PUSH_ACTION_STATUS_ALREADY){
        // 주차완료된 상태의 차량정보를 본다.
        [self receiptCheck:^(valetData *data) {
            [self ValetDeliveryFinish];
        }];
    }
}

- (IBAction)mainParkkingCallClick:(id)sender {
    
    NSString *tel = [NSString stringWithFormat:@"telprompt://%@",_targetValetData.valet_tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
}


- (IBAction)mainOrderCloseClick:(id)sender {
    
    if (_pageWaitUserSelection == MAIN_STATE_VALET_WAITING) {
        
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithTitle:APP_NAME message:[NSString stringWithFormat:NSLocalizedString(@"connected_cancel_message",nil),_targetValetData.valetName] leftButtonText:NSLocalizedString(@"btn_yes",nil) leftButtonCallback:^{
            
            [[NetworkManager sharedInstance] valetCancel:VALET_CANCEL_ORDER_TYPE_CANCEL center_idx:self.targetValetData.valet_center complete:^(BOOL success, valetCancelData* data){
                
                if(success){
                    
                    [self setMainView];
                }
            }];
            
        } rightButtonText:NSLocalizedString(@"btn_no",nil) rightButtonCallback:^{
            
        }];
        
    }else{
        _pageWaitUserSelection = MAIN_STATE_VALET_WAITING;
        [self setMainView];
    }
    
}

- (IBAction)mainOrderCallClick:(id)sender {
    
    NSString *tel = [NSString stringWithFormat:@"telprompt://%@",_targetValetData.valet_tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
}

- (IBAction)mainOrderGoClick:(id)sender {
    
    if (_pageWaitUserSelection == MAIN_STATE_VALET_SELECT) {
        [self setMainView];
    }else{
        [self requestReserveValet:_targetValetData];
    }
    
}
- (IBAction)valetCallDriverClick:(id)sender {
    NSString *tel = [NSString stringWithFormat:@"telprompt://%@",_targetValetData.valet_tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
}
- (IBAction)valetStayWaitClick:(id)sender {
    _valetDeliveryFinishView.hidden = YES;
}

- (IBAction)callbackValetCallClick:(id)sender {
    
    [[NetworkManager sharedInstance] valetRelease:_targetValetData.valet_addr req_location:CLLocationCoordinate2DMake(_targetValetData.valet_lat.doubleValue, _targetValetData.valet_lon.doubleValue) req_release_time:10 req_memo:@"" complete:^(BOOL success, responseData *data) {
        [self requestValetAgreement:data];
    }];
    
}
- (IBAction)completeDetailClick:(id)sender {
}
#pragma mark - call


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



-(void) driverPosition
{
    [[NetworkManager sharedInstance] callDriver:^(BOOL success, callDriverData *data){
        if(success){
            ////[_mapController setDriverMarker:data.driver_lon lat:data.driver_lat title:nil];
            
            TMapPoint *point = [[TMapPoint alloc] initWithLon:[data.driver_lon doubleValue] Lat:[data.driver_lat doubleValue]];
            NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:point];
            ////[self.chauffeurMovingAreaView updateDriverPosition:address];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
}

#pragma mark - UI

- (void) buildStatusBox
{
    
}

- (void) hideBottomInfoBox
{
    
}

- (void) showValetDriverInfo
{
    
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
    if([segue.sourceViewController isKindOfClass:[DestinationViewController class]] ||
       [segue.sourceViewController isKindOfClass:[DestinationTabViewController class]] || [segue.sourceViewController isKindOfClass:[DestinationMapViewController class]] ){
        //////[self setTextFieldAndMarker];
        ////[_mapView setTMapPathIconStart:depatureMarker end:destinationMarker pass:wayPointMarker];
        if([_mapController checkPolyLineMake]){
            ////_pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
            ////[self setMainView];
            ///[self callNew];
            //[_mapView setTrackingMode:FALSE];
            //[_mapView setSightVisible:FALSE];
        }
    }else if([segue.sourceViewController isKindOfClass:[FavoriteViewController class]]){
        
        ////if(_pageWaitUserSelection >= MAIN_STATE_WAITING_DRIVER){
        ////    return;
        ////}
        
        //////[_mapController setTextFieldAndMarker];
        ////[_mapView setTMapPathIconStart:depatureMarker end:destinationMarker pass:wayPointMarker];
        if([_mapController checkPolyLineMake]){
            ////_pageWaitUserSelection = MAIN_STATE_OPTION_SELECT;
            ////[self setMainView];
        }
    }else if([segue.sourceViewController isKindOfClass:[PayingViewController class]]){
        if(!_isCardCanceled && _isCardPayed){
            
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"main_order_complete_message",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
                
                [self waitForDeliveryCar:_targetValetData];
                [self howWantUseChaffeur];
            }];
            
            
            
        }else if(!_isCardCanceled){
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"lost_response_data_card",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
            
        }
    }else if([segue.sourceViewController isKindOfClass:[ValetLastAgreeViewController class]]){
        
        if([segue.identifier isEqualToString:@"agreed"]){
            
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"payment_complete_message",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
                [self initialState];
            }];
            
        }else{
            
        }
        
    }else if([segue.sourceViewController isKindOfClass:[ValetChooseViewController class]]){
        
        [self requestValetInterface:_targetValetData request:YES];
    }
    
}


#pragma mark - push message method



//vallet//





- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
    if (state == CLRegionStateInside) {
        
        [self checkArrivedValet];
        
    }else if (state == CLRegionStateOutside) {
        
        // We are outside region
        NSLog(@"Outside region");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(nonnull CLRegion *)region
{
    if([region.identifier isEqualToString:@"valet"]){
        
    }
}

- (void) handleDriverLocationReport:(BOOL)isStart
{
    if(!locationManager){
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_targetValetData.valet_lat.doubleValue, _targetValetData.valet_lon.doubleValue);
    
    //CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    CLLocationDistance maxDistance = locationManager.maximumRegionMonitoringDistance;
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coord radius:maxDistance identifier:@"valet"];
    region.notifyOnExit = FALSE;
    region.notifyOnEntry = TRUE;
    
    if(isStart){
        
        if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways){
            
            [locationManager startMonitoringForRegion:region];
        }
        
        NSTimeInterval interval = 60.0;
        dispatch_async(dispatch_get_main_queue(), ^{
            self->positionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateUserLocation) userInfo:nil repeats:YES];
        });
        
    }else{
        
        //CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        [locationManager stopMonitoringForRegion:region];
        
        [positionTimer invalidate];
        positionTimer = nil;
    }
}

- (void) updateUserLocation
{
    /*
    [[NetworkManager sharedInstance] valetUserLocation:(CLLocationCoordinate2D) driverCenterLocation:(CLLocationCoordinate2D) centerId:(NSString *) distance:(NSInteger) complete:^(BOOL, responseData *) {
        
    }];
     */
    
    
    [[NetworkManager sharedInstance] callDriver:^(BOOL success, callDriverData *data){
        if(success){
            ////[_mapController setDriverMarker:data.driver_lon lat:data.driver_lat title:nil];
            
            TMapPoint *point = [[TMapPoint alloc] initWithLon:[data.driver_lon doubleValue] Lat:[data.driver_lat doubleValue]];
            NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:point];
            ////[self.chauffeurMovingAreaView updateDriverPosition:address];
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
    
}

- (void)checkArrivedValet
{
    //내차맞기기버튼사라지고 전화걸기버튼이 커짐
    
    // We entered a region
    NSLog(@"Inside region");
    
    NSString *destination;
    if(!_targetValetData){
        destination = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_DESTINATION_NAME] ?: @"목적지";
        
    }else{
        destination = _targetValetData.valetName;
    }
    
    if (!destination) {
        
        double lat;
        double lon;
        if([NetworkManager sharedInstance].myLatitude > 0 && [NetworkManager sharedInstance].myLongitude > 0){
            lat = [NetworkManager sharedInstance].myLatitude;
            lon = [NetworkManager sharedInstance].myLongitude;
        }else if([[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LAT] > 0 && [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LON]){
            lat = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LAT];
            lon = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LON];
        }
        
        TMapPoint *point = [[TMapPoint alloc] initWithLon:lon Lat:lat];
        destination = [[[TMapPathData alloc] init] convertGpsToAddressAt:point];
    }
    
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground){
        
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"arrived_message",nil),destination];
        notification.soundName = @"Default";
        notification.userInfo = [NSDictionary dictionaryWithObject:@"onArrived" forKey:@"valet"];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        
    }else{
        
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithNoticeMessage:[NSString stringWithFormat:NSLocalizedString(@"arrived_message",nil),destination] centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
            
            [self doArrivedValet];
            
        }];
    }
    
}

//onResume
-(void)receiptCheck:(void(^)(valetData *data))callback;
{
    [[NetworkManager sharedInstance]valetDriverInfo:^(BOOL success, valetData *data){
        if(success){
            
            ////////
            //self.targetValetData = data;
            ////////
            
            callback(data);
            
        }else{
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                
            }];
        }
    }];
}


- (void)receiptComplete:(valetData *)data
{
    //접수완료
    //배정 정보 상태메세지뷰
    //전화, 취소등
}

- (void)completeValetParking
{
    //주차완료 및 내차호출하기 뷰
    
    //내차호출시 ValetReleaseTask
}

- (void)requestValetAgreement:(valetData *)data
{
    //ValetReleaseTask 성공후
    
    //차량 번호 및 차량인수동의 뷰
    
    //동의하면 초기화한것같음
}

- (void)parkingChargePayment:(valetData *)data
{
    //현금,현장결제 , 결제요청
    
    
}

- (void)waitForDeliveryCar:(valetData *)data
{
    //출차진행
    
    //대리운전앱이용안내 "wawawachauffeur://gorouting?slat="+slat+"&slon="+slon+"&elat="+elat+"&elon="+elon
}

- (void)orderValetDriverInfo:(valetData *)valetData
{
    //VALET_CANCEL_ORDER_TYPE_ORDER 후 네비게이터버튼표시
    [[NetworkManager sharedInstance] valetCancel:VALET_CANCEL_ORDER_TYPE_ORDER center_idx:valetData.valet_center complete:^(BOOL success, valetCancelData* data){
        
        if(success){
            
            //valetData.setResponseId(response.getResponseId());
            //showNavigatorButton(valetData, myData);
            [self->_mainOrderGo setTitle:NSLocalizedString(@"btn_go",nil) forState:UIControlStateNormal];
            [self->_mainOrderClose setTitle:NSLocalizedString(@"btn_reserved_cancel",nil) forState:UIControlStateNormal];
            
            //(findViewById(R.id.main_map_location_share_sw)).setVisibility(View.VISIBLE);
            _pageWaitUserSelection = MAIN_STATE_VALET_WAITING;
        }else{
            
        }
    }];
}

//start
- (void)requestValetInterface:(valetData *)data request:(BOOL)isRequest;
{
    //발렛목록선택시 들어오는
    
    self.targetValetData = data;
    [NetworkManager sharedInstance].destinatiion = data.valetName;
}

- (void)requestReserveValet:(valetData *)data
{
    //발렛 예약하기
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    [messageView initWithTitle:APP_NAME message:[NSString stringWithFormat:NSLocalizedString(@"request_reserve",nil),data.valetName] leftButtonText:NSLocalizedString(@"btn_reserve",nil) leftButtonCallback:^{
        
        [self orderValetDriverInfo:data];
        
        [self handleDriverLocationReport:TRUE];
        
        
    } rightButtonText:NSLocalizedString(@"btn_cancel",nil) rightButtonCallback:^{
        
    }];
}
    
- (void) doArrivedValet
{
    [[NetworkManager sharedInstance] valetCancel:VALET_CANCEL_ORDER_TYPE_ARRVIED center_idx:self.targetValetData.valet_center complete:^(BOOL success, valetCancelData* data){
        
        // 센터에 도착하면 기사에게 푸시만 발송하고, UI작업은 없다!
    }];
}
    
- (void) popupNavigatorList
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueSelectNavi" sender:self];
    });
}
    

- (void) goSearch
{
    double myLat = [NetworkManager sharedInstance].myLatitude;
    double myLon = [NetworkManager sharedInstance].myLongitude;
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(myLat, myLon);
    
    [[NetworkManager sharedInstance] valetList:coord request_range:_searchRangeMeter complete:^(BOOL success, valetListData* data){
        if(success){
            
            [self->_mapController updateMapView:data];
            [self->_listController updateListView:data];
            
        }else{
            
        }
    }];
    
}
    
    
    
//onActivityResult

//RESULT_COMPLETE_VALET
- (void)ValetDeliveryFinish
{
    //출차진행중
}
//RESULT_PAYMENT_RESULT
- (void)howWantUseChaffeur
{
    //결제후
    
    double myLat = [NetworkManager sharedInstance].myLatitude;
    double myLon = [NetworkManager sharedInstance].myLongitude;
    
    double targetLat = self.targetValetData.valet_lat.doubleValue;
    double targetLon = self.targetValetData.valet_lon.doubleValue;
    
    // check whether facebook is (likely to be) installed or not
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wawawachauffeur://"]]) {
        // Safe to launch the facebook app
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"wawawachaffeur://gorouting?slat=%f&slon=%f&elat=%f&elon=%f",myLat,myLon,targetLat,targetLon]]];
        
        
    }else{
        [self runChaffeur];
    }
}

//RESULT_CHAUFFEUR_INSTALL
- (void)runChaffeur
{
    //대리앱실행
    
    NSString *iTunesLink = @"itms-apps://itunes.apple.com/app/id1434687876";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}





//not use
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
