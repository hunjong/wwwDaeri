//
//  RouteSearchView.m
//  GoodDaeri
//
//  Created by hunjong choi on 06/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import "RouteSearchView.h"

@implementation RouteSearchView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self customInit];
    }
    
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self customInit];
    }
    
    return self;
}

-(void)customInit
{
    //UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"RouteSearchView" owner:self options:nil] firstObject];
    //view.frame = self.bounds;
    //[self addSubview:view];
    [self reset];
}


- (void) reset
{
    _twoWay.hidden = NO;
    _threeWay.hidden = YES;
    _twoWayDepatureTextField.text = @"";
    _threeWayDepatureTextField.text = @"";
    _twoWayDestinationTextField.text = @"";
    _threeWayDestinationTextField.text = @"";
    _threeWayPointTextField.text = @"";
    destination = @"";
    depature = @"";
    wayPoint = @"";
    _completeRouteSearch = FALSE;
}

- (NSString *)destination
{
    return destination;
}
- (NSString *)depature
{
    return depature;
}
- (NSString *)wayPoint
{
    return wayPoint;
}


- (void) setDestination:(NSString *)dest
{
    _twoWayDestinationTextField.text = dest ?: @"";
    _threeWayDestinationTextField.text = dest ?: @"";
    destination = dest ?: @"";
}

- (void) setDeparture:(NSString *)depart
{
    _twoWayDepatureTextField.text = depart ?: @"";
    _threeWayDepatureTextField.text = depart ?: @"";
    depature = depart ?: @"";
}

- (void) setWayPoint:(NSString *)way
{
    _threeWayPointTextField.text = way ?: @"";
    wayPoint = way ?: @"";
    if(wayPoint && ![wayPoint isEqualToString:@""]){
        _twoWay.hidden = YES;
        _threeWay.hidden = NO;
    }else{
        _twoWay.hidden = NO;
        _threeWay.hidden = YES;
    }
    
}

- (CGFloat) getVisibleHeight
{
    _completeRouteSearch = TRUE;
    CGFloat result;
    if(wayPoint && ![wayPoint isEqualToString:@""]){
        result = 8 +_threeWay.frame.size.height+8;
    }else{
        result = 8 +_twoWay.frame.size.height+8;
    }
    return result;
}

#pragma mark - textField
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField == _twoWayDepatureTextField || textField == _threeWayDepatureTextField){
        [_delegate depatureShoudClear:textField];
    }else if(textField == _twoWayDestinationTextField || textField == _threeWayDestinationTextField){
        [_delegate destinationShoudClear:textField];
    }else if(textField == _threeWayPointTextField){
        [_delegate waypointShoudClear:textField];
    }
    return TRUE;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField == _twoWayDepatureTextField || textField == _threeWayDepatureTextField){
        [_delegate depatureTextFieldShouldBeginEditing:textField];
    }else if(textField == _twoWayDestinationTextField || textField == _threeWayDestinationTextField){
        [_delegate destinationTextFieldShouldBeginEditing:textField];
    }else if(textField == _threeWayPointTextField){
        [_delegate waypointTextFieldShouldBeginEditing:textField];
    }
    return FALSE;  // Hide both keyboard and blinking cursor.
}

- (IBAction)addWaypointClick:(id)sender {
    if(_completeRouteSearch) return;
    _twoWay.hidden = YES;
    _threeWay.hidden = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
