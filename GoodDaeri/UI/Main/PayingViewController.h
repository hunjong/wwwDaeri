//
//  PayingViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;
@property (weak, nonatomic) IBOutlet UITextField *cardNum1;
@property (weak, nonatomic) IBOutlet UITextField *cardNum2;
@property (weak, nonatomic) IBOutlet UITextField *cardNum3;
@property (weak, nonatomic) IBOutlet UITextField *cardNum4;
@property (weak, nonatomic) IBOutlet UITextField *expireMonth;
@property (weak, nonatomic) IBOutlet UITextField *expireYear;
@property (weak, nonatomic) IBOutlet UILabel *buttonLine;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIView *pickerContainer;

@property (readwrite) NSString * productName;
@property (readwrite) NSInteger * payCost;
@end
