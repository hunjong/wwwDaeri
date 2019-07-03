//
//  RecommenderViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "RecommenderViewController.h"
#import "NetworkManager.h"

@interface RecommenderViewController () <UITextFieldDelegate>
{
    NSString *recommanderCode;
}
@end

@implementation RecommenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _codeTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _codeTextField.layer.borderWidth = 1;
    _codeTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
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

- (IBAction)textFieldDidChanged:(UITextField *)textField
{
    if([self NSStringIsValid:textField.text]){
        
    }else{
        
        
        //textField.text = [textField.text stringByReplacingCharactersInRange:range
        //                                                         withString:@""];
        
        
        NSString *text = textField.text;
        NSString *newString = [text substringToIndex:[text length]-1];
        textField.text=newString;
        
    }
}

// 입력 형식에 맞추기 위해 특정 위치에 공백 문자 삽입
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([self NSStringIsValid:textField.text]){
        
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:[string uppercaseString]];
            return NO;
        }
        
        return YES;
        
    }else{
        
        
        //textField.text = [textField.text stringByReplacingCharactersInRange:range
        //                                                         withString:@""];
        
        
        NSString *text = textField.text;
        NSString *newString = [text substringToIndex:[text length]-1];
        textField.text=newString;
        
        return NO;
    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)passButton:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SAVEKEY_RECOMMEND];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"segueMain" sender:self];
    });
    
}
- (IBAction)confirmButton:(id)sender {
    if(_codeTextField.text.length > 0){
        recommanderCode = _codeTextField.text;
    [[NetworkManager sharedInstance]agentRecommender:_codeTextField.text complete:^(BOOL success, responseData *data)
     {
         if (success)
         {
             [[NSUserDefaults standardUserDefaults] setObject:self->recommanderCode forKey:SAVEKEY_RECOMMEND];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self performSegueWithIdentifier:@"segueMain" sender:self];
             });
         }else{
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self performSegueWithIdentifier:@"segueMain" sender:self];
             });
         }
     }];
    }else{
        
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:SAVEKEY_RECOMMEND];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segueMain" sender:self];
        });
        
    }
    
}

@end
