//
//  CommonMessageView.m
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 4..
//  Copyright © 2017년 m4nc. All rights reserved.
//

#import "CommonMessageView.h"

@interface CommonMessageView ()
{
    SimpleCallback leftButtonCallback;
    SimpleCallback rightButtonCallback;
    SimpleCallback centerButtonCallback;
}

@property (weak, nonatomic) IBOutlet UIView *dimView;

@property (weak, nonatomic) IBOutlet UIView *uivContainerView;

@property (weak, nonatomic) IBOutlet UILabel *topCenterTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *topMainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *topSubTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomNormalLabel;
@property (weak, nonatomic) IBOutlet UILabel *normalLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *centerButton;

@property (weak, nonatomic) IBOutlet UILabel *topLine;
@property (weak, nonatomic) IBOutlet UILabel *leftButtonLine;
@end

@implementation CommonMessageView

NSMutableArray *stack;

+ (CommonMessageView*) createView:(UIView*)target
{
    
    return [CommonMessageView createView:target clearExist:NO];
}

+ (CommonMessageView*) createView:(UIView*)target clearExist:(BOOL)clearExist
{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"CommonMessageView" owner:nil options:nil];
    CommonMessageView *messageView = [subviewArray lastObject];
    //[messageView setFrame:target.frame];
    messageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [messageView initialize];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:messageView];
    return messageView;
}

+ (CommonMessageView*) createView2:(UIView*)target clearExist:(BOOL)clearExist
{
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"CommonMessageView" owner:nil options:nil];
    CommonMessageView *messageView = [subviewArray lastObject];
    [messageView setFrame:target.frame];

    [messageView initialize];
    
    // 1. target의 subview에 이미 있는지 체크
    NSIndexSet *indexSet = [target.subviews indexesOfObjectsPassingTest:^BOOL(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        return [obj isKindOfClass:[CommonMessageView class]];
    }];
    
    if (indexSet.firstIndex != NSNotFound)
    {
        if (clearExist)
        {
            // 2-1. 기존의 동일 종류 뷰를 다 제거
            if (stack != nil)
                [stack removeAllObjects];
            
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop)
            {
                UIView *uiview = [target.subviews objectAtIndex:idx];
                [uiview removeFromSuperview];
            }];
        }
        else
        {
            // 2-2. stack에 쌓고 숨김
            [messageView setHidden:YES];
            
            if (stack == nil)
                stack = [NSMutableArray array];
            
            [stack addObject:messageView];
        }
        
        
    }
    
    [target addSubview:messageView];
 
    return messageView;
}

+ (CommonMessageView*) createDebugPopup:(NSString*)message target:(UIView*)target
{
    CommonMessageView *messageView = [CommonMessageView createView:target];
    
    NSString *buttonText = NSLocalizedString(@"확인", nil);
    
    [messageView initWithMessage:message centerButtonText:buttonText centerButtonCallback:nil];
    
    return messageView;
}

- (void) initialize
{
    [_dimView setHidden:NO];
    
    [_topCenterTitleLabel setHidden:YES];
    [_topMainTitleLabel setHidden:YES];
    [_topSubTitleLabel setHidden:YES];
    
    [_normalLabel setHidden:YES];
    
    [_bottomNormalLabel setHidden:YES];
    
    [_leftButton setHidden:YES];
    [_rightButton setHidden:YES];
    [_centerButton setHidden:YES];
    
    leftButtonCallback = nil;
    rightButtonCallback = nil;
    centerButtonCallback = nil;
    
    [self setTag:0];
    
    // 뷰 세팅
    _topLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _leftButtonLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _rightButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _centerButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    _topMainTitleLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    _topSubTitleLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    _normalLabel.textColor = UIColorFromRGB(BASIC_COLOR);
}

- (void) showAnimation
{
    _uivContainerView.layer.shouldRasterize = YES;
    _uivContainerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.dimView.layer.shouldRasterize = YES;
    self.dimView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.dimView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    _uivContainerView.layer.opacity = 0.5f;
    _uivContainerView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.dimView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         self.uivContainerView.layer.opacity = 1.0f;
                         self.uivContainerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];

}

-(void) initWithMessage:(NSString*)message centerButtonText:(NSString*)centerButtonText centerButtonCallback:(SimpleCallback)centerCallback
{
    [_normalLabel setHidden:NO];
    [_normalLabel setText:message];
    
    [_centerButton setHidden:NO];
    [_centerButton setTitle:centerButtonText forState:UIControlStateNormal];
    
    centerButtonCallback = centerCallback;
    [self showAnimation];
}

