//
//  SelectNaviViewController.m
//  GoodValet
//
//  Created by hunjong choi on 13/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import "SelectNaviViewController.h"
#import <KakaoNavi/KakaoNavi.h>
#import "TMap.h"

@interface SelectNaviViewController ()

@end

@implementation SelectNaviViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (IBAction)closeClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)tmapClick:(id)sender {
    BOOL installed = [TMapTapi isTmapApplicationInstalled];
    if(installed){
        [TMapTapi invokeRoute:_targetValetData.valetName coordinate:CLLocationCoordinate2DMake(_targetValetData.valet_lat.doubleValue, _targetValetData.valet_lon.doubleValue)];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (IBAction)kakaoClick:(id)sender {
    // 목적지 생성
    KNVLocation *destination = [KNVLocation locationWithName:_targetValetData.valetName
                                                           x:_targetValetData.valet_lon
                                                           y:_targetValetData.valet_lat];
    
    // WGS84 좌표타입 옵션 설정
    KNVOptions *options = [KNVOptions options];
    options.coordType = KNVCoordTypeWGS84;
    
    // 목적지 공유 실행
    KNVParams *params = [KNVParams paramWithDestination:destination options:options];
    
    [[KNVNaviLauncher sharedLauncher] shareDestinationWithParams:params completion:^(NSError * _Nullable error) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
