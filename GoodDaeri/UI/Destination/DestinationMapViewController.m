//
//  DestinationMapViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 8. 19..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import "DestinationMapViewController.h"
#import "TMap.h"
#import "MainViewController.h"
#import "LocalDataManager.h"
#import "NetworkManager.h"

@interface DestinationMapViewController ()<TMapViewDelegate,TMapGpsManagerDelegate>
{
    TMapView* _mapView;
    DestinationDBData *data;
    
}
@end

@implementation DestinationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _selectButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    [self createMapView];
    [_centerIcon setImage:[UIImage imageNamed:_iconImageName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"unwindMain"])
    {
        if ([[segue destinationViewController] isKindOfClass:[MainViewController class]])
        {
            MainViewController *nextVC = [segue destinationViewController];
            nextVC.findData = sender;
        }
    }
}

- (IBAction)hereClick:(id)sender {
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma TMAP

- (void)createMapView {
    _mapView = [[TMapView alloc] initWithFrame:self.mapContainer.bounds];
    [_mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_mapView setDelegate:self]; // 지도이벤트 델리게이트 연결
    [_mapView setGpsManagersDelegate:self];
    [_mapView setSKTMapApiKey:TMAP_APPKEY];     // 발급 받은 apiKey 설정
    [self.mapContainer addSubview:_mapView];
    double myLat = [NetworkManager sharedInstance].myLatitude;
    double myLon = [NetworkManager sharedInstance].myLongitude;
    if(myLat != 0 && myLon != 0){
        TMapPoint *point = [[TMapPoint alloc]initWithLon:myLon Lat:myLat];
        [_mapView setCenterPoint:point];
        [_mapView setZoomLevel:15];
    }
}

//클릭이벤트
- (void)onClick:(TMapPoint *)TMP
{
    NSLog(@"onClick: %@", TMP);
}


//롱클릭이벤트
- (void)onLongClick:(TMapPoint*)TMP
{
    NSLog(@"onLongClick: %@", TMP);
}

//오브젝트(marker, polyline, polygon) 클릭이벤트
- (void)onCustomObjectClick:(TMapObject*)obj
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"TMapMarkerItem clicked:%@", obj);
    }
}

//오브젝트 롱클릭이벤트
- (void)onCustomObjectLongClick:(TMapObject*)obj
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"TMapMarkerItem clicked:%@", obj);
    }
}

- (void)onCustomObjectClick:(TMapObject*)obj screenPoint:(CGPoint)point
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"onCustomObjectClick :%@ screenPoint:{%f, %f}", obj, point.x, point.y);
    }
}

- (void)onCustomObjectLongClick:(TMapObject*)obj screenPoint:(CGPoint)point
{
    if([obj isMemberOfClass:[TMapMarkerItem class]])
    {
        NSLog(@"onCustomObjectLongClick :%@ screenPoint:{%f, %f}", obj, point.x, point.y);
    }
}

- (void)onDidScrollWithZoomLevel:(NSInteger)zoomLevel centerPoint:(TMapPoint*)mapPoint
{
    NSLog(@"zoomLevel: %d point: %@", zoomLevel, mapPoint);
}

- (void)onDidEndScrollWithZoomLevel:(NSInteger)zoomLevel centerPoint:(TMapPoint*)mapPoint
{
    NSLog(@"zoomLevel: %d point: %@", (int)zoomLevel, mapPoint);
        NSLog(@"trackingMode %d", [_mapView getIsTracking]);
    
    
    NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:mapPoint];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = interval;
    DestinationDBData *data = [DestinationDBData new];
    data.seq = [NSString stringWithFormat:@"%ld",(long)time];
    data.title = address;
    data.address = address;
    data.lat = [[NSDecimalNumber alloc] initWithDouble:mapPoint.getLatitude];
    data.lon = [[NSDecimalNumber alloc] initWithDouble:mapPoint.getLongitude];
    _positionLabel.text = address;
    NSLog(@"address: %@", address);
}


- (IBAction)selectClick:(id)sender {
    
    if(data == nil){
        
        NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:_mapView.getCenterPoint];
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        NSInteger time = interval;
        
        
        data = [DestinationDBData new];
        data.seq = [NSString stringWithFormat:@"%ld",(long)time];
        data.title = address;
        data.address = address;
        data.lat = [[NSDecimalNumber alloc] initWithDouble:_mapView.getCenterPoint.getLatitude];
        data.lon = [[NSDecimalNumber alloc] initWithDouble:_mapView.getCenterPoint.getLongitude];
        
        NSLog(@"address: %@", address);
        _positionLabel.text = address;
    }
   
    if(data != nil){
        [[LocalDataManager sharedInstance] pushRecentDestData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.backViewController performSegueWithIdentifier:@"unwindMain" sender:data];
        });
        
        //DestinationViewController에서 dismissViewController
    }
}

@end
