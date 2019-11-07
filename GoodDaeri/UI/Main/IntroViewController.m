//
//  IntroViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "IntroViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>
#import "NetworkManager.h"
#import "CommonMessageView.h"
#import "responseData.h"
#import "AppDelegate.h"

@interface IntroViewController () <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    BOOL gpsCheckDone;
    BOOL alarmCheckDone;
    BOOL isMoved;
}
@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // GPS 활성화 여부 확인
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        gpsCheckDone = YES;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        
        if(((AppDelegate *)[[UIApplication sharedApplication]delegate]).isWaWaWaDaeri){
            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {

                // 앱이 활성화 되어 있는 동안에만 위치서비스를 이용하는 경우
                [locationManager requestWhenInUseAuthorization];
            }
            else
            {
                gpsCheckDone = NO;
                [self nextMessageView];
            }
        }else{
            
            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                
                // 항상 위치서비스를 이용하는 경우
                [locationManager requestAlwaysAuthorization];
            }
            else
            {
                gpsCheckDone = NO;
                [self nextMessageView];
            }
        }
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        gpsCheckDone = NO;
        [self nextMessageView];
    }
    
    alarmCheckDone = [[NSUserDefaults standardUserDefaults] boolForKey:SAVEKEY_ALARM];
    //test
    alarmCheckDone = YES;
    //업데이트 확인
    
    
    
    //[self checkUpdate];
    //NSString *requiredVersion = [[NSUserDefaults standardUserDefaults] objectForKey:SAVEKEY_APP_VER];
    //NSString *actualVersion = [NetworkManager getAppVersion];
    if(gpsCheckDone && alarmCheckDone){
        [self switchToNextVC];
    }
}


- (void) checkUpdate
{
    [[NetworkManager sharedInstance]checkUpdate:^(BOOL success, CheckUpdateData *checkUpdateData)
     {
         if (success)
         {
             //Y,n
             if([checkUpdateData.update_yn isEqualToString:@"Y"] ||[checkUpdateData.update_yn isEqualToString:@"y"] ){
                 
                 [self updateNow];
                 //test
                 
             }else{
                 //[self updateNow];
                 [self nextMessageView];
             }
             
         }else{
             
             
         }
     }];
}

- (void) updateNow
{
    
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    
    NSString *updateMessage = NSLocalizedString(@"server_have_update",nil);
    NSString *noButtonText = NSLocalizedString(@"btn_no",nil);
    NSString *updateButtonText = @"업데이트";
    
    [messageView initWithTitle:NSLocalizedString(@"dialog_notify_title",nil) message:updateMessage leftButtonText:noButtonText leftButtonCallback:^{
        [self nextMessageView];
    } rightButtonText:updateButtonText rightButtonCallback:^
     {
         
         NSString *iTunesLink = [REQUEST_TYPE isEqualToString:@"gs"] ? @"itms-apps://itunes.apple.com/app/id1434687876" : @"itms-apps://itunes.apple.com/app/id1455215095";
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
         
         //[[NSNotificationCenter defaultCenter] addObserver:self
         //                                         selector:@selector(checkUpdate)
         //                                             name:UIApplicationDidBecomeActiveNotification
         //                                           object:nil];
     }];
}

- (void) checkLocationService {

    NSString *updateMessage = @"정확한 현 위치 파악을 위해 위치서비스를 켜 주세요.";
    NSString *laterButtonText = @"나중에";
    NSString *nowButtonText = @"지금 설정";
    
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    [messageView initWithTitle:NSLocalizedString(@"dialog_notify_title",nil) message:updateMessage leftButtonText:laterButtonText leftButtonCallback:^{
        gpsCheckDone = YES;
        [self nextMessageView];
        
    } rightButtonText:nowButtonText rightButtonCallback:^
     {
         gpsCheckDone = YES;
         [self nextMessageView];
         
         if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue] < 10) {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
             
             
         } else {
             if (@available(iOS 10.0, *)) {
                 [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
             } else {
                 // Fallback on earlier versions
             }
         }
         
     }];
}

- (void) checkAlarm {
    
    NSString *alarmMessage = @"앱에서 알림을 보내고자 합니다. 알림 수신을 허용해 주세요.";
    NSString *noButtonText = NSLocalizedString(@"btn_cancel",nil);
    NSString *settingButtonText = @"설정";
    
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    [messageView initWithTitle:NSLocalizedString(@"dialog_notify_title",nil) message:alarmMessage leftButtonText:noButtonText leftButtonCallback:^{
        [self switchToNextVC];
        
    } rightButtonText:settingButtonText rightButtonCallback:^
     {
         [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:SAVEKEY_ALARM];
         [self switchToNextVC];
     }];
}

- (void) switchToNextVC
{
    if(!isMoved){
        isMoved = TRUE;
        NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:SAVEKEY_PHONE_NUMBER];
    
        BOOL agree = [[NSUserDefaults standardUserDefaults] boolForKey:SAVEKEY_AGREEMENT];
    
        NSString *recommend = [[NSUserDefaults standardUserDefaults] objectForKey:SAVEKEY_RECOMMEND];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if(number != nil && agree && recommend){
                [self performSegueWithIdentifier:@"segueMain" sender:self];
                
            }else if(number == nil){
                [self performSegueWithIdentifier:@"segueNumber" sender:self];
                
            }else if(!agree){
                [self performSegueWithIdentifier:@"segueAccept" sender:self];
            }else if(!recommend){
                [self performSegueWithIdentifier:@"segueRecommend" sender:self];
                
            }
        });
    }
}

- (void) nextMessageView
{
    if(gpsCheckDone && alarmCheckDone){
        [self switchToNextVC];
    }else if(!gpsCheckDone){
        [self checkLocationService];
    }else if(!alarmCheckDone){
        [self checkAlarm];
    }else{
        [self switchToNextVC];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LocationMangerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"locationManager didChangeAuthorizationStatus:%d", status);
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        gpsCheckDone = YES;
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        //대기중
    }
    else if (status == kCLAuthorizationStatusDenied)
    {
        gpsCheckDone = NO;
        [self nextMessageView];
    }
   
    if(gpsCheckDone && alarmCheckDone){
        [self switchToNextVC];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
