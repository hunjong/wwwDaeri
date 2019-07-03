//
//  TermsViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcceptTermsViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *numberTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *usageCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *usageFullView;
@property (weak, nonatomic) IBOutlet UIButton *privateCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *privateFullView;
@property (weak, nonatomic) IBOutlet UIButton *locationCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *locationFullView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITextView *detailView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextView *usageTextView;
@property (weak, nonatomic) IBOutlet UITextView *privateTextView;
@property (weak, nonatomic) IBOutlet UITextView *locationTextView;
@property (weak, nonatomic) IBOutlet UIButton *allCheckBox;

@property (readwrite) NSString * _Nullable phoneNumber;

@end
