//
//  DestinationTabViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 8. 13..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationViewController.h"

typedef enum {
    SEARCH_DESTINATION,
    RECENT_DESTINATION,
    FAVORITE_DESTINATION,
} destinationType;

@interface DestinationTabViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *editContainer;
@property (weak, nonatomic) IBOutlet UIView *editMenuContainer;
@property (readwrite) NSMutableArray *searchDestinationArray;
@property (readwrite) destinationType type;
@property (weak, nonatomic) DestinationViewController *backViewController;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *buttonLine;
@property (weak, nonatomic) IBOutlet UIButton *deleteAllButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteSelectButton;
@property (readwrite) BOOL isHideEditButton;
- (void)reload;

@end


