//
//  WebContentsViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 8. 5..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebContentsViewController : UIViewController

@property WEB_CONTENTS_TYPE type;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end
