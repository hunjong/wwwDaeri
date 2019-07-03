//
//  NavigationController.m
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 26..
//  Copyright © 2017년 m4nc. All rights reserved.
//

#import "NavigationController.h"

#import "IndicatorView.h"
#import "IntroViewController.h"
#import "PopUpViewController.h"

@interface NavigationController()
{
    IndicatorView *indicatorView;
}

@end


@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    indicatorView = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startIndicator:(UIView*)parentView withMessage:(BOOL)withMessage
{
     if (indicatorView == nil)
     {
         NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"IndicatorView" owner:nil options:nil];
         indicatorView = [subviewArray lastObject];
         
         [indicatorView setFrame:parentView.frame];
         
         [indicatorView.uiaiIndicator setTransform:CGAffineTransformMakeScale(2, 2)];
     }
     
     if (indicatorView.superview != nil)
         [indicatorView removeFromSuperview];
     
     if ([indicatorView isHidden])
         [indicatorView setHidden:NO];
     
     [indicatorView.uilMessage setHidden:!withMessage];
     
     //NSLog(@"startIndicator : %d", withMessage);
     
     [parentView addSubview:indicatorView];
}

- (void) stopIndicator
{
     //NSLog(@"stopIndicator");
     
     if (indicatorView.superview != nil)
         [indicatorView removeFromSuperview];
     
     if (![indicatorView isHidden])
         [indicatorView setHidden:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 10)
    {
        NSMutableArray *mutableViewControllers = [self.viewControllers mutableCopy];
        
        //remove 2 last controllers in controller stack (from the bottom)
        [mutableViewControllers removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
        self.viewControllers = [mutableViewControllers copy];
    }
    
    [super pushViewController:viewController animated:animated];
}

// 최상위 VC 1개만 남기고 삭제
- (void) clearViewControllers
{
    if (self.viewControllers.count > 2)
    {
        NSMutableArray *mutableViewControllers = [self.viewControllers mutableCopy];
        
        //remove 2 last controllers in controller stack (from the bottom)
        [mutableViewControllers removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, mutableViewControllers.count - 1)]];
        self.viewControllers = [mutableViewControllers copy];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"segueIntro"])
    {
        if ([[segue destinationViewController] isKindOfClass:[IntroViewController class]])
        {
            IntroViewController *viewController = [segue destinationViewController];
            
        }
    }else if ([[segue identifier] isEqualToString:@"seguePopUp"])
    {
        if ([[segue destinationViewController] isKindOfClass:[PopUpViewController class]])
        {
            PopUpViewController *viewController = [segue destinationViewController];
            [viewController setIntroData:(IntroData *)sender];
            
        }
        
    }
}

@end
