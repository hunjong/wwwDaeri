//
//  DriverWaitingView.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 9. 26..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DriverWaitingView : UIView


@property (weak, nonatomic) IBOutlet UIView *registrationTopView2;
@property (weak, nonatomic) IBOutlet UIView *registrationTopView3;
@property (weak, nonatomic) IBOutlet UIView *registrationView2;
@property (weak, nonatomic) IBOutlet UIView *registrationView3;
@property (weak, nonatomic) IBOutlet UIButton *registrationCancelButton;

@property (weak, nonatomic) IBOutlet UILabel *basicColorBarLine;

@property (weak, nonatomic) IBOutlet UILabel *waitNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *depatureLabel3;
@property (weak, nonatomic) IBOutlet UILabel *wayPointLabel3;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel3;
@property (weak, nonatomic) IBOutlet UILabel *depatureLabel2;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel2;
@property (readwrite) BOOL isWayPointExist;

- (void) setDriverWaitingViewWithCost:(NSInteger)cost depature:(NSString *)depature wayPoint:(NSString *)wayPoint destination:(NSString *)destination;
@end

NS_ASSUME_NONNULL_END
