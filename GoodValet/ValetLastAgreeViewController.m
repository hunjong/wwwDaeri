//
//  ValetLastAgreeViewController.m
//  GoodValet
//
//  Created by hunjong choi on 27/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import "ValetLastAgreeViewController.h"
#import "NetworkManager.h"
#import "responseData.h"
#import "TMap.h"

@interface ValetLastAgreeViewController ()


@property (weak, nonatomic) IBOutlet UILabel *carNumberLabel;
@property (weak, nonatomic) IBOutlet UITextView *agreeContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *agreeDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreeCarAddressLabel;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *disAgreeButton;

@property (weak, readwrite) NSString *agreeName;
@property (weak, readwrite) NSString *agreeCarNum;
@property (weak, readwrite) NSString *agreeAddress;
@end

@implementation ValetLastAgreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NetworkManager sharedInstance] memberInfo:^(BOOL success, MemberModifyData *data) {
        _agreeName = data.member_name;
        _agreeCarNum = data.member_car_number;
        _carNumberLabel.text = data.member_car_number;
        TMapPoint *point = [[TMapPoint alloc] initWithLon:[_targetValetData.valet_lon doubleValue] Lat:[_targetValetData.valet_lat doubleValue]];
        NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:point];
        _agreeCarAddressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"last_agree_addr", nil),address];
        _agreeAddress = address;
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy년 MM월 dd일  HH시 mm분"];
        [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"]];
        NSString *dateString = [dateFormat stringFromDate:today];
        NSLog(@"Today : %@", dateString);
        _agreeDateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"last_agree_dt", nil),dateString];
        
        
        
    }];
}
- (IBAction)disAgreeClick:(id)sender {
    [self sendAgreeData:NO];
}
- (IBAction)agreeClick:(id)sender {
    [self sendAgreeData:YES];
}

- (void) sendAgreeData:(BOOL)agreed
{
    [[NetworkManager sharedInstance] valetLastAgree:_agreeAddress ?:@"" location:CLLocationCoordinate2DMake(_targetValetData.valet_lat.doubleValue, _targetValetData.valet_lon.doubleValue) carNum:_agreeCarNum name:_agreeName ?: @"" yn:agreed? @"y":@"n" complete:^(BOOL success) {
        
        if(success){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"unwindMain" sender:nil];
            });
        }
    }];
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
