//
//  ReachablityView.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 25..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "ReachablityView.h"

@implementation ReachablityView
{
    SimpleCallback refeshCallback;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)exitClick:(id)sender {
    exit(0);
}
- (IBAction)refreshClick:(id)sender {
    if(refeshCallback != nil){
        refeshCallback();
    }
}

- (void) setRefreshCallback:(SimpleCallback) callback
{
    refeshCallback = callback;
}


@end
