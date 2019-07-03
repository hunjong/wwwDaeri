//
//  ValetListTableCell.h
//  GoodValet
//
//  Created by hunjong choi on 21/04/2019.
//  Copyright © 2019 GoodDaeri. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ValetListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@end

NS_ASSUME_NONNULL_END
