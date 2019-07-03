//
//  WebContentsViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 8. 5..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import "WebContentsViewController.h"
#import "NetworkManager.h"


@interface WebContentsViewController () <UIWebViewDelegate>
{
    
    __weak IBOutlet UIWebView *webview;
}

@end

@implementation WebContentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    // Do any additional setup after loading the view.
    //@"https:goodriver.co.kr/com1026/driving/_content/%@.asp?vipptsid=%@&latitude=%f&longitude=%f&request_type=%@&request_locale=%@"
    NSString *kind;
    switch (self.type) {
        case WEB_CONTENTS_CONTACT:
            kind = url_webcontent_contactus;
            _titleLabel.text = NSLocalizedString(@"menu07", nil);
            break;
        case WEB_CONTENTS_BUG:
            kind = url_webcontent_error_report;
            _titleLabel.text = NSLocalizedString(@"menu10", nil);
            break;
        case WEB_CONTENTS_UNION:
            kind = url_webcontent_intro;
            _titleLabel.text = NSLocalizedString(@"menu09", nil);
            break;
        case WEB_CONTENTS_CHARGE:
            kind = url_webcontent_account_list;
            _titleLabel.text = NSLocalizedString(@"menu03", nil);
            break;
        case WEB_CONTENTS_NOTICE:
            kind = url_webcontent_notice;
            _titleLabel.text = NSLocalizedString(@"menu08", nil);
            break;
        case WEB_CONTENTS_CASH_RECEIPT:
            kind = url_webcontent_cash_receipt;
            _titleLabel.text = NSLocalizedString(@"menu11", nil);
            break;
        case WEB_CONTENTS_HISTORY_LIST:
            kind = url_webcontent_call_history;
            _titleLabel.text = NSLocalizedString(@"menu02", nil);
            break;
        case WEB_CONTENTS_MILEAGE_LIST:
            kind = url_webcontent_mileage;
            _titleLabel.text = NSLocalizedString(@"menu04", nil);
            break;
        default:
            break;
    }
    
    double lat = [[NetworkManager sharedInstance] myLatitude];
    double lon = [[NetworkManager sharedInstance] myLongitude];
    
    NSString *phone = [[[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_PHONE_NUMBER] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *url = [NSString stringWithFormat:WEB_CONTENTS_URL,WEBCONTENT_PATH,kind,vipptsid,lat,lon,REQUEST_TYPE,REQUEST_LOCALE,phone];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [webview loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_loadingView setHidden:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    [_loadingView setHidden:NO];
    
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
