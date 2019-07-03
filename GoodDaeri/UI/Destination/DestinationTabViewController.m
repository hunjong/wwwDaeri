//
//  DestinationTabViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 8. 13..
//  Copyright © 2018년 GoodDaeri. All rights reserved.
//

#import "DestinationTabViewController.h"
#import "DestinationTableViewCell.h"
#import "LocalDataManager.h"
#import "DestinationDBData.h"
#import "CommonMessageView.h"
#import "MainViewController.h"
#import "TMap.h"

@interface DestinationTabViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *destinationArray;
    NSArray *selectedRows;
    NSMutableArray *selectedRowSeqs;
    BOOL allowDeleteSelected;
    NSInteger rowNo;
}
@end

@implementation DestinationTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.buttonLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    self.deleteSelectButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    self.editButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    self.editMenuContainer.hidden = YES;
    [self loadArrayData];
    if(_isHideEditButton){
        [self hideEditButton];
    }
}

- (void) loadArrayData
{
    if(self.type == FAVORITE_DESTINATION){
        destinationArray = [[[LocalDataManager sharedInstance] getRecentFavData:100] mutableCopy];
    }else if(self.type == RECENT_DESTINATION){
        destinationArray = [[[LocalDataManager sharedInstance] getRecentDestData:100] mutableCopy];
    }else{
        destinationArray = _searchDestinationArray;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteAllClick:(id)sender {
    
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    NSString *updateMessage = @"모두 삭제할까요?";
    NSString *noButtonText = NSLocalizedString(@"btn_no",nil);
    NSString *yesButtonText = NSLocalizedString(@"btn_yes",nil);
    
    [messageView initWithTitle:NSLocalizedString(@"dialog_notify_title",nil) message:updateMessage leftButtonText:noButtonText leftButtonCallback:^{
        
    } rightButtonText:yesButtonText rightButtonCallback:^
     {
         if(self.type == RECENT_DESTINATION){
             [[LocalDataManager sharedInstance] removeAllDestData];
             [destinationArray removeAllObjects];
             [_tableView reloadData];
         }else if(self.type == FAVORITE_DESTINATION){
             [[LocalDataManager sharedInstance] removeAllFavData];
             [destinationArray removeAllObjects];
             [_tableView reloadData];
         }
         [self editClick:nil];
     }];
    
    
}
- (IBAction)selectClick:(id)sender {
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    NSString *updateMessage = @"선택한 항목을 삭제할까요?";
    NSString *noButtonText = NSLocalizedString(@"btn_no",nil);
    NSString *yesButtonText = NSLocalizedString(@"btn_yes",nil);
    
    [messageView initWithTitle:NSLocalizedString(@"dialog_notify_title",nil) message:updateMessage leftButtonText:noButtonText leftButtonCallback:^{
        allowDeleteSelected = NO;
        [_tableView setEditing:NO];
    } rightButtonText:yesButtonText rightButtonCallback:^
     {
         allowDeleteSelected = YES;
         [self deleteSelected];
         [_tableView setEditing:NO];
         
     }];
}

-(void) deleteSelected
{
    selectedRows = [self.tableView indexPathsForSelectedRows];
    NSLog(@"%lu", (unsigned long)selectedRows.count);
    if(allowDeleteSelected){
        
        selectedRowSeqs = [NSMutableArray array];
            
        for (int j = 0; j < selectedRows.count; j++) {
            NSInteger row = ((NSIndexPath *)[selectedRows objectAtIndex:j]).row;
                DestinationDBData *data = [destinationArray objectAtIndex:row];
                [selectedRowSeqs addObject:data.seq];
            
        }
        
        
        
        if(_type == FAVORITE_DESTINATION){
            
            for (int i = 0; i < selectedRowSeqs.count; i++) {
                NSString *seq = [selectedRowSeqs objectAtIndex:i];
                [[LocalDataManager sharedInstance] removeFavData:seq];
            }
            
            
        }else if(_type == RECENT_DESTINATION){
            
            for (int i = 0; i < selectedRowSeqs.count; i++) {
                NSString *seq = [selectedRowSeqs objectAtIndex:i];
                [[LocalDataManager sharedInstance] removeDestData:seq];
            }
        }
        
        [destinationArray removeAllObjects];
        [self loadArrayData];
        [_tableView reloadData];
    }
    allowDeleteSelected = FALSE;
    [self editClick:nil];
}

- (IBAction)editClick:(id)sender {
    if(self.editMenuContainer.isHidden){
        self.editMenuContainer.hidden = NO;
        [self.editButton setTitle:NSLocalizedString(@"btn_cancel",nil) forState:UIControlStateNormal];
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = tableFrame.size.height - _editMenuContainer.frame.size.height;
        self.tableView.frame = tableFrame;
        [_tableView setEditing:YES];
        [_tableView setAllowsMultipleSelection:YES];
    }else{
        self.editMenuContainer.hidden = YES;
        [self.editButton setTitle:NSLocalizedString(@"search_bottom_cmd",nil) forState:UIControlStateNormal];
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = tableFrame.size.height + _editMenuContainer.frame.size.height;
        self.tableView.frame = tableFrame;
        [_tableView setEditing:NO];
        [_tableView setAllowsMultipleSelection:NO];
    }
}

- (void) hideEditButton
{
    self.editMenuContainer.hidden = YES;
    self.editContainer.hidden = YES;
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = tableFrame.size.height + _editMenuContainer.frame.size.height +_editContainer.frame.size.height;
    self.tableView.frame = tableFrame;
    [_tableView setEditing:NO];
    [_tableView setAllowsMultipleSelection:NO];
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
        
        self.editButton.hidden = NO;
    }
    else
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = NSLocalizedString(@"search_empty_result", nil);
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.editButton.hidden = YES;
    }
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return destinationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"destinationCell";
    
    DestinationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[DestinationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    DestinationDBData *data = [destinationArray objectAtIndex:indexPath.row];
    
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
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath { //implement the delegate method
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Update data source array here, something like [array removeObjectAtIndex:indexPath.row];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did end editing");
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![tableView isEditing]){
        rowNo = indexPath.row;
        DestinationDBData *data = [destinationArray objectAtIndex:rowNo];
        
        if(_type == SEARCH_DESTINATION){
            TMapPoint *point = [[TMapPoint alloc] initWithLon:[data.lon doubleValue] Lat:[data.lat doubleValue]];
            NSString *address = [[[TMapPathData alloc] init] convertGpsToAddressAt:point];
            data.address = address;
            [[LocalDataManager sharedInstance] pushRecentDestData:data];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.backViewController performSegueWithIdentifier:@"unwindMain" sender:data];
        });
    }
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


-(void)reload
{
    [self loadArrayData];
    [_tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"unwindMain"])
    {
        if ([[segue destinationViewController] isKindOfClass:[MainViewController class]])
        {
            MainViewController *nextVC = [segue destinationViewController];
            nextVC.findData = sender;
        }
    }
}


@end
