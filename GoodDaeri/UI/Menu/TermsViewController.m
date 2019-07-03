//
//  TermsViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()
{
    NSString *termsUrl;
}
@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    NSString* path = [[NSBundle mainBundle] pathForResource:@"GoodDaeri" ofType:@"strings"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"\n %@",[dict objectForKey:@"이용약관"]);
    if(_isUsageTerms){
        _titleLabel.text = @"이용약관";
        //_textView.text = [dict objectForKey:@"이용약관"];
        termsUrl = TERMS_USE_URL;
    }else if(_isPrivateTerms){
        _titleLabel.text = @"개인정보보호방침";
        //_textView.text = [dict objectForKey:@"개인정보보호방침"];
        termsUrl = TERMS_PRIVACY_URL;
    }else{
        _titleLabel.text = @"위치서비스 이용약관";
        //_textView.text = [dict objectForKey:@"위치서비스 이용약관"];
        termsUrl = TERMS_GPS_URL;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_textView.text =[self downLoadText:self->termsUrl];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) downLoadText:(NSString *)text
{
    NSURL *url = [NSURL URLWithString:text];
    
    NSLog(@"downLoadText : %@", url);
    
    // Download and write to file
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    NSString *receivedDataString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    return receivedDataString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
