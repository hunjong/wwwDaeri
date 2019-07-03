//
//  SideMenuViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 19..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *usageButton;
@property (weak, nonatomic) IBOutlet UIButton *paymentButton;
@property (weak, nonatomic) IBOutlet UIButton *cashReceiptButton;
@property (weak, nonatomic) IBOutlet UIButton *mileageButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *callCenterButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *noticeButton;
@property (weak, nonatomic) IBOutlet UIButton *unionButton;
@property (weak, nonatomic) IBOutlet UILabel *unionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@end
