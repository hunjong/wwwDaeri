//
//  DriverMovingView.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 9. 26..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import "DriverMovingView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation DriverMovingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void) setColor
{
    _routeInfoTopView3.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    _routeInfoTopView2.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    _appFinishButton.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    _horizontalLine.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    _verticalLine.backgroundColor = UIColorFromRGB(SECOND_COLOR);
}

- (void)setRouteInfoWithDriver:(NSString *)driver depature:(NSString *)depature wayPoint:(NSString *)wayPoint destination:(NSString *)destination cost:(NSInteger)cost
{
    [self setColor];
    NSString *baecha = [NSString stringWithFormat:@"%@ (%d,%@%@)",NSLocalizedString(@"connected_driver_title", nil),cost/1000,@"000",koreaMoney];
    
    
    if(!wayPoint || [wayPoint isEqualToString:@""]){
        _isWayPointExist = FALSE;
    }else{
        _isWayPointExist = TRUE;
    }
    
    if(!_isWayPointExist){
        _routeInfoView3.hidden = YES;
        _routeInfoView2.hidden = NO;
        _routeInfoDriverLabel2.text = driver;
        _routeInfoDepatureLabel2.text = depature;
        _routeInfoDestinationLabel2.text = destination;
        _routeInfoTopLabel2.text = baecha;
    }else{
        _routeInfoView3.hidden = NO;
        _routeInfoView2.hidden = YES;
        _routeInfoDriverLabel3.text = driver;
        _routeInfoDepatureLabel3.text = depature;
        _routeInfoWayPointLabel3.text = wayPoint;
        _routeInfoDestinationLabel3.text = destination;
        _routeInfoTopLabel3.text = baecha;
    }
}

-(void) updateDriverPosition:(NSString *)driver
{
    if(!_isWayPointExist){
        _routeInfoDriverLabel2.text = driver;
    }else{
        _routeInfoDriverLabel3.text = driver;
    }
}

- (void) setDriverInfoWithDriverName:(NSString *)name insurance:(NSString *)insurance photo:(NSString *)photo
{
    _driverMovingLabel.text = [NSString stringWithFormat:NSLocalizedString(@"connected_driver_message", nil),name];
    
    _driverMovingInsuranceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"connected_driver_insure", nil),insurance];
    
    [self.driverMovingImageView cancelImageDownloadTask];
    
    // Set up a NSURL for the image you want.
    NSURL *imageURL = [NSURL URLWithString:photo];
    
    // Check if the URL is valid
    if ( imageURL ) {
        // The URL is valid so we'll use it to load the image asynchronously.
        // Pass the placeholder image that will be shown while the
        // remote image loads.
        [self.driverMovingImageView setImageWithURL:imageURL
                                       placeholderImage:nil];
    }
    else {
        // The imageURL is invalid, just show the placeholder image.
        dispatch_async(dispatch_get_main_queue(), ^{
            self.driverMovingImageView.image = [UIImage imageNamed:@"picture"];
        });
        
    }
}

@end
