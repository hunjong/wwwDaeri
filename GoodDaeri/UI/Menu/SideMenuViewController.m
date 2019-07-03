//
//  SideMenuViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 19..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "SideMenuViewController.h"
#import "WebContentsViewController.h"
#import "NetworkManager.h"

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _numberLabel.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _unionLabel.text = AGENCY_NAME;
    NSString *actualVersion = [NetworkManager getAppVersion];
    _versionLabel.text = [NSString stringWithFormat:@"%@ %@",_versionLabel.text,actualVersion];
    
    _numberLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_PHONE_NUMBER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueWebContent"])
    {
        if ([[segue destinationViewController] isKindOfClass:[WebContentsViewController class]])
        {
            WebContentsViewController *nextVC = [segue destinationViewController];
            if([sender isEqualToString:url_webcontent_contactus]){
                nextVC.type = WEB_CONTENTS_CONTACT;
            }else if([sender isEqualToString:url_webcontent_notice]){
                nextVC.type = WEB_CONTENTS_NOTICE;
            }else if([sender isEqualToString:url_webcontent_intro]){
                nextVC.type = WEB_CONTENTS_UNION;
            }else if([sender isEqualToString:url_webcontent_cash_receipt]){
                nextVC.type = WEB_CONTENTS_CASH_RECEIPT;
            }else if([sender isEqualToString:url_webcontent_call_history]){
                nextVC.type = WEB_CONTENTS_HISTORY_LIST;
            }else if([sender isEqualToString:url_webcontent_mileage]){
                nextVC.type = WEB_CONTENTS_MILEAGE_LIST;
            }
            
        }
    }
}


- (IBAction)callCenterClick:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NetworkManager sharedInstance].callCenterTel ?: cscenter_phone_number]];
}

- (IBAction)contactClick:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueWebContent" sender:url_webcontent_contactus];
    });
}

- (IBAction)noticeClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:@"segueWebContent" sender:url_webcontent_notice];
    });
}

- (IBAction)unionClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
    [self performSegueWithIdentifier:@"segueWebContent" sender:url_webcontent_intro];
    });
}

- (IBAction)cashReceiptClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueWebContent" sender:url_webcontent_cash_receipt];
    });
}
- (IBAction)usageClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueWebContent" sender:url_webcontent_call_history];
    });
}
- (IBAction)mileageClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueWebContent" sender:url_webcontent_mileage];
    });
}

-(IBAction)prepareForUnwindMenu:(UIStoryboardSegue *)segue {
    
}
@end
