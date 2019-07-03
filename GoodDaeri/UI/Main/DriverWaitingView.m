//
//  DriverWaitingView.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 9. 26..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import "DriverWaitingView.h"

@implementation DriverWaitingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) setDriverWaitingViewWithCost:(NSInteger)cost depature:(NSString *)depature wayPoint:(NSString *)wayPoint destination:(NSString *)destination
{
    _registrationTopView2.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _registrationTopView3.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _basicColorBarLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _registrationCancelButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    if(!wayPoint || [wayPoint isEqualToString:@""]){
        _isWayPointExist = FALSE;
    }else{
        _isWayPointExist = TRUE;
    }
    
    if(!_isWayPointExist){
        _registrationView2.hidden = NO;
        _registrationView3.hidden = YES;
    }else{
        _registrationView2.hidden = YES;
        _registrationView3.hidden = NO;
        _wayPointLabel3.text = wayPoint;
    }
    _depatureLabel2.text = depature;
    _depatureLabel3.text = depature;
    _destinationLabel2.text = destination;
    _destinationLabel3.text = destination;
    _waitNumberLabel.text = [NSString stringWithFormat:@"%d,%@ %@",cost/1000,@"000",koreaMoney];
}


@end
