//
//  ValetListViewController.m
//  GoodValet
//
//  Created by Choi Hunjong on 2018. 10. 20..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import "ValetListViewController.h"
#import "DestinationDBData.h"
#import "LocalDataManager.h"
#import "CommonMessageView.h"
#import "ValetMainViewController.h"
#import "responseData.h"
#import "ValetListTableCell.h"
#import "NetworkManager.h"

@interface ValetListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *destinationArray;
    NSArray *selectedRows;
    BOOL allowDeleteSelected;
    NSInteger rowNo;
}
@end

@implementation ValetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CustomCell"];
    
    //self.buttonLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    //self.deleteSelectButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    //self.editButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([destinationArray count] > 0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                 = 1;
        //yourTableView.backgroundView   = nil;
        self.tableView.backgroundView = nil;
        
        ////self.editButton.hidden = NO;
    }
    else
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = NSLocalizedString(@"search_empty_result", nil);
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        ////self.editButton.hidden = YES;
    }
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return destinationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //거리 전화(버튼) 이름 주소 가격 상세보기(버튼)
    ValetListTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ValetListCell" forIndexPath:indexPath];
    
    /*
     
     @property (readwrite) NSString *valet_center;
     @property (readwrite) NSString *valet_tel;
     @property (readwrite) NSInteger valet_value;
     @property (readwrite) NSString *valet_insurance;
     @property (readwrite) NSString *valet_addr;
     @property (readwrite) NSDecimalNumber *valet_lat;
     @property (readwrite) NSDecimalNumber *valet_lon;
     @property (readwrite) NSString *response_id;
     @property (readwrite) NSString *valet_parking_times;
     @property (readwrite) NSString *driverTel;
     @property (readwrite) NSString *valetColor;
     @property (readwrite) NSString *valetName;
     @property (readwrite) NSString *valetPhotoUrl;
     */
    
    valetData *data = [destinationArray objectAtIndex:indexPath.row];
    cell.addressLabel.text = data.valet_addr;
    cell.costLabel.text = [NSString stringWithFormat:@"%ld",(long)data.valet_value];
    cell.nameLabel.text = data.valet_center;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%ld",(long)[self distance:data]];
    [cell.callButton addTarget:self action:@selector(callButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.detailButton addTarget:self action:@selector(detailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    ////DestinationDBData *data = [destinationArray objectAtIndex:indexPath.row];
    /*
    cell.addressLabel.text = data.title;
    cell.detailAddressLabel.text = data.address;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2fkm",[data getDistanceFromHere]/ 1000.0];
    if(_type != FAVORITE_DESTINATION){
        [cell.addFavoriteButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.addFavoriteButton.tag = indexPath.row;
    }else{
        cell.addFavoriteButton.hidden = YES;
        CGRect newRect = cell.addressLabel.frame;
        newRect.size.width = cell.frame.size.width - newRect.origin.x * 2;
        cell.addressLabel.frame = newRect;
    }
     */
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![tableView isEditing]){
        rowNo = indexPath.row;
        //DestinationDBData *data = [destinationArray objectAtIndex:rowNo];
        
        
        
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    [self.backViewController performSegueWithIdentifier:@"unwindMain" sender:data];
        //});
    }
}

-(void)callButtonClicked:(UIButton*)sender
{
    //개발중
    valetData *_targetValetData;
    NSString *tel = [NSString stringWithFormat:@"telprompt://%@",_targetValetData.valet_tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tel]];
}

-(void)detailButtonClicked:(UIButton*)sender
{
    
    
}
-(void)addButtonClicked:(UIButton*)sender
{
    DestinationDBData *data = [destinationArray objectAtIndex:sender.tag];
    BOOL isInserted = [[LocalDataManager sharedInstance] pushRecentFavData:data];
    if(isInserted){
        sender.enabled = NO;
    }
    
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    [messageView initWithNoticeMessage:NSLocalizedString(isInserted?@"usage_favorites_added":@"usage_favorites_exist", nil) centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:^{
        if(self.presentationController && [self.presentationController isKindOfClass:[DestinationViewController class]]){
            [((DestinationViewController *)self.presentationController) reloadFavorite];
        }
        
    }];
    
}

- (void)updateListView:(valetListData *)listData
{
    destinationArray = listData.valetList;
    [self.tableView reloadData];
}

- (double) distance:(valetData *)data
{
    //개발중
    double driverLat = [data.valet_lat doubleValue];
    double driverLon = [data.valet_lon doubleValue];
    double myLat = [NetworkManager sharedInstance].myLatitude;
    double myLon = [NetworkManager sharedInstance].myLongitude;
    
    CLLocation *driverLocation = [[CLLocation alloc] initWithLatitude:driverLat longitude:driverLon];
    CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:myLat longitude:myLon];
    CLLocationDistance distance = [driverLocation distanceFromLocation:myLocation];
    NSLog(@"나의거리: %f",distance);
    return distance;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"unwindMain"])
    {
        if ([[segue destinationViewController] isKindOfClass:[ValetMainViewController class]])
        {
            ValetMainViewController *nextVC = [segue destinationViewController];
            //nextVC.findData = sender;
        }
    }
}


@end

