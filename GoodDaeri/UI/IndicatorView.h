//
//  IndicatorView.h
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 26..
//  Copyright © 2017년 m4nc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndicatorView : UIView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uiaiIndicator;

@property (weak, nonatomic) IBOutlet UILabel *uilMessage;

@end
