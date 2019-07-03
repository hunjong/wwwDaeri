//
//  PayingViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "PayingViewController.h"
#import "NTMonthYearPicker.h"
#import "NetworkManager.h"
#import "responseData.h"
#import "MainViewController.h"

@interface PayingViewController () <UITextFieldDelegate>
{
    __weak IBOutlet UILabel *sellInfoLabel;
    __weak IBOutlet UIView *sellLineLeft;
    __weak IBOutlet UIView *sellLineRight;
    
    __weak IBOutlet UILabel *cardInfoLabel;
    __weak IBOutlet UIView *cardLineLeft;
    __weak IBOutlet UIView *cardLineRight;
    BOOL isCardPayed;
    BOOL isCancel;
    
    NSInteger yearNum;
    NSInteger monthNum;
}
@end

@implementation PayingViewController

NTMonthYearPicker *picker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _confirmButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _buttonLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _finishButton.titleLabel.textColor = UIColorFromRGB(BASIC_COLOR);
    sellLineRight.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    cardLineRight.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    sellInfoLabel.textColor = UIColorFromRGB(SECOND_COLOR);
    sellLineLeft.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    cardInfoLabel.textColor = UIColorFromRGB(SECOND_COLOR);
    cardLineLeft.backgroundColor = UIColorFromRGB(SECOND_COLOR);
    
    
    _cardNum1.text = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_CARD_NUMBER1];
    _cardNum2.text = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_CARD_NUMBER2];
    _cardNum3.text = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_CARD_NUMBER3];
    _cardNum4.text = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_CARD_NUMBER4];
    _expireYear.text = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_CARD_YEAR];
    _expireMonth.text = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_CARD_MONTH];
    
    yearNum = [[[_expireYear.text componentsSeparatedByCharactersInSet:
                 [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                componentsJoinedByString:@""] integerValue];
    monthNum = [[[_expireMonth.text componentsSeparatedByCharactersInSet:
                  [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                 componentsJoinedByString:@""] integerValue];
    
    // Initialize the picker
    picker = [[NTMonthYearPicker alloc] init];
    [picker addTarget:self action:@selector(onDatePicked:) forControlEvents:UIControlEventValueChanged];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    // Set mode to month + year
    // This is optional; default is month + year
    picker.datePickerMode = NTMonthYearPickerModeMonthAndYear;
    
    // Set minimum date to January 2000
    // This is optional; default is no min date
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"dd"];
    NSString *dayString = [formatter stringFromDate:[NSDate date]];
    [formatter setDateFormat:@"MM"];
    NSString *monthString = [formatter stringFromDate:[NSDate date]];
    int day = [dayString intValue];
    int month = [monthString intValue];
    int year = [yearString intValue];
    
    NSLog(@"day: %d , month: %d , year: %d",day,month,year);
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];//
    picker.minimumDate = [cal dateFromComponents:comps];
    
    yearNum = [yearString intValue];
    monthNum = [monthString intValue];
    // Set maximum date to next month
    // This is optional; default is no max date
    [comps setDay:0];
    [comps setMonth:12];
    [comps setYear:2050];
    picker.maximumDate = [cal dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    // Set initial date to last month
    // This is optional; default is current month/year
    //[comps setDay:0];
    //[comps setMonth:-1];
    //[comps setYear:0];
    //picker.date = [cal dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    // Initialize UI label and mode selector
    [self updateLabel];
    
    _nameTextField.text = _productName;
    [_nameTextField endEditing:YES];
    _priceTextField.text = [NSString stringWithFormat:@"%d,%@",(int)_payCost/1000 ,@"000"];
    [_priceTextField endEditing:YES];
    
    if(!_cardNum1.text || [_cardNum1.text isEqualToString:@""])
        [_cardNum1 becomeFirstResponder];
    
    
    [self border:_nameTextField withColor:[UIColor blackColor]];
    [self border:_priceTextField withColor:[UIColor blackColor]];
    [self border:_cardNum1 withColor:[UIColor blueColor]];
    [self border:_cardNum2 withColor:[UIColor blueColor]];
    [self border:_cardNum3 withColor:[UIColor blueColor]];
    [self border:_cardNum4 withColor:[UIColor blueColor]];
    [self border:_expireMonth withColor:[UIColor blueColor]];
    [self border:_expireYear withColor:[UIColor blueColor]];
    
}

- (void) border:(UITextField *)field withColor:(UIColor *)color
{
    field.layer.borderWidth = 1.0f;
    field.layer.borderColor = [color CGColor];
    field.layer.cornerRadius = 3;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitClick:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueMain" sender:self];
    });
}
- (IBAction)confirmClick:(id)sender {
    //_nameTextField.text = @"";
    //_priceTextField.text = @"";
    //_cardNum1.text = @"";
    //_cardNum2.text = @"";
    //_cardNum3.text = @"";
    //.text = @"";
    //_expireMonth.text = @"";
    //_expireYear.text = @"";
    NSString *expire_date;
    if(monthNum <10){
        expire_date = [NSString stringWithFormat:@"%ld0%ld",(long)yearNum,(long)monthNum];
    }else{
        expire_date = [NSString stringWithFormat:@"%ld%ld",(long)yearNum,(long)monthNum];
    }
    //이름 ,카드 = ""
    NSString *name = @"";
    NSString *card = @"";
    NSString *phone = [[[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_PHONE_NUMBER] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *card_number = [NSString stringWithFormat:@"%@%@%@%@",_cardNum1.text,_cardNum2.text,_cardNum3.text,_cardNum4.text];
    
    [[NetworkManager sharedInstance] cardDirect:CARD_DIRECT_ORDER_TYPE_OK c_name:name c_phone:phone c_card:card c_card_number:card_number c_expire_date:expire_date complete:^(BOOL success,responseData *data){
        if(success){
            
            if([data.response_yn isEqualToString:@"y"] ||[data.response_yn isEqualToString:@"Y"]){
            
            [[NSUserDefaults standardUserDefaults] setValue:self->_cardNum1.text forKey:SAVEKEY_CARD_NUMBER1];
            [[NSUserDefaults standardUserDefaults] setValue:self->_cardNum2.text forKey:SAVEKEY_CARD_NUMBER2];
            [[NSUserDefaults standardUserDefaults] setValue:self->_cardNum3.text forKey:SAVEKEY_CARD_NUMBER3];
            [[NSUserDefaults standardUserDefaults] setValue:self->_cardNum4.text forKey:SAVEKEY_CARD_NUMBER4];
            [[NSUserDefaults standardUserDefaults] setValue:self->_expireYear.text forKey:SAVEKEY_CARD_YEAR];
            [[NSUserDefaults standardUserDefaults] setValue:self->_expireMonth.text forKey:SAVEKEY_CARD_MONTH];
            
            
            
            isCardPayed = TRUE;
            
            }else{
                isCardPayed = FALSE;
            }
        }else{
            isCardPayed = FALSE;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segueMain" sender:self];
        });
    }];
}

- (void) addPickerView
{
    //CGSize pickerSize = [picker sizeThatFits:CGSizeZero];
    if( ![picker isDescendantOfView:self.view] ) {
        picker.frame = _pickerContainer.frame;
        [self.view addSubview:picker];
    }
}



- (void)onDatePicked:(UITapGestureRecognizer *)gestureRecognizer {
    [self updateLabel];
    
}

- (void)updateLabel {
    NSDateFormatter *dfMonth = [[NSDateFormatter alloc] init];
    NSDateFormatter *dfYear = [[NSDateFormatter alloc] init];
    //if( picker.datePickerMode == NTMonthYearPickerModeMonthAndYear ) {
    [dfMonth setDateFormat:@"MM월"];
    [dfYear setDateFormat:@"yyyy년"];
    
    NSString *month = [dfMonth stringFromDate:picker.date];
    NSString *year = [dfYear stringFromDate:picker.date];
    
    _expireMonth.text = month;
    _expireYear.text = year;
    yearNum = [year integerValue];
    monthNum = [month integerValue];
    //[picker removeFromSuperview];//추가
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)textFieldDidChanged:(UITextField *)textField
{
    NSLog(@"textFieldDidChanged %@",textField);
    if(textField.text.length == 4){
    [textField endEditing:YES];
    if(textField == _cardNum1){
        
        if(_cardNum2.text.length <4)
            [_cardNum2 becomeFirstResponder];
    }else if(textField == _cardNum2){
        if(_cardNum3.text.length <4)
            [_cardNum3 becomeFirstResponder];
    }else if(textField == _cardNum3){
        if(_cardNum4.text.length <4)
            [_cardNum4 becomeFirstResponder];
    }else{
        [_cardNum4 resignFirstResponder];
    }
        
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Get the selected text range
    UITextRange *selectedRange = [textField selectedTextRange];
    // Calculate the existing position, relative to the end of the field (will be a - number)
    int pos = (int)[textField offsetFromPosition:textField.endOfDocument toPosition:selectedRange.start];
    NSInteger textlength = textField.text.length;
    
    if(textField == _cardNum1 || textField == _cardNum2 || textField == _cardNum3 || textField == _cardNum4){
        
        if(textlength == 4){
            
            
            UITextPosition *beginning = textField.beginningOfDocument;
            UITextPosition *cursorLocation = [textField positionFromPosition:beginning offset:(range.location + string.length+1)];
            if(cursorLocation){
                NSLog(@"cursor : %d",pos);
                if(pos < 0){
                    NSLog(@"커서 중간");
                }
            }else{
                
                return NO;
            }
            
            
            
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _expireYear ||textField == _expireMonth){
        [self endEditAll];
        [self addPickerView];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(textField == _nameTextField || textField == _priceTextField){
        return FALSE;
    }
    return TRUE;
    
}

- (void) endEditAll
{
    [_nameTextField resignFirstResponder];
    [_priceTextField resignFirstResponder];
    [_cardNum1 resignFirstResponder];
    [_cardNum2 resignFirstResponder];
    [_cardNum3 resignFirstResponder];
    [_cardNum4 resignFirstResponder];
    [_expireMonth resignFirstResponder];
    [_expireYear resignFirstResponder];
}

- (IBAction)backClick:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->isCancel = TRUE;
        [self performSegueWithIdentifier:@"segueMain" sender:self];
    });
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
            nextVC.isCardPayed = isCardPayed;
            if(isCardPayed){
                isCancel = FALSE;
            }
            nextVC.isCardCanceled = isCancel;
            
        }
    }
}


@end
