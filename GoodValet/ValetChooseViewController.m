//
//  ValetChooseViewController.m
//  GoodValet
//
//  Created by hunjong choi on 27/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import "ValetChooseViewController.h"
#import <KakaoNavi/KakaoNavi.h>
#import "TMap.h"

@interface ValetChooseViewController ()
{
    
}
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation ValetChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)closeClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
