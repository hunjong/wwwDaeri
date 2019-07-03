//
//  NavigationController.h
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 26..
//  Copyright © 2017년 m4nc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "responseData.h"

@class IndicatorView;

@interface NavigationController : UINavigationController

- (void) clearViewControllers;

- (void) startIndicator:(UIView*)parentView withMessage:(BOOL)withMessage;
- (void) stopIndicator;

@end
