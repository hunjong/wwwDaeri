//
//  PhoneNumberViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "PhoneNumberViewController.h"
#import "AcceptTermsViewController.h"
#import "NetworkManager.h"
#import "responseData.h"
#import "CommonMessageView.h"

@interface PhoneNumberViewController () <UITextFieldDelegate>
{
    BOOL isVerified;
    BOOL isWaiting;
    NSTimer *timer;
    NSInteger waitTime;
    NSString *verifyNumberFromServer;
    NSString *phoneNumber;
    NSInteger tryNumber;
}

@end

@implementation PhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    [self initialState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)textFieldDidChanged:(UITextField *)theTextField
{
    if(theTextField == _numberTextField){
        
        NSString *string = [theTextField.text stringByReplacingOccurrencesOfString:@"-"
                                             withString:@""];
        if(string.length == 11){
            
            phoneNumber = string;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _nextButton.enabled = YES;
                [_nextButton setTitleColor:UIColorFromRGB(SECOND_COLOR) forState:UIControlStateNormal];
            });
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _nextButton.enabled = NO;
                [_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
            });
            
        }
        
    }else if (theTextField == _verifyTextField){
        
        if(theTextField.text.length >= 4){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_nextButton setTitleColor:UIColorFromRGB(SECOND_COLOR) forState:UIControlStateNormal];
                _nextButton.enabled = YES;
            });
            
            if([verifyNumberFromServer isEqualToString:theTextField.text]){
                
                isVerified = YES;
            }else{
                
                isVerified = NO;
            }
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _nextButton.enabled = NO;
                [_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
            });
            
        }
    }
}

// 입력 형식에 맞추기 위해 특정 위치에 공백 문자 삽입
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   
}

-(BOOL) NSStringIsValid:(NSString *)checkString
{
    NSString *stricterFilterString = @"[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\u318D\u119E\u11A2\u2022\u2025a\u00B7\uFE55_-]*";
    //NSString *stricterFilterString = @"[ㄱ-ㅎㅏ-ㅣ가-힣A-Z0-9a-z-_ ]*";
    
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [stringTest evaluateWithObject:checkString];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueTerms"])
    {
        if ([[segue destinationViewController] isKindOfClass:[AcceptTermsViewController class]])
        {
            AcceptTermsViewController *nextVC = [segue destinationViewController];
            nextVC.phoneNumber = phoneNumber;
        }
    }
}


- (void) initialState
{
    waitTime = 180;
    _verifyNumberView.hidden = YES;
    _phoneNumberInputView.hidden = NO;
    _nextButton.enabled = NO;
    [_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
    _backButton.hidden = YES;
    isVerified = NO;
    _numberTextField.text = @"";
    _verifyTextField.text = @"";
    _phoneNumberLabel.text = @"";
    isWaiting = NO;
    _backButton.hidden = YES;
    
    _numberTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _numberTextField.layer.borderWidth = 1;
    _verifyTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _verifyTextField.layer.borderWidth = 1;
}

- (void) waitMessage
{
    
    NSTimeInterval interval = 1.0;
    //timer = [NSTimer scheduledTimerWithTimeInterval:interval
     //                                target:self
    ///                               selector:@selector(timerFired:)
    //                               userInfo:nil
    //                                 repeat:YES];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    
    [[NetworkManager sharedInstance]iOSMobileNum:phoneNumber complete:^(BOOL success, responseData *data)
     {
         if (success)
         {
             _phoneNumberLabel.text = [self splitNumber:phoneNumber];
             _phoneNumberInputView.hidden = YES;
             _verifyNumberView.hidden = NO;
             _remainTimeLabel.text = [NSString stringWithFormat:@"%ld%@",(long)waitTime,NSLocalizedString(@"second", nil)];
             
             self->verifyNumberFromServer = data.message;
             
         }else{
             [_numberTextField resignFirstResponder];
             CommonMessageView *messageView = [CommonMessageView createView:self.view];
             [messageView initWithNoticeMessage:NSLocalizedString(@"서버 통신 에러입니다",nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
                 
                 isWaiting = FALSE;
                 [_nextButton setTitleColor:UIColorFromRGB(SECOND_COLOR) forState:UIControlStateNormal];
                 _nextButton.enabled = YES;
             }];
         }
     }];
}

- (NSString *) splitNumber:(NSString *)number
{
    // 문자열 중간부분 반환
    NSString *tmp1 = [number substringWithRange:NSMakeRange(0, 3)];
    NSString *tmp2 = [number substringWithRange:NSMakeRange(3, 4)];
    NSString *tmp3 = [number substringWithRange:NSMakeRange(7, 4)];
    return [NSString stringWithFormat:@"%@-%@-%@",tmp1,tmp2,tmp3];
}

- (void) timerFired
{
    waitTime -=1;
    _remainTimeLabel.text = [NSString stringWithFormat:@"%ld%@",(long)waitTime,NSLocalizedString(@"second", nil)];
    if(waitTime == 0){
        [timer invalidate];
        [self initialState];
    }
}

- (IBAction)nextClick:(id)sender {
    
    if(!isWaiting){
        isWaiting = TRUE;
        [self waitMessage];
        _backButton.hidden = NO;
        _nextButton.enabled = NO;
        [_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
        [_verifyTextField becomeFirstResponder];
    }else if(!isVerified){
        
        [_verifyTextField resignFirstResponder];
        CommonMessageView *messageView = [CommonMessageView createView:self.view];
        [messageView initWithNoticeMessage:@"인증이 완료되지않았습니다" centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
            
            //_nextButton.enabled = YES;
            // isVerified = YES;
            //[_nextButton setTitleColor:UIColorFromRGB(SECOND_COLOR) forState:UIControlStateNormal];
            //[self waitMessage];
            //_backButton.hidden = NO;
            //_nextButton.enabled = NO;
            //[_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
            if(tryNumber < 3){
                tryNumber++;
                _nextButton.enabled = NO;
                [_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
                _verifyTextField.text = @"";
            }else{
                tryNumber = 0;
                [timer invalidate];
                [self initialState];
            }
            
        }];
        
    }else{
        
        [_numberTextField endEditing:YES];
        [_verifyTextField endEditing:YES];
        
        [[NSUserDefaults standardUserDefaults] setObject:[self splitNumber:phoneNumber] forKey:SAVEKEY_PHONE_NUMBER];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segueTerms" sender:self];
        });
    }
    
}
- (IBAction)backClick:(id)sender {
    tryNumber = 0;
    [timer invalidate];
    [self initialState];
    [_verifyTextField resignFirstResponder];
}


@end
