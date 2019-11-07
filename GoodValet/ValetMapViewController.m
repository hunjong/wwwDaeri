//
//  MainViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "ValetMapViewController.h"
#import "NetworkManager.h"
#import "DestinationTabViewController.h"
#import "DestinationMapViewController.h"
#import "DestinationViewController.h"
#import "FavoriteViewController.h"
#import "CommonMessageView.h"
#import "responseData.h"
#import "PayingViewController.h"
#import "CancelViewController.h"
#import "TerminationViewController.h"
#import "NavigationController.h"
#import "AppDelegate.h"



@interface ValetMapViewController () <TMapViewDelegate,TMapGpsManagerDelegate>
{
    IBOutlet UIView *valetListOverlayView;
    __weak IBOutlet UIView *valetListTableAreaView;
    __weak IBOutlet UITableView *valetListTableView;
    TMapView* _mapView;
    CLLocationManager *locationManager;
    CGRect routeViewAreaFrame;
    BOOL isMyLocationSet;
    double latestMyLat;
    double latestMyLon;
    TMapMarkerItem *depatureMarker;
    TMapMarkerItem *destinationMarker;
    NSInteger optionDistance;
    NSInteger optionCost;
    PAYMENT_TYPE payMethod;
    CAR_TYPE carType;
    NSInteger optionMileage;
    NSString *response_id;
    BOOL useMileage;
    NSTimer *driverTimer;
    NSTimer *locationTimer;
    NSInteger currentZoomLevel;
    CGRect guideViewFrame;
    BOOL isTextFieldClear;
    BOOL isScrollMapEnable;
}

@end


@implementation ValetMapViewController

//int DEFAULT_COST = 10000;
//int MIN_COST = 6000;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createMapView];
}


- (void) initialState
{
    [_mapView removeTMapMarkerItemID:@"me_icon"];
    [_mapView removeTMapMarkerItemID:@"pin_red2"];
    [_mapView removeTMapMarkerItemID:@"pin_gray2"];
    [_mapView removeTMapMarkerItemID:@"chauffeur2"];
    isMyLocationSet = FALSE;
    destinationMarker = nil;
    depatureMarker = nil;
    //wayPointMarker = nil;
    //driverMarker = nil;
    [_mapView removeAllTMapMarkerItems];
    [_mapView removeTMapPath];
    _mapView.zoomLevel = currentZoomLevel; //줌레벨유지
    [_mapView setTrackingMode:TRUE];
    [_mapView setSightVisible:FALSE];
    if(latestMyLat != 0 && latestMyLon != 0){
        TMapPoint *point = [[TMapPoint alloc] initWithLon:latestMyLon
                                                      Lat:latestMyLat];
        [_mapView setCenterPoint:point];
        [self setDepatureLocation:point];
    }
}



#pragma mark - TMAP

- (void)createMapView
{
    _mapView = [[TMapView alloc] initWithFrame:self.view.bounds];
    [_mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_mapView setDelegate:self]; // 지도이벤트 델리게이트 연결
    [_mapView setGpsManagersDelegate:self];
    [_mapView setSKTMapApiKey:TMAP_APPKEY];     // 발급 받은 apiKey 설정
    [self.view addSubview:_mapView];
    [_mapView setTrackingMode:TRUE];
    [_mapView setSightVisible:FALSE];
    [_mapView setZoomLevel:15];
    latestMyLat = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LAT];
    latestMyLon = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_MY_LON];
    if(latestMyLat != 0 && latestMyLon != 0){
        TMapPoint *point = [[TMapPoint alloc]initWithLon:latestMyLon Lat:latestMyLat];
        [_mapView setCenterPoint:point];
        [self setDepatureLocation:point];
        
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
    [self setDepatureLocation:TMP];
    isMyLocationSet = TRUE;
    [_mapView setTrackingMode:FALSE];
    [_mapView setSightVisible:FALSE];
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
    //NSLog(@"zoomLevel: %d point: %@", zoomLevel, mapPoint);
    currentZoomLevel = zoomLevel;
}

- (void)onDidEndScrollWithZoomLevel:(NSInteger)zoomLevel centerPoint:(TMapPoint*)mapPoint
{
    //NSLog(@"zoomLevel: %d point: %@", (int)zoomLevel, mapPoint);
    //    NSLog(@"trackingMode %d", [_mapView getIsTracking]);
    
    if(isScrollMapEnable){
        double lat = [NetworkManager sharedInstance].myLatitude;
        double lon = [NetworkManager sharedInstance].myLongitude;
        if(!isMyLocationSet && lat != latestMyLat && lon != latestMyLon){
            NSLog(@"changeLocation %d", [_mapView getIsTracking]);
            latestMyLat = [NetworkManager sharedInstance].myLatitude;
            latestMyLon = [NetworkManager sharedInstance].myLongitude;
            TMapPoint *point = [[TMapPoint alloc] initWithLon:latestMyLon Lat:latestMyLat];
            [self setDepatureLocation:point];
        }
    }
}

- (void)onClusteringMarkerClick:(NSArray*)markerItems screenPoint:(CGPoint)point
{
    
}

- (UIView*)mapView:(TMapView *)mapView viewForCalloutView:(TMapMarkerItem2*)markerItem
{
    
    
    
    //개발중
    return nil;
}

#pragma mark - Marker

