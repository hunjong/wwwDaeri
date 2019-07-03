//
//  UsageDetailViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsageDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteAllButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *buttonLine;
@property (weak, nonatomic) IBOutlet UIView *selectButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *periodView;
@property (weak, nonatomic) IBOutlet UITextField *periodTextField;
@end
