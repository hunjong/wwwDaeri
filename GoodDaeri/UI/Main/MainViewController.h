//
//  MainViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationDBData.h"
#import "DestinationViewController.h"
#import "DriverWaitingView.h"
#import "DriverMovingView.h"
#import "RouteSearchView.h"

@interface MainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UIView *mapAreaView;
@property (weak, nonatomic) IBOutlet UIButton *phoneCallButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *onlyCallButton;
@property (weak, nonatomic) IBOutlet UIView *bottomButtonAreaView;
@property (weak, nonatomic) IBOutlet UIView *guideViewArea;
@property (weak, nonatomic) IBOutlet UILabel *guideViewLabel;
/*
@property (weak, nonatomic) IBOutlet UIView *routeViewArea;
@property (weak, nonatomic) IBOutlet UIView *twoStepRouteView;
@property (weak, nonatomic) IBOutlet UIView *threeStepRouteView;
@property (weak, nonatomic) IBOutlet UITextField *twoStepDepatureTextField;
@property (weak, nonatomic) IBOutlet UITextField *twoStepDestinationTextField;
@property (weak, nonatomic) IBOutlet UIImageView *twoStepDepatureSearchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *twoStepSearchImageView;
@property (weak, nonatomic) IBOutlet UIButton *waypointButton;
@property (weak, nonatomic) IBOutlet UILabel *waypointLabel;
@property (weak, nonatomic) IBOutlet UIImageView *waypointPlusImageView;
@property (weak, nonatomic) IBOutlet UITextField *threeStepDepatureTextField;
@property (weak, nonatomic) IBOutlet UITextField *threeStepWaypointTextField;
@property (weak, nonatomic) IBOutlet UITextField *threeStepDestinationTextField;
@property (weak, nonatomic) IBOutlet UIImageView *threeStepDepatureSearchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *threeStepWaypointSearchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *threeStepDestinationSearchImageView;
 */
@property (weak, nonatomic) IBOutlet UIView *optionSettingAreaView;
@property (weak, nonatomic) IBOutlet UILabel *optionSettingCostLabel;
@property (weak, nonatomic) IBOutlet UIButton *optionSettingMinusButton;
@property (weak, nonatomic) IBOutlet UIButton *optionSettingPlusButton;
@property (weak, nonatomic) IBOutlet UILabel *optionSettingDistanceLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *optionSettingSegmented;
@property (weak, nonatomic) IBOutlet UISegmentedControl *opntionTransmisionSegmented;
@property (weak, nonatomic) IBOutlet UIImageView *optionSettingMileageImageView;
@property (weak, nonatomic) IBOutlet UIButton *optionSettingMileageButton;
@property (weak, nonatomic) IBOutlet UIImageView *optionSettingMemoImageView;
@property (weak, nonatomic) IBOutlet UIButton *optionSettingMemoButton;
@property (weak, nonatomic) IBOutlet UITextField *optionSettingMemoTextField;
@property (weak, nonatomic) IBOutlet UIView *chauffeurWaitingDetailView;
@property (weak, nonatomic) IBOutlet UIView *chauffeurMovingDetailView;
@property (weak, nonatomic) IBOutlet UIButton *chauffeurWaitingDetailButton;
@property (weak, nonatomic) IBOutlet UIButton *chauffeurMovingDetailButton;
@property (weak, nonatomic) IBOutlet DriverMovingView *chauffeurMovingAreaView;
@property (weak, nonatomic) IBOutlet UIButton *chaufeurMovingCallCenterButton;
@property (weak, nonatomic) IBOutlet UIButton *chaufuerMovingFinishButton;
@property (weak, nonatomic) IBOutlet UIView *confirmationAreaView;
@property (weak, nonatomic) IBOutlet UILabel *confirmationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmationTitleLine;
@property (weak, nonatomic) IBOutlet UILabel *confirmationSavePointTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmationSavePointLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmationAvailablePointTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmationAvailablePointLabel;
@property (weak, nonatomic) IBOutlet UILabel *confirmationNowPointLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmationLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmationRightButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmationCenterButton;
@property (weak, nonatomic) IBOutlet UILabel *confirmationButtonLine;
@property (weak, nonatomic) IBOutlet UILabel *secondColorBarLine;
@property (weak, nonatomic) IBOutlet DriverWaitingView *waitingView;

@property (readwrite,nonatomic) DestinationDBData *findData;
@property (readwrite,nonatomic) FIND_DESTINATION_TYPE findType;
@property (readwrite,nonatomic) BOOL isCardPayed;
@property (readwrite,nonatomic) BOOL isCardCanceled;
@property (readwrite,nonatomic) BOOL isCallCancelledInCarDispatch;
@property (readwrite,nonatomic) BOOL withComplain;
@property (retain, nonatomic) RouteSearchView *routeSearchView;

-(void)actionAccecpt;
-(void)actionCancel;
-(void)actionDone;
-(void)callInfoWithUpdate:(BOOL)isUpdate;
-(void)actionCallAccecptedWithUpdate:(BOOL)isUpdate;
- (void)updateMainView;

//vallet
-(void)actionStatusParked;
-(void)actionStatusReady;
-(void)actionPaynow:(NSInteger)cost;




@end
