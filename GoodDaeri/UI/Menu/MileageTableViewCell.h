//
//  MileageTableViewCell.h
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 26..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MileageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

@end
