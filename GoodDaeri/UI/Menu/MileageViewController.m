//
//  MileageViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "MileageViewController.h"
#import "MileageTableViewCell.h"
#import "NetworkManager.h"
#import "responseData.h"
#import "CommonMessageView.h"

@interface MileageViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *mileageArray;
    NSString *now;
    NSString *before;
    NSInteger period;
}
@end

@implementation MileageViewController

- (void)loadMileageList {
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:SAVEKEY_MILEAGE_SEARCH_MONTH] == 0){
        period = DEFAULT_START_MONTH;
    }else{
        period = [[NSUserDefaults standardUserDefaults] integerForKey:SAVEKEY_MILEAGE_SEARCH_MONTH];
    }
    
    switch (period) {
        case 6:
            _periodTextField.text = NSLocalizedString(@"history_search_range1",nil);
            break;
        case 12:
            _periodTextField.text = NSLocalizedString(@"history_search_range2",nil);
            break;
        case 24:
            _periodTextField.text = NSLocalizedString(@"history_search_range3",nil);
            break;
        case 36:
            _periodTextField.text = NSLocalizedString(@"history_search_range4",nil);
            break;
        default:
            break;
    }
    
    NSDate *today = [[NSDate alloc] init];
    NSLog(@"%@", today);
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:-period];
    NSDate *month3 = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    NSLog(@"%@", month3);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    now = [formatter stringFromDate:today];
    
    before = [formatter stringFromDate:month3];
    
    [[NetworkManager sharedInstance] mileageHistory:before end:now order_type:HISTORY_ORDER_TYPE_LIST order_idxs:nil complete:^(BOOL success, mileageHistoryData *data){
        if(success){
            self->mileageArray = data.mileageList;
            [self->_tableView reloadData];
        }else{
            self->mileageArray = [NSMutableArray new];
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _deleteSelectButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _editButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _buttonLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _periodView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _periodTextField.layer.cornerRadius = 3;
    _periodTextField.layer.borderColor = [[UIColor blueColor] CGColor];
    _periodTextField.layer.borderWidth = 1;
    _periodTextField.rightViewMode = UITextFieldViewModeAlways;
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_right_arrow_w"]];
    icon.frame = CGRectMake(0, 0, icon.frame.size.width/2, icon.frame.size.height/2);
    _periodTextField.rightView = icon;
    _periodTextField.textAlignment = NSTextAlignmentRight;
    [self loadMileageList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([mileageArray count] > 0)
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
    return [mileageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"mileageCell";
    
    MileageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[MileageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    NSString *title= ((mileageData *)[mileageArray objectAtIndex:indexPath.row]).m_list_title;
    NSString *dateTime = ((mileageData *)[mileageArray objectAtIndex:indexPath.row]).m_list_day;
    NSInteger *value = ((mileageData *)[mileageArray objectAtIndex:indexPath.row]).m_list_value;

    cell.contentLabel.text = title;
    cell.pointLabel.text = [NSString stringWithFormat:@"%d",value];
    cell.dateLabel.text = dateTime;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did end editing");
    
}

- (IBAction)editClick:(id)sender {
    //[_tableView setEditing:YES animated:YES];
    if(self.selectButtonContainer.isHidden){
        self.selectButtonContainer.hidden = NO;
        [self.editButton setTitle:NSLocalizedString(@"btn_cancel",nil) forState:UIControlStateNormal];
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = tableFrame.size.height - _selectButtonContainer.frame.size.height;
        self.tableView.frame = tableFrame;
        [_tableView setEditing:YES];
        [_tableView setAllowsMultipleSelection:YES];
    }else{
        self.selectButtonContainer.hidden = YES;
        [self.editButton setTitle:NSLocalizedString(@"search_bottom_cmd",nil) forState:UIControlStateNormal];
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = tableFrame.size.height + _selectButtonContainer.frame.size.height;
        self.tableView.frame = tableFrame;
        [_tableView setEditing:NO];
        [_tableView setAllowsMultipleSelection:NO];
    }
}
- (IBAction)deleteAllClick:(id)sender {
    
    NSMutableString *ids = [NSMutableString new];
    for (int i = 0; i < mileageArray.count; i++) {
        [ids appendString:[NSString stringWithFormat:i == mileageArray.count-1? @"%d":@"%d|",i+1]];
    }
    
    [[NetworkManager sharedInstance] mileageHistory:before end:now order_type:HISTORY_ORDER_TYPE_DELETE order_idxs:ids complete:^(BOOL success, mileageHistoryData *data){
        
        if(success){
            [mileageArray removeAllObjects];
            [_tableView setAllowsMultipleSelection:NO];
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:@"삭제되었습니다." centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:nil];
            _editButton.hidden = NO;
        }
    }];
    
}
- (IBAction)deleteSelectedClick:(id)sender {
    
    NSMutableString *ids = [NSMutableString new];
    NSArray<NSIndexPath *> *rows = [_tableView indexPathsForSelectedRows];
    for(int i = 0; i <rows.count ; i++){
        NSIndexPath *index = [rows objectAtIndex:i];
        [mileageArray removeObjectAtIndex:index.row];
        [ids appendString:[NSString stringWithFormat:i == rows.count-1? @"%d":@"%d|",i+1]];
    }
    
    [[NetworkManager sharedInstance] mileageHistory:before end:now order_type:HISTORY_ORDER_TYPE_DELETE order_idxs:ids complete:^(BOOL success, mileageHistoryData *data){
        
        if(success){
            [_tableView setAllowsMultipleSelection:NO];
            CommonMessageView *messageView = [CommonMessageView createView:self.view];
            [messageView initWithNoticeMessage:@"삭제되었습니다." centerButtonText:NSLocalizedString(@"btn_ok",nil) centerButtonCallback:nil];
            _editButton.hidden = NO;
        }
    }];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)backClick:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"unwindMenu" sender:self];
    });
    
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self periodActionSheet];
    return FALSE;
}

- (void) periodActionSheet
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"history_search_bet",nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"history_search_range1",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults]setInteger:6 forKey:SAVEKEY_MILEAGE_SEARCH_MONTH];
        [self loadMileageList];
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"history_search_range2",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults]setInteger:12 forKey:SAVEKEY_MILEAGE_SEARCH_MONTH];
        [self loadMileageList];
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"history_search_range3",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults]setInteger:24 forKey:SAVEKEY_MILEAGE_SEARCH_MONTH];
        [self loadMileageList];
        //}];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"history_search_range4",nil) style:UIActionSheetStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[actionSheet dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults]setInteger:36 forKey:SAVEKEY_MILEAGE_SEARCH_MONTH];
        [self loadMileageList];
        //}];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end