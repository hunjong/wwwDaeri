//
//  DriverMovingView.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 9. 26..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DriverMovingView : UIView

@property (weak, nonatomic) IBOutlet UILabel *routeInfoTopLabel2;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoTopLabel3;
@property (weak, nonatomic) IBOutlet UIView *routeInfoTopView3;
@property (weak, nonatomic) IBOutlet UIView *routeInfoTopView2;

@property (weak, nonatomic) IBOutlet UIButton *appFinishButton;
@property (weak, nonatomic) IBOutlet UILabel *horizontalLine;
@property (weak, nonatomic) IBOutlet UILabel *verticalLine;

@property (weak, nonatomic) IBOutlet UILabel *routeInfoDriverLabel3;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoDepatureLabel3;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoWayPointLabel3;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoDestinationLabel3;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoDriverLabel2;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoDepatureLabel2;
@property (weak, nonatomic) IBOutlet UILabel *routeInfoDestinationLabel2;
@property (weak, nonatomic) IBOutlet UIView *routeInfoView2;
@property (weak, nonatomic) IBOutlet UIView *routeInfoView3;

@property (weak, nonatomic) IBOutlet UILabel *driverMovingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *driverMovingImageView;
@property (weak, nonatomic) IBOutlet UILabel *driverMovingInsuranceLabel;

@property (readwrite) BOOL isWayPointExist;
- (void)setRouteInfoWithDriver:(NSString *)driver depature:(NSString *)depature wayPoint:(NSString *)wayPoint destination:(NSString *)destination cost:(NSInteger)cost;
-(void) updateDriverPosition:(NSString *)driver;
- (void) setDriverInfoWithDriverName:(NSString *)name insurance:(NSString *)insurance photo:(NSString *)photo;

@end

NS_ASSUME_NONNULL_END
