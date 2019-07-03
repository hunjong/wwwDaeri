//
//  ValetListViewController.h
//  GoodValet
//
//  Created by Choi Hunjong on 2018. 10. 20..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>
@class valetListData;

NS_ASSUME_NONNULL_BEGIN

@interface ValetListViewController : UITableViewController


- (void)updateListView:(valetListData *)listData;
@end

NS_ASSUME_NONNULL_END
