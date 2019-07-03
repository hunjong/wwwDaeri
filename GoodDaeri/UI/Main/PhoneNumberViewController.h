//
//  PhoneNumberViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneNumberViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberInputView;
@property (weak, nonatomic) IBOutlet UIView *verifyNumberView;
@property (weak, nonatomic) IBOutlet UITextField *verifyTextField;
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@end
