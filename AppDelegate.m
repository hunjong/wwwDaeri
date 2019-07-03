//
//  AppDelegate.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 5. 18..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkManager.h"
#import "NavigationController.h"
#import "responseData.h"
#import "MainViewController.h"
#import "NavigationController.h"
#import "CommonMessageView.h"
#import "PayingViewController.h"
#import "CancelViewController.h"
#import "TerminationViewController.h"
#import "DestinationViewController.h"
#import "SideMenuViewController.h"
#import "ValetMainViewController.h"
#import "SFHFKeychainUtils.h"

@import Firebase;
@import UserNotifications;
@import AVFoundation;

@interface AppDelegate () <UNUserNotificationCenterDelegate,FIRMessagingDelegate>

@end

@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";
NSString *const responseIDKey = @"response_id";
NSString *const actionKey = @"action";
NSString *const actionAccept = @"accept";
NSString *const actionCancel = @"cancel";
NSString *const actionDone = @"done";
//check_update시
NSString *const actionWaiting = @"waiting";
NSString *const actionConnected = @"connected";

//vallet
NSString *const actionStatus = @"status"; //$STATUS = "parked" - 주차, "ready" - 출차
NSString *const statusParked = @"parked";
NSString *const statusAlready = @"already";
NSString *const actionPaynow = @"paynow";

NSString *const actionArrived = @"arrived";
NSString *const actionAlert = @"alert";

NSString *const actionValet = @"valet";
NSString *const actionReady = @"ready";
NSString *const actionChauffeur = @"chauffeur";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setUUID];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    //[FIRMessaging messaging].shouldEstablishDirectChannel = YES;
    

    
    if (@available(iOS 10.0, *)) {
        if ([UNUserNotificationCenter class] != nil) {
            // iOS 10 or later
            // For iOS 10 display notification (sent via APNS)
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
            UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
                 // ...
             }];
        } else {
            // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [application registerUserNotificationSettings:settings];
        }
    } else {
        // Fallback on earlier versions
    }
    
    [application registerForRemoteNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingChanged) name:NSUserDefaultsDidChangeNotification object:nil];
    
    //test
    //[[NSUserDefaults standardUserDefaults] setObject:@"01012345678" forKey:SAVEKEY_PHONE_NUMBER];
    
    // Override point for customization after application launch.
    [self TTS:NSLocalizedString(@"로딩시 음성 안내", @"로딩시 음성 안내")];
    
    [NSThread sleepForTimeInterval:1.0];
    NSTimeInterval expireTime = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVEKEY_POPUP];
    
    NSTimeInterval elapsedTime =  expireTime - [[NSDate date] timeIntervalSince1970];
    
    NavigationController *rootVC = (NavigationController *)[self.window rootViewController];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [rootVC performSegueWithIdentifier:@"segueIntro" sender:rootVC];
    });
    
    if(elapsedTime > 0){
        
    }else{
        
        BOOL agree = [[NSUserDefaults standardUserDefaults] boolForKey:SAVEKEY_AGREEMENT];
        NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] stringForKey:SAVEKEY_PHONE_NUMBER];
        if(!agree && phoneNumber == nil){
            //첨사용자
        }else{
        [[NetworkManager sharedInstance]intro:^(BOOL success, IntroData *introData)
         {
             if (success)
             {
                 if(!introData.ad_image_url.length){
                     
                 }else{
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [rootVC performSegueWithIdentifier:@"seguePopUp" sender:introData];
                     });
                     
                 }
                 
                 
                 //[[NSUserDefaults standardUserDefaults] setObject:@"http://www.kdss.kr" forKey:SAVEKEY_POPUP_URL];
                 //[[NSUserDefaults standardUserDefaults] setObject:@"1.0" forKey:SAVEKEY_APP_VER];
                 
                 
                 
                 /*
                  UIimageview *imageView;
                  [imageView setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"placeholder-avatar"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                  if ([[extension lowercaseString] isEqualToString:@"png"]) {
                  [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
                  } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
                  [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
                  }
                  } failure:NULL];
                  */
                 
                 /*
                  NSURL *url = [NSURL URLWithString:introData.ad_url];
                  NSData *data = [NSData dataWithContentsOfURL:url];
                  UIImage *image = [UIImage imageWithData:data];
                  [self.popUpImageView setImage:image];
                  */
                 
             }
             else
             {
                 
             }
         }];
            
        }
    }
    
    //valet
    if(launchOptions[UIApplicationLaunchOptionsLocationKey]){
        [self controlMainView:nil withAction:actionArrived withData:nil];
    }
       
    if(launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]){
        //self.isValetCenterArrived = TRUE;
        //[self checkUpdateProcess];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (![CLLocationManager locationServicesEnabled]){
        
        NSLog(@"Location Services Enabled");
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            
            UIViewController *controller = ((UINavigationController*)self.window.rootViewController).visibleViewController;
            
            CommonMessageView *messageView = [CommonMessageView createView:controller.view];
            [messageView initWithTitle:APP_NAME message:NSLocalizedString(@"정확한 위치를 파악을 위해 위치 서비스를 켜주세요.", nil) centerButtonText:NSLocalizedString(@"btn_ok", nil) centerButtonCallback:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    
    double lat = [NetworkManager sharedInstance].myLatitude;
    double lon = [NetworkManager sharedInstance].myLongitude;
    [[NSUserDefaults standardUserDefaults] setDouble:lat forKey:SAVEKEY_MY_LAT];
    [[NSUserDefaults standardUserDefaults] setDouble:lon forKey:SAVEKEY_MY_LON];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NetworkManager sharedInstance].destinatiion forKey:SAVEKEY_DESTINATION_NAME];
    
}