-(void) initWithNoticeMessage:(NSString*)message centerButtonText:(NSString*)centerButtonText centerButtonCallback:(SimpleCallback)centerCallback
{
    [_topMainTitleLabel setHidden:NO];
    [_topMainTitleLabel setText:NSLocalizedString(@"dialog_notify_title",nil)];
    
    [_normalLabel setHidden:NO];
    [_normalLabel setText:message];
    
    [_centerButton setHidden:NO];
    [_centerButton setTitle:centerButtonText forState:UIControlStateNormal];
    
    centerButtonCallback = centerCallback;
    [self showAnimation];
}

-(void) initWithTitle:(NSString*)title message:(NSString *)message centerButtonText:(NSString*)centerButtonText centerButtonCallback:(SimpleCallback)centerCallback
{
    //[_topCenterTitleLabel setHidden:NO];
    //[_topCenterTitleLabel setText:title];
    [_topMainTitleLabel setHidden:NO];
    [_topMainTitleLabel setText:title];
    [_normalLabel setHidden:NO];
    [_normalLabel setText:message];
    
    [_centerButton setHidden:NO];
    [_centerButton setTitle:centerButtonText forState:UIControlStateNormal];
    
    centerButtonCallback = centerCallback;
    [self showAnimation];
}

-(void) initWithTitle:(NSString*)title message:(NSString*)message leftButtonText:(NSString*)leftButtonText leftButtonCallback:(SimpleCallback)leftCallback rightButtonText:(NSString*)rightButtonText rightButtonCallback:(SimpleCallback)rightCallback
{
    //[_topCenterTitleLabel setHidden:NO];
    //[_topCenterTitleLabel setText:title];
    
    //[_bottomNormalLabel setHidden:NO];
    //[_bottomNormalLabel setText:message];
    
    [_topMainTitleLabel setHidden:NO];
    [_topMainTitleLabel setText:title];
    //[_topMainTitleLabel sizeToFit];
    //CGRect rect1 = _topMainTitleLabel.superview.frame;
    //CGRect rect2 = _topMainTitleLabel.frame;
    //rect2.origin.y = 0;
    //[_topMainTitleLabel setFrame:rect2];
    
    [_normalLabel setHidden:NO];
    [_normalLabel setText:message];
    
    [_leftButton setHidden:NO];
    [_leftButton setTitle:leftButtonText forState:UIControlStateNormal];
    
    leftButtonCallback = leftCallback;
    
    [_rightButton setHidden:NO];
    [_rightButton setTitle:rightButtonText forState:UIControlStateNormal];
    
    rightButtonCallback = rightCallback;
    [self showAnimation];
}

-(void) initWithMainTitle:(NSString*)mainTitle subTitle:(NSString*)subtitle message:(NSString*)message leftButtonText:(NSString*)leftButtonText leftButtonCallback:(SimpleCallback)leftCallback rightButtonText:(NSString*)rightButtonText rightButtonCallback:(SimpleCallback)rightCallback
{
    [_topMainTitleLabel setHidden:NO];
    [_topMainTitleLabel setText:mainTitle];
    
    [_topSubTitleLabel setHidden:NO];
    [_topSubTitleLabel setText:subtitle];
    
    [_bottomNormalLabel setHidden:NO];
    [_bottomNormalLabel setText:message];
    
    [_leftButton setHidden:NO];
    [_leftButton setTitle:leftButtonText forState:UIControlStateNormal];
    
    leftButtonCallback = leftCallback;
    
    [_rightButton setHidden:NO];
    [_rightButton setTitle:rightButtonText forState:UIControlStateNormal];
     
    rightButtonCallback = rightCallback;
    [self showAnimation];
}