- (BOOL) checkPolyLineMake
{
     if(depatureMarker && destinationMarker){
         TMapPathData* path = [[TMapPathData alloc] init];
         TMapPolyLine *polyLine = [path findPathDataWithType:CAR_PATH startPoint:depatureMarker.getTMapPoint endPoint:destinationMarker.getTMapPoint];
         if(polyLine){
         [_mapView addTMapPath:polyLine];
         [self centerZoomToPath:polyLine];
         optionDistance = polyLine.getDistance;
         return TRUE;
         }
     }
    
    return FALSE;
}

- (void) setDepatureLocation:(TMapPoint * )TMP
{
     if(TMP.getLatitude > 0 && TMP.getLongitude > 0){
         [self->locationTimer invalidate];
         self->locationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(depatureMarkerPolyLineAndCall:) userInfo:TMP repeats:NO];
     }
}

- (void) depatureMarkerPolyLine:(NSTimer *)timer
{
     TMapPoint *TMP = timer.userInfo;
     NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:TMP];
     if(!address){
     isMyLocationSet = FALSE;
     [_mapView setTrackingMode:TRUE];
     [_mapView setSightVisible:FALSE];
     }
     //[_routeSearchView setDeparture:address];
     NSDecimalNumber *lat =[[NSDecimalNumber alloc]initWithDouble:TMP.getLatitude];
     NSDecimalNumber *lon =[[NSDecimalNumber alloc]initWithDouble:TMP.getLongitude];
     [self setDepatureMarker:lon lat:lat title:address];
    
     //////[_mapView setTMapPathIconStart:depatureMarker end:destinationMarker pass:wayPointMarker];
     
    [self checkPolyLineMake];
    [_mapView setTrackingMode:FALSE];
    [_mapView setSightVisible:FALSE];
    
}


- (void) centerZoomToPath:(TMapPolyLine *)polyLine
{
     double ltLat, ltLon;
     double rbLat, rbLon;
     
     // set default;
     ltLat = depatureMarker != nil ? depatureMarker.getTMapPoint.getLatitude : _mapView.getCenterPoint.getLatitude;
     ltLon = depatureMarker != nil ? depatureMarker.getTMapPoint.getLongitude : _mapView.getCenterPoint.getLongitude;
     rbLat = depatureMarker != nil ? depatureMarker.getTMapPoint.getLatitude : _mapView.getCenterPoint.getLatitude;
     rbLon = depatureMarker != nil ? depatureMarker.getTMapPoint.getLongitude : _mapView.getCenterPoint.getLongitude;
     
     NSMutableArray *points = [NSMutableArray new];
     
     if (depatureMarker != nil) [points addObject:depatureMarker.getTMapPoint];
     if (destinationMarker != nil) [points addObject:destinationMarker.getTMapPoint];
     //if (wayPointMarker != nil) [points addObject:wayPointMarker.getTMapPoint];
     if (polyLine != nil) [points addObjectsFromArray:polyLine.getLinePoint];
     
     for (TMapPoint *p in points) {
     if (p.getLatitude < ltLat) ltLat = p.getLatitude;
     else if (p.getLatitude > rbLat) rbLat = p.getLatitude;
     if (p.getLongitude < ltLon) ltLon = p.getLongitude;
     else if (p.getLongitude > rbLon) rbLon = p.getLongitude;
     }
     
     TMapPoint *leftTop = [[TMapPoint alloc] initWithLon:ltLon Lat:ltLat];
     TMapPoint *rightBottom = [[TMapPoint alloc] initWithLon:rbLon Lat:rbLat];
     
     //[_mapView zoomToTMapPointLeftTop:leftTop rightBottom:rightBottom];
     
     //[_mapView showFullPath:polyLine.getLinePoint];
     // moveCenterPoint
     double cLat = (ltLat + rbLat) / 2.0;
     double cLon = (ltLon + rbLon) / 2.0;
     TMapPoint *center = [[TMapPoint alloc] initWithLon:cLon Lat:cLat];
     [_mapView setCenterPoint:center];
     
     double llon = rbLon - ltLon;
     double llat = rbLat - ltLat;
     
     double least= llon > llat ? llat:llon;
     
     [_mapView zoomToLatSpan:least*2.5 lonSpan:least*2.5];
    
}


- (void) setDepatureMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title
{
     TMapPoint* mapPoint = [[TMapPoint alloc] initWithLon:[lon doubleValue] Lat:[lat doubleValue]];
     if(depatureMarker == nil){
     depatureMarker = [[TMapMarkerItem alloc] init] ;
     [depatureMarker setIcon:[self imageWithHalf:[UIImage imageNamed:@"me_icon"]]];
     }
     [depatureMarker setTMapPoint:mapPoint];
     //if(title)
     //[depatureMarker setName:title];
     
     [_mapView addTMapMarkerItemID:@"me_icon" Marker:depatureMarker];
}

- (void) setDestinationMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title
{
     TMapPoint* mapPoint = [[TMapPoint alloc] initWithLon:[lon doubleValue] Lat:[lat doubleValue]];
     if(destinationMarker == nil){
     destinationMarker = [[TMapMarkerItem alloc] init] ;
     [destinationMarker setIcon:[self imageWithHalf:[UIImage imageNamed:@"pin_red2"]]];
     }
     [destinationMarker setTMapPoint:mapPoint];
     //if(title)
     //[destinationMarker setName:title];
     
     [_mapView addTMapMarkerItemID:@"pin_red2" Marker:destinationMarker];
}

- (UIImage *)imageWithHalf:(UIImage *)image
{
    CGSize size = image.size;
    size.width = size.width/2;
    size.height = size.height/2;
    
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end