/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    
    if([userInfo[@"valet"] isEqualToString:@"onArrived"]){
        //valet main 에서
        [self controlMainView:nil withAction:actionArrived withData:nil];
    }
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}
 */

- (void)settingChanged
{
    if([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]){
        [FIRMessaging messaging].shouldEstablishDirectChannel = NO;
    }else{
        [FIRMessaging messaging].shouldEstablishDirectChannel = YES;
    }
    
}


// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    
    if(userInfo[responseIDKey] && userInfo[actionKey]){
        NSString *lastResponseId = [NetworkManager sharedInstance].responseId;
        if(userInfo[responseIDKey] && lastResponseId && [userInfo[responseIDKey] isEqualToString:lastResponseId]){
            [self controlMainView:userInfo[responseIDKey] withAction:userInfo[actionKey] withData:nil];
        }else{
            [self checkUpdateProcess];
        }
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionSound);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    if(userInfo[responseIDKey] && userInfo[actionKey]){
        
        NSString *lastResponseId = [NetworkManager sharedInstance].responseId;
        if(userInfo[responseIDKey] && lastResponseId && [userInfo[responseIDKey] isEqualToString:lastResponseId]){
            [self controlMainView:userInfo[responseIDKey] withAction:userInfo[actionKey] withData:nil];
        }else{
            [self checkUpdateProcess];
        }
    }
    
    completionHandler();
}

// [END ios_10_message_handling]

