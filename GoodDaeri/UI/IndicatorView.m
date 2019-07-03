//
//  IndicatorView.m
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 26..
//  Copyright © 2017년 m4nc. All rights reserved.
//

#import "IndicatorView.h"

@interface IndicatorView ()

@end

@implementation IndicatorView

- (void) showMessage:(BOOL)show
{
    [_uilMessage setHidden:!show];
}

@end
