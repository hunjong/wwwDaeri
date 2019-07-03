//
//  DestinationViewController.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAPSPageMenu.h"

@interface DestinationViewController : UIViewController

typedef enum FIND_DESTINATION_TYPE {
    DESTINATION_TWOWAY,
    DEPATURE_TWOWAY,
    DESTINATION_THREEWAY,
    DEPATURE_THREEWAY,
    WAYPOINT_THREEWAY
} FIND_DESTINATION_TYPE;


@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteAllButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteSelectedButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchIcon;
@property (weak, nonatomic) IBOutlet UIView *pageMenuContainer;
@property (nonatomic) CAPSPageMenu *pagemenu;
@property (readwrite, nonatomic)FIND_DESTINATION_TYPE type;

@property (weak, nonatomic) IBOutlet UIView *searchContainer;

- (void) reloadFavorite;

@end
