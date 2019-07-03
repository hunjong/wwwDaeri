//
//  TerminationViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "TerminationViewController.h"
#import "MainViewController.h"

@interface TerminationViewController ()
{
    BOOL withComplain;
}
@end

@implementation TerminationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _goHomeButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)complainClick:(id)sender {
    withComplain = TRUE;
}
- (IBAction)goHomeClick:(id)sender {
    withComplain = FALSE;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueMain"])
    {
        if ([[segue destinationViewController] isKindOfClass:[MainViewController class]])
        {
            MainViewController *nextVC = [segue destinationViewController];
            nextVC.withComplain = withComplain;
        }
    }
}


@end