- (void)checkUpdateProcess
{
    
    [[NetworkManager sharedInstance]checkUpdate:^(BOOL success, CheckUpdateData *checkUpdateData)
     {
         if (success)
         {
             
             NSString *num = checkUpdateData.callcenterTel ? [NSString stringWithFormat:@"telprompt://%@",checkUpdateData.callcenterTel] : cscenter_phone_number;
             [NetworkManager sharedInstance].callCenterTel = num;
             //Y,n
             if([checkUpdateData.update_yn isEqualToString:@"Y"] ||[checkUpdateData.update_yn isEqualToString:@"y"] ){
                 
                 [self updateAlert];
             }else if(![checkUpdateData.member_yn isEqualToString:@"Y"] && ![checkUpdateData.member_yn isEqualToString:@"y"] ){
                 
                 //가입상태 날리기
                 [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:SAVEKEY_MEMBERJOIN];
             }
             
             if(!checkUpdateData.response_id || [checkUpdateData.response_id isEqualToString:@""]){
                 return ;
             }
             
             //daeri
             if(checkUpdateData.call_status == CALL_STATUS_ACCEPT){
                 [self controlMainView:checkUpdateData.response_id withAction:actionAccept withData:nil];
             }else if(checkUpdateData.call_status == CALL_STATUS_CANCEL){
                 [self controlMainView:checkUpdateData.response_id withAction:actionCancel withData:nil];
             }else if(checkUpdateData.call_status == CALL_STATUS_WAITING){
                 [self controlMainView:checkUpdateData.response_id withAction:actionWaiting withData:nil];
             }else if(checkUpdateData.call_status == CALL_STATUS_DONE){
                 [self controlMainView:checkUpdateData.response_id withAction:actionDone withData:nil];
             }else if(checkUpdateData.call_status == CALL_STATUS_CONNECTED){
                 [self controlMainView:checkUpdateData.response_id withAction:actionConnected withData:checkUpdateData];
             }
             //valet
             else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_ALERT){
                 [self controlMainView:checkUpdateData.response_id withAction:actionAlert withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_ARRIVED){
                 [self controlMainView:checkUpdateData.response_id withAction:actionArrived withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET){
                 [self controlMainView:checkUpdateData.response_id withAction:actionValet withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_STATUS){
                 [self controlMainView:checkUpdateData.response_id withAction:actionStatus withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_READY){
                 [self controlMainView:checkUpdateData.response_id withAction:actionReady withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_PAYNOW){
                 [self controlMainView:checkUpdateData.response_id withAction:actionPaynow withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_CHAUFFEUR){
                 [self controlMainView:checkUpdateData.response_id withAction:actionChauffeur withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_PARKED){
                 [self controlMainView:checkUpdateData.response_id withAction:statusParked withData:checkUpdateData];
             }else if(checkUpdateData.call_status ==  CALL_STATUS_VALET_READY){
                 [self controlMainView:checkUpdateData.response_id withAction:actionReady withData:checkUpdateData];
             }
             
         }else{
             
             
         }
     }];
}

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    [[NetworkManager sharedInstance] setFcmToken:fcmToken];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
    ////[self checkUpdateProcess];
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
    
    if(remoteMessage.appData[responseIDKey] && remoteMessage.appData[actionKey]){
        
        NSString *lastResponseId = [NetworkManager sharedInstance].responseId;
        
        if(remoteMessage.appData[responseIDKey] && lastResponseId && [remoteMessage.appData[responseIDKey] isEqualToString:lastResponseId]){
            
            [self controlMainView:remoteMessage.appData[responseIDKey] withAction:remoteMessage.appData[actionKey] withData:nil];
            
        }else{
            [self checkUpdateProcess];
        }
        
    }
    
}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
    // [FIRMessaging messaging].APNSToken = deviceToken;
    
}

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{

    if([[url scheme] isEqualToString:@"wawawachauffeur"] && [[url host] isEqualToString:@"gorouting"]){
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        self.urlParameters = [self parseUrlComponents:urlComponents.queryItems];
        UIViewController *rootVC = [self.window rootViewController];
        [self findMainViewAndUpdate:rootVC];
    }
    
    return YES;
}

- (NSDictionary *) parseUrlComponents:(NSArray *) queryItems
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSURLQueryItem *item in queryItems) {
        [dict setValue:item.value forKey:item.name];
    }
    
    return dict;
}


- (void)setUUID
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    //키체인에서 UUID를 받아온다.
    NSString *uuidKeyChain = [SFHFKeychainUtils getPasswordForUsername:bundleIdentifier
                                                        andServiceName:APP_NAME
                                                                 error:nil];
    
    //키체인에 등록 안되어있으면 생성
    if (uuidKeyChain == nil)
    {
        
        //디바이스 id 생성 및 유저디폴트에 저장
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef identifier = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        NSString *uuidString = CFBridgingRelease(identifier);
        
        //키체인에 생성된 데이터값 저장
        [SFHFKeychainUtils storeUsername:bundleIdentifier
                             andPassword:uuidString
                          forServiceName:APP_NAME
                          updateExisting:YES
                                   error:nil];
        
        uuidKeyChain = uuidString;
    }
    [NetworkManager sharedInstance].uuid = uuidKeyChain;
}

static BOOL isDaeri()
{
    return [REQUEST_TYPE isEqualToString:@"gs"];
}

static BOOL isValet()
{
    return [REQUEST_TYPE isEqualToString:@"vs"];
}

- (void) resetAction
{
    _isCallInfo = FALSE;
    _isCallCheckMade = FALSE;
    _isCallCanceled = FALSE;
    _isCallDone = FALSE;
    
    _isArrived = FALSE;
    _isAlert = FALSE;
    
    _isVallet = FALSE;
    _isStatus = FALSE;
    _isParked = FALSE;
    _isAlready = FALSE;
    _isValetCancel = FALSE;
    _isReady = FALSE;
    _isPayNow = FALSE;
    _isChauffeur = FALSE;
    _isValetWaiting = FALSE;
    _parkingValue = 0;
    _message = nil;
    _urlParameters = nil;
}

- (void)findMainViewAndUpdate:(UIViewController *)rootVC {
    if ([rootVC isKindOfClass:[NavigationController class]]) {
        
        NSArray* tempVCA = [(NavigationController *)rootVC viewControllers];
        for(UIViewController *tempVC in tempVCA)
        {
            if([tempVC isKindOfClass:[MainViewController class]])
            {
                
                MainViewController *aVC = (MainViewController*)tempVC;
                [aVC updateMainView];
                
            }else if([tempVC isKindOfClass:[ValetMainViewController class]]){
                
                ValetMainViewController *aVC = (ValetMainViewController*)tempVC;
                [aVC updateMainView];
                
            }else{
                [self closeViewControllerOnMainView:tempVC];
            }
        }
    }
}

- (void) controlMainView:(NSString *)resposeId withAction:(NSString *)action withData:(CheckUpdateData *)data
{
    [self resetAction];
    
    UIViewController *rootVC = [self.window rootViewController];
    
    //daeri
    if([action isEqualToString:actionWaiting]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.isCallInfo = TRUE;
        self.isValetWaiting = TRUE; //valet
    }else if([action isEqualToString:actionCancel]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.isCallInfo = TRUE;
        self.isCallCanceled = TRUE;
        self.isValetCancel = TRUE; //valet
    }else if([action isEqualToString:actionConnected]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.isCallCheckMade = TRUE;
    }else if([action isEqualToString:actionAccept]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.isCallCheckMade = TRUE;
    }else if([action isEqualToString:actionDone]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.isCallDone = TRUE;
    }
    //valet
    else if([action isEqualToString:actionArrived]){
        self.isArrived = TRUE;
    }else if([action isEqualToString:actionAlert]){
        self.isAlert = TRUE;
    }else if([action isEqualToString:actionValet]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.message = data.message;
        self.isVallet = TRUE;
    }else if([action isEqualToString:actionStatus]){
        
        self.isStatus = TRUE;
        NSArray *arrString= [resposeId componentsSeparatedByString: @"/"];
        NSString *newResponseId = arrString[0];
        [NetworkManager sharedInstance].responseId = newResponseId;
        NSString *newAction = arrString[1];
        if([newAction isEqualToString:statusParked]){
            self.isParked = TRUE;
        }else if([newAction isEqualToString:statusAlready]){
            self.isAlready = TRUE;
        }
        
    }else if([action isEqualToString:actionCancel]){
        
    }else if([action isEqualToString:actionReady]){
        self.isReady = TRUE;
    }else if([action isEqualToString:actionPaynow]){
        self.isPayNow = TRUE;
        
        NSArray *arrString= [resposeId componentsSeparatedByString: @"/"];
        NSString *newResponseId = arrString[0];
        [NetworkManager sharedInstance].responseId = newResponseId;
        self.parkingValue = [arrString[1] integerValue];
        
    }else if([action isEqualToString:actionChauffeur]){
        self.isChauffeur = TRUE;
    }else if([action isEqualToString:statusParked]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.isParked = TRUE;
    }else if([action isEqualToString:actionWaiting]){
        [NetworkManager sharedInstance].responseId = resposeId;
        self.isValetWaiting = TRUE;
    }
        
    [self findMainViewAndUpdate:rootVC];
    
}

- (void) closeViewControllerOnMainView:(UIViewController *)controller
{
    if([controller isKindOfClass:[PayingViewController class]]
       || [controller isKindOfClass:[CancelViewController class]]
       || [controller isKindOfClass:[TerminationViewController class]]
       || [controller isKindOfClass:[DestinationViewController class]]
       || [controller isKindOfClass:[SideMenuViewController class]])
    {
        [controller dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)updateAlert
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"dialog_notify_title",nil)
                                 message:NSLocalizedString(@"server_have_update",nil)
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:NSLocalizedString(@"btn_yes",nil)
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    NSString *iTunesLink = isDaeri() ? @"itms-apps://itunes.apple.com/app/id1434687876" : @"itms-apps://itunes.apple.com/app/id1455215095";
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"btn_no",nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                               }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) TTS:(NSString *)string
{
    AVSpeechSynthesizer * synthesizer = [[AVSpeechSynthesizer alloc]init];
    
    AVSpeechUtterance * utterance = [[AVSpeechUtterance alloc]initWithString:string];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"ko-KR"];
    utterance.rate = 0.4f;
    
    [synthesizer speakUtterance:utterance];
    
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"AVSpeechSynthesizerFacade::speakText - AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation");
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:nil];
    
    //[[AVAudioSession sharedInstance] setActive:NO error:nil];
}
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"AVSpeechSynthesizerFacade::speakText - AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation");
    [[AVAudioSession sharedInstance] setActive:NO
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:nil];
    //[[AVAudioSession sharedInstance] setActive:NO error:nil];
}

@end
