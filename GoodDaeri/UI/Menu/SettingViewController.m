//
//  SettingViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "SettingViewController.h"
#import "TermsViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _alarmSwitch.tintColor = UIColorFromRGB(BASIC_COLOR);
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _saveButton.titleLabel.textColor = UIColorFromRGB(SECOND_COLOR);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"unwindMenu" sender:self];
    });
    
}

-(IBAction)prepareForUnwindSetting:(UIStoryboardSegue *)segue {
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueTerms"])
    {
        if ([[segue destinationViewController] isKindOfClass:[TermsViewController class]])
        {
            TermsViewController *nextVC = [segue destinationViewController];
            if(sender == _termsButton){
                nextVC.isUsageTerms = TRUE;
            }else if(sender == _privateButton){
                nextVC.isPrivateTerms = TRUE;
            }else{
                nextVC.isLocationTerms = TRUE;
            }
                
        }
    }
}

- (IBAction)alarmChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_alarmSwitch.isOn forKey:SAVEKEY_ALARM];
}
- (IBAction)smsChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:_smsSwitch.isOn forKey:SAVEKEY_SMS];

}
- (IBAction)usageClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueTerms" sender:_termsButton];
    });
    
}

- (IBAction)privateClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:@"segueTerms" sender:_privateButton];
    });
}


- (IBAction)locationClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:@"segueTerms" sender:_locationButton];
    });
}

- (IBAction)noticeClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:@"segueNotice" sender:self];
    });
}


@end
