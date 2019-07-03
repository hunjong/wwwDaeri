//
//  SelectNaviViewController.h
//  GoodValet
//
//  Created by hunjong choi on 13/03/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "responseData.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectNaviViewController : UIViewController

@property (readwrite,nonatomic) valetData *targetValetData;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

NS_ASSUME_NONNULL_END
