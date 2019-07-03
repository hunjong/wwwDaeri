//
//  RouteSearchView.h
//  GoodDaeri
//
//  Created by hunjong choi on 06/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RouteSearchDelegate <NSObject>

- (void)depatureShoudClear:(UITextField *)textField;
- (void)destinationShoudClear:(UITextField *)textField;
- (void)waypointShoudClear:(UITextField *)textField;
- (void)depatureTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)destinationTextFieldShouldBeginEditing:(UITextField *)textField;
- (void)waypointTextFieldShouldBeginEditing:(UITextField *)textField;
@end

@interface RouteSearchView : UIView <UITextFieldDelegate>
{
    NSString *destination;
    NSString *depature;
    NSString *wayPoint;
}

@property (nonatomic, assign) id<RouteSearchDelegate> delegate;

@property (nonatomic) BOOL completeRouteSearch;

@property (weak, nonatomic) IBOutlet UIView *twoWay;
@property (weak, nonatomic) IBOutlet UITextField *twoWayDepatureTextField;
@property (weak, nonatomic) IBOutlet UITextField *twoWayDestinationTextField;
@property (weak, nonatomic) IBOutlet UIView *threeWay;
@property (weak, nonatomic) IBOutlet UITextField *threeWayDepatureTextField;
@property (weak, nonatomic) IBOutlet UITextField *threeWayPointTextField;
@property (weak, nonatomic) IBOutlet UITextField *threeWayDestinationTextField;
@property (weak, nonatomic) IBOutlet UIButton *addWayPointButton;

- (NSString *)destination;
- (NSString *)depature;
- (NSString *)wayPoint;

- (void) reset;
- (void) setDestination:(NSString *)dest;
- (void) setDeparture:(NSString *)depart;
- (void) setWayPoint:(NSString *)way;
- (CGFloat) getVisibleHeight;
@end

NS_ASSUME_NONNULL_END
