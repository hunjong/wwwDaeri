//
//  TermsViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "AcceptTermsViewController.h"

@interface AcceptTermsViewController ()
{
    
    UIImage *unselectedImage;
    UIImage *selectedImage;
    
    BOOL usageButtonState;
    BOOL privateButtonState;
    BOOL locationButtonState;
    BOOL allButoonState;
}
@end




@implementation AcceptTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _usageTextView.layer.borderWidth = 1.0f;
    _usageTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _usageTextView.layer.cornerRadius = 3;
    _privateTextView.layer.borderWidth = 1.0f;
    _privateTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _privateTextView.layer.cornerRadius = 3;
    _locationTextView.layer.borderWidth = 1.0f;
    _locationTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _locationTextView.layer.cornerRadius = 3;
    
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:SAVEKEY_PHONE_NUMBER];
    _numberTextLabel.text = number;
    _numberTextLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _numberTextLabel.layer.borderWidth = 1.0;
    _nextButton.enabled = NO;
    [_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
    
    unselectedImage = [UIImage imageNamed:@"check_box_off"];
    selectedImage = [UIImage imageNamed:@"check_box_on"];
    _closeButton.hidden = YES;
    
    [_usageCheckBox setImage:unselectedImage forState:UIControlStateNormal];

    [_usageCheckBox setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];

    [_privateCheckBox setImage:unselectedImage forState:UIControlStateNormal];

    [_privateCheckBox setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];

    [_locationCheckBox setImage:unselectedImage forState:UIControlStateNormal];

    [_locationCheckBox setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_usageTextView.text =[self downLoadText:TERMS_USE_URL];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_privateTextView.text =[self downLoadText:TERMS_PRIVACY_URL];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_locationTextView.text =[self downLoadText:TERMS_GPS_URL];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) checkNextStep
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(usageButtonState && privateButtonState && locationButtonState){
            _nextButton.enabled = YES;
            [_nextButton setTitleColor:UIColorFromRGB(SECOND_COLOR) forState:UIControlStateNormal];
        }else{
            [_nextButton setTitleColor:UIColorFromRGB(0x646e89) forState:UIControlStateNormal];
        }
    });
}

- (IBAction)usageClick:(id)sender {
    usageButtonState = !usageButtonState;
    [self setCheckbuttonImage];
   //((UIButton *)sender).selected = !((UIButton *)sender).selected;
    
    
    //[self checkNextStep];
}
- (IBAction)privateClick:(id)sender {
    privateButtonState = !privateButtonState;
    [self setCheckbuttonImage];
    //((UIButton *)sender).selected = !((UIButton *)sender).selected;
    
    
    
    //[self checkNextStep];
}
- (IBAction)locationClick:(id)sender {
    
    
    /*
    if ([sender isSelected]) {
        [sender setImage:selectedImage forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else {
        [sender setImage:unselectedImage forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
    */
    locationButtonState = !locationButtonState;
    [self setCheckbuttonImage];
    
    //((UIButton *)sender).selected = !((UIButton *)sender).selected;
    
    //[self checkNextStep];
}

-(void) setCheckbuttonImage
{
    if (usageButtonState == NO) {
        [_usageCheckBox setImage:unselectedImage forState:UIControlStateNormal];
    } else {
        [_usageCheckBox setImage:selectedImage forState:UIControlStateNormal];
    }
    if (privateButtonState == NO) {
        [_privateCheckBox setImage:unselectedImage forState:UIControlStateNormal];
    } else {
        [_privateCheckBox setImage:selectedImage forState:UIControlStateNormal];
    }
    if (locationButtonState == NO) {
        [_locationCheckBox setImage:unselectedImage forState:UIControlStateNormal];
    } else {
        [_locationCheckBox setImage:selectedImage forState:UIControlStateNormal];
    }
    [_usageCheckBox layoutIfNeeded];
    [_privateCheckBox layoutIfNeeded];
    [_locationCheckBox layoutIfNeeded];
}

- (IBAction)allCheckClick:(id)sender {
    
    allButoonState = !allButoonState;
    
    if (allButoonState == NO) {
        [_allCheckBox setImage:unselectedImage forState:UIControlStateNormal];
        usageButtonState = FALSE;
        privateButtonState = FALSE;
        locationButtonState = FALSE;
    } else {
        [_allCheckBox setImage:selectedImage forState:UIControlStateNormal];
        usageButtonState = TRUE;
        privateButtonState = TRUE;
        locationButtonState = TRUE;
    }
    [self setCheckbuttonImage];
   
    
    [self checkNextStep];
}

- (void) fullViewSetting
{
    _mainView.hidden = YES;
    [self.view addSubview:_detailView];
    CGRect frame =  _mainView.frame;
    //frame.origin.y = _titleView.frame.size.height;
    [_detailView setFrame:frame];
    _nextButton.hidden = YES;
    _closeButton.hidden = NO;
}

- (NSString *) downLoadText:(NSString *)text
{
    NSURL *url = [NSURL URLWithString:text];
    
    // Download and write to file
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSString *receivedDataString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    return receivedDataString;
}

- (IBAction)usageFullClick:(id)sender {
    [self fullViewSetting];
    _detailView.text = _usageTextView.text;
}
- (IBAction)privateFullClick:(id)sender {
    [self fullViewSetting];
    _detailView.text = _privateTextView.text;
}
- (IBAction)locationFullClick:(id)sender {
    [self fullViewSetting];
    _detailView.text = _locationTextView.text;
}
- (IBAction)closeClick:(id)sender {
    _mainView.hidden = NO;
    [_detailView removeFromSuperview];
    _closeButton.hidden = YES;
    _nextButton.hidden = NO;
}
- (IBAction)nextClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SAVEKEY_AGREEMENT];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([RECOMMENDER_CODE isEqualToString:@"YES"]){
            [self performSegueWithIdentifier:@"segueRecommender" sender:self];
            
        }else{
            [self performSegueWithIdentifier:@"segueMain" sender:self];
        }
    });
}

@end
