//
//  FavoriteTableViewCell.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 25..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *favTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *favAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *favDateLabel;

@end
