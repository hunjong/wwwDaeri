//
//  DestinationMapViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 8. 19..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationViewController.h"

@interface DestinationMapViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *centerIcon;
@property (weak, nonatomic) NSString *iconImageName;
@property (weak, nonatomic) DestinationViewController *backViewController;
@end
