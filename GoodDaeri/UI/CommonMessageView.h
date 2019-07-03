//
//  CommonMessageView.h
//  PCO2018SmartNavi
//
//  Created by m4nc on 2017. 9. 4..
//  Copyright © 2017년 m4nc. All rights reserved.
//
//  * 공통 팝업. 보여주는 내용에 따라 height값이 가변

#import <UIKit/UIKit.h>

static int MESSAGE_VIEW_TAG_GPS_ERROR = 1;

@interface CommonMessageView : UIView

+ (CommonMessageView*) createView:(UIView*)target;
+ (CommonMessageView*) createView:(UIView*)target clearExist:(BOOL)clearExist;
+ (CommonMessageView*) createDebugPopup:(NSString*)message target:(UIView*)target;

-(void) initWithMessage:(NSString*)message centerButtonText:(NSString*)centerButtonText centerButtonCallback:(SimpleCallback)centerCallback;

-(void) initWithNoticeMessage:(NSString*)message centerButtonText:(NSString*)centerButtonText centerButtonCallback:(SimpleCallback)centerCallback;

-(void) initWithTitle:(NSString*)title message:(NSString*)message centerButtonText:(NSString*)centerButtonText centerButtonCallback:(SimpleCallback)centerCallback;

-(void) initWithTitle:(NSString*)title message:(NSString*)message leftButtonText:(NSString*)leftButtonText leftButtonCallback:(SimpleCallback)leftCallback rightButtonText:(NSString*)rightButtonText rightButtonCallback:(SimpleCallback)rightCallback;

-(void) initWithMainTitle:(NSString*)mainTitle subTitle:(NSString*)subtitle message:(NSString*)message leftButtonText:(NSString*)leftButtonText leftButtonCallback:(SimpleCallback)leftCallback rightButtonText:(NSString*)rightButtonText rightButtonCallback:(SimpleCallback)rightCallback;

-(void) initWithMessage:(NSString*)message leftButtonText:(NSString*)leftButtonText leftButtonCallback:(SimpleCallback)leftCallback rightButtonText:(NSString*)rightButtonText rightButtonCallback:(SimpleCallback)rightCallback;

@end
