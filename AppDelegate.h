//
//  AppDelegate.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 5. 18..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface AppDelegate : UIResponder <UIApplicationDelegate,AVSpeechSynthesizerDelegate>

@property (strong, nonatomic) UIWindow *window;

//Daeri
@property (readwrite) BOOL isCallInfo;
@property (readwrite) BOOL isCallCheckMade;
@property (readwrite) BOOL isCallCanceled;
@property (readwrite) BOOL isCallDone;
@property (readwrite) NSDictionary *urlParameters;

//Valet
@property (readwrite) BOOL isArrived;
@property (readwrite) BOOL isAlert;
@property (readwrite) BOOL isVallet;
@property (readwrite) BOOL isStatus;
@property (readwrite) BOOL isParked;
@property (readwrite) BOOL isAlready;
@property (readwrite) BOOL isValetCancel;
@property (readwrite) BOOL isReady;
@property (readwrite) BOOL isPayNow;
@property (readwrite) BOOL isChauffeur;
@property (readwrite) BOOL isValetWaiting;
@property (readwrite) NSInteger parkingValue;
@property (readwrite) NSString* message;

@property (readwrite) BOOL isValetCenterArrived;

- (void) TTS:(NSString *)string;
- (void) resetAction;
@end

