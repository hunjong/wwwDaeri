//
//  DestinationTableViewCell.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 8. 13..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DestinationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailAddressLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFavoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
