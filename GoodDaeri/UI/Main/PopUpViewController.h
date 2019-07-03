//
//  PopUpViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "responseData.h"

@interface PopUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *deActivateButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *popUpImageView;

@property (readwrite) IntroData *introData;
@end
