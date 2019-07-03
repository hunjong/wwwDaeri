//
//  MainViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationDBData.h"
#import "DestinationViewController.h"
#import "DriverWaitingView.h"
#import "DriverMovingView.h"
#import "TMap.h"
@class valetListData;

@interface ValetMapViewController : UIViewController

- (void)updateMapView:(valetListData *)listData;

- (void) initialState;
- (BOOL) checkPolyLineMake;
- (void) setDepatureLocation:(TMapPoint * )TMP;
- (void) centerZoomToPath:(TMapPolyLine *)polyLine;
- (void) setDepatureMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title;
- (void) setDestinationMarker:(NSDecimalNumber *)lon lat:(NSDecimalNumber *)lat title:(NSString *)title;

@end
