//
//  ValetMainViewController.h
//  GoodValet
//
//  Created by hunjong choi on 07/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAPSPageMenu.h"
#import "DestinationDBData.h"
#import "DestinationViewController.h"
#import "DriverWaitingView.h"
#import "DriverMovingView.h"
#import "RouteSearchView.h"
#import "responseData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ValetMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;


@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *mainAddressBox;
@property (weak, nonatomic) IBOutlet UILabel *mainAddressMy;
@property (weak, nonatomic) IBOutlet UILabel *mainAddressValet;
@property (weak, nonatomic) IBOutlet UILabel *mainValetValue;
@property (weak, nonatomic) IBOutlet UILabel *mainValetDistance;
@property (weak, nonatomic) IBOutlet UILabel *mainValetInsure;
@property (weak, nonatomic) IBOutlet UIButton *mainOrderClose;
@property (weak, nonatomic) IBOutlet UIButton *mainOrderCall;
@property (weak, nonatomic) IBOutlet UIButton *mainOrderGo;
@property (weak, nonatomic) IBOutlet UIView *mainOrderCommandBox;
@property (weak, nonatomic) IBOutlet UIView *mainParkingCommandBox;
@property (weak, nonatomic) IBOutlet UIButton *mainParkingInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *mainParkingCallBtn;


@property (strong, nonatomic) IBOutlet UIView *valetDeliveryFinishView;
@property (weak, nonatomic) IBOutlet UILabel *valetDeliveryTitle;
@property (weak, nonatomic) IBOutlet UIButton *valetDeliveryCloseBtn;
@property (weak, nonatomic) IBOutlet UILabel *waitPaymentMeAddr;
@property (weak, nonatomic) IBOutlet UILabel *waitPaymentDriverAddr;
@property (weak, nonatomic) IBOutlet UIButton *valetCallDriverBtn;
@property (weak, nonatomic) IBOutlet UIButton *valetStayWaitBtn;


@property (strong, nonatomic) IBOutlet UIView *callbackValetParkingView;
@property (weak, nonatomic) IBOutlet UILabel *callbackValetTitle;
@property (weak, nonatomic) IBOutlet UIButton *callbackValetCloseBtn;
@property (weak, nonatomic) IBOutlet UILabel *callbackValetMeAddress;
@property (weak, nonatomic) IBOutlet UILabel *callbackValetTime;
@property (weak, nonatomic) IBOutlet UILabel *callbackValetMemoAddress;
@property (weak, nonatomic) IBOutlet UIButton *callbackValetCallBtn;


@property (strong, nonatomic) IBOutlet UIView *completeValetParkingView;
@property (weak, nonatomic) IBOutlet UILabel *completeValetTitle;
@property (weak, nonatomic) IBOutlet UIButton *completeValetCloseBtn;
@property (weak, nonatomic) IBOutlet UILabel *completeValetMeAddress;
@property (weak, nonatomic) IBOutlet UILabel *completeValetDriverAddress;
@property (weak, nonatomic) IBOutlet UICollectionView *completeValetPhotoBox;
@property (weak, nonatomic) IBOutlet UILabel *completeValetCarInfoMessage;

@property (strong, nonatomic) IBOutlet UIView *completeDetailView;
@property (weak, nonatomic) IBOutlet UILabel *completeDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *completeDetailImage;




@property (readwrite,nonatomic) BOOL isCardPayed;
@property (readwrite,nonatomic) BOOL isCardCanceled;
@property (readwrite,nonatomic) BOOL isCallCancelledInDriverMoving;
@property (readwrite,nonatomic) BOOL withComplain;

@property (readwrite,nonatomic) valetData *targetValetData;
@property (readwrite,nonatomic) NSInteger searchRangeMeter;

@property (readwrite,nonatomic) UIView *pageMenuContainer;
@property (retain, nonatomic) RouteSearchView *routeSearchView;
@property (readwrite,nonatomic) BOOL isCallCancelledInCarDispatch;

-(void)actionAccecpt;
-(void)actionCancel;
-(void)actionDone;
-(void)callInfoWithUpdate:(BOOL)isUpdate;
-(void)actionAccecptWithUpdate:(BOOL)isUpdate;

- (void)updateMainView;
//vallet
-(void)actionStatusParked;
-(void)actionStatusReady;
-(void)actionPaynow:(NSInteger)cost;
@end

NS_ASSUME_NONNULL_END