-(void) initWithMessage:(NSString*)message leftButtonText:(NSString*)leftButtonText leftButtonCallback:(SimpleCallback)leftCallback rightButtonText:(NSString*)rightButtonText rightButtonCallback:(SimpleCallback)rightCallback
{
    [_normalLabel setHidden:NO];
    [_normalLabel setText:message];
    
    [_leftButton setHidden:NO];
    [_leftButton setTitle:leftButtonText forState:UIControlStateNormal];
    
    leftButtonCallback = leftCallback;
    
    [_rightButton setHidden:NO];
    [_rightButton setTitle:rightButtonText forState:UIControlStateNormal];
    
    rightButtonCallback = rightCallback;
    [self showAnimation];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float topMainTitleOffset = 0;
    float topSubTitleOffset = 0;
    float topCenterTitleOffset = 0;
    float normalOffset = 0;
    float bottomNormalOffset = 0;
    
    // size adjust
    float offset = 10;//40
    
    BOOL enabledFitstLabel = NO;
    
    if (_topMainTitleLabel.hidden == NO)
    {
        buttonSizeToFit(_topMainTitleLabel);
        
        topMainTitleOffset = offset;
        
        offset += _topMainTitleLabel.frame.size.height;
        
        enabledFitstLabel = YES;
    }
    
    if (_topSubTitleLabel.hidden == NO)
    {
        buttonSizeToFit(_topSubTitleLabel);
        
        if (enabledFitstLabel)
            offset += 16;
        
        topSubTitleOffset = offset;
        
        offset += _topSubTitleLabel.frame.size.height;
        
        enabledFitstLabel = YES;
    }
    
    if (_topCenterTitleLabel.hidden == NO)
    {
        buttonSizeToFit(_topCenterTitleLabel);
        
        if (enabledFitstLabel)
            offset += 16;
        
        topCenterTitleOffset = offset;
        
        offset += _topCenterTitleLabel.frame.size.height;
        
        enabledFitstLabel = YES;
    }
    
    if (_normalLabel.hidden == NO)
    {
        buttonSizeToFit(_normalLabel);
        
        if (enabledFitstLabel)
            offset += 36;//16
        
        normalOffset = offset;
        
        offset += _normalLabel.frame.size.height;
        
        enabledFitstLabel = YES;
    }
    
    if (_bottomNormalLabel.hidden == NO)
    {
        buttonSizeToFit(_bottomNormalLabel);
        
        if (enabledFitstLabel)
            offset += 16;
        
        bottomNormalOffset = offset;
        
        offset += _bottomNormalLabel.frame.size.height;
        
        enabledFitstLabel = YES;
    }
    
    offset += 40;
    
    CGRect newFrame = _uivContainerView.frame;
    newFrame.size.height = offset + _centerButton.frame.size.height;
    _uivContainerView.frame = newFrame;
    
    _uivContainerView.center = _dimView.center;
    
    if (_topMainTitleLabel.hidden == NO)
    {
        CGRect newFrame = _topMainTitleLabel.frame;
        newFrame.origin.y = topMainTitleOffset;
        _topMainTitleLabel.frame = newFrame;
    }
    
    if (_topSubTitleLabel.hidden == NO)
    {
        CGRect newFrame = _topSubTitleLabel.frame;
        newFrame.origin.y = topSubTitleOffset;
        _topSubTitleLabel.frame = newFrame;
    }
    
    if (_topCenterTitleLabel.hidden == NO)
    {
        CGRect newFrame = _topCenterTitleLabel.frame;
        newFrame.origin.y = topCenterTitleOffset;
        _topCenterTitleLabel.frame = newFrame;
    }
    
    if (_normalLabel.hidden == NO)
    {
        CGRect newFrame = _normalLabel.frame;
        newFrame.origin.y = normalOffset;
        _normalLabel.frame = newFrame;
    }
    
    if (_bottomNormalLabel.hidden == NO)
    {
        CGRect newFrame = _bottomNormalLabel.frame;
        newFrame.origin.y = bottomNormalOffset;
        _bottomNormalLabel.frame = newFrame;
    }
    
    if (_topLine.hidden == NO)
    {
    CGRect newFrame = _topLine.frame;
        newFrame.origin.y =  _topMainTitleLabel.frame.origin.y+_topMainTitleLabel.frame.size.height+topMainTitleOffset;
    _topLine.frame = newFrame;
    }
}

void buttonSizeToFit(UILabel *targetLabel)
{
    CGSize fittedSize = [targetLabel sizeThatFits:CGSizeMake(targetLabel.frame.size.width, CGFLOAT_MAX)];
    
    CGRect newFrame = targetLabel.frame;
    newFrame.size.height = fittedSize.height;
    targetLabel.frame = newFrame;
}

- (IBAction)leftButtonClick:(id)sender
{
    if (leftButtonCallback != nil)
        leftButtonCallback();
    
    [self PopView];
}

- (IBAction)rightButtonClick:(id)sender
{
    if (rightButtonCallback != nil)
        rightButtonCallback();
    
    [self PopView];
}

- (IBAction)centerButtonClick:(id)sender
{
    if (centerButtonCallback != nil)
        centerButtonCallback();
    
    [self PopView];
}


- (void) PopView
{
    CATransform3D currentTransform = self.uivContainerView.layer.transform;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation = [[self.uivContainerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
        
        self.uivContainerView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }
    
    self.uivContainerView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.uivContainerView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.uivContainerView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

- (void) PopView2
{
    if (stack != nil)
    {
        for (long i = stack.count - 1; i >= 0; i--)
        {
            UIView *uiView = [stack objectAtIndex:i];
            if (uiView.superview == nil)
            {
                [stack removeObject:uiView];
            }
        }
        
        for (UIView *uiView in stack)
        {
            if (uiView.superview == self.superview)
            {
                [stack removeObject:uiView];
                
                [uiView setHidden:NO];
                
                break;
            }
        }
    }
    
    [self removeFromSuperview];
}

@end
