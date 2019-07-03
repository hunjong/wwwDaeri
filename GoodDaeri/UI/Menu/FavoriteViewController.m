//
//  FavoriteViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "FavoriteViewController.h"
#import "CommonMessageView.h"
#import "FavoriteTableViewCell.h"
#import "LocalDataManager.h"
#import "DestinationDBData.h"
#import "MainViewController.h"

@interface FavoriteViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *favoriteArray;
    NSString *searchKeyword;
    NSMutableArray *deletaArray;
    NSMutableArray *selectedRowSeqs;
    NSArray *selectedRows;
    BOOL allowDeleteSelected;
}

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _textFieldBackView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _deleteSelectButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _editButton.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _buttonLine.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    //UIView *catView = [[UIView alloc] init];
    //UIImage *image = [UIImage imageNamed:@"icon_search_dark_gray"];
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    //[catView addSubview:imageView];
    //_searchTextField.rightView = catView;
    _selectButtonContainer.hidden = YES;
    
    // TODO: 디비에서 array 가져오기
    favoriteArray = [[[LocalDataManager sharedInstance] getRecentFavData:100] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [favoriteArray removeAllObjects];
    favoriteArray = [[[LocalDataManager sharedInstance] getSearchFavData:textField.text] mutableCopy];
    
    return YES;
}

- (IBAction)textFieldDidChanged:(UITextField *)theTextField
{
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([self NSStringIsValid:string]){
        return YES;
    }else{
        return NO;
    }
    
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    searchKeyword = textField.text;
}

-(BOOL) NSStringIsValid:(NSString *)checkString
{
    NSString *stricterFilterString = @"[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\u318D\u119E\u11A2\u2022\u2025a\u00B7\uFE55_-]*";
    //NSString *stricterFilterString = @"[ㄱ-ㅎㅏ-ㅣ가-힣A-Z0-9a-z-_ ]*";
    
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [stringTest evaluateWithObject:checkString];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([favoriteArray count] > 0)
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
    return [favoriteArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"favoriteCell";
    
    FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[FavoriteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    DestinationDBData *data = [favoriteArray objectAtIndex:indexPath.row];
    
    cell.favTitleLabel.text = data.title;
    cell.favAddressLabel.text = data.address;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy년 MM월 dd일"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
     NSString *theDate = [dateFormatter stringFromDate:data.rdate];
    cell.favDateLabel.text = theDate;
    
    
    if ([cell isEditing] == YES) {
        // Do something.
    }
    else {
        // Do Something else.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![tableView isEditing]){
        DestinationDBData *data = [favoriteArray objectAtIndex:indexPath.row];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segueMain" sender:data];
        });
    }
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
    
    CommonMessageView *messageView = [CommonMessageView createView:self.view];
    NSString *updateMessage = @"모두 삭제할까요?";
    NSString *noButtonText = NSLocalizedString(@"btn_no",nil);
    NSString *yesButtonText = NSLocalizedString(@"btn_yes",nil);
    
    [messageView initWithTitle:NSLocalizedString(@"dialog_notify_title",nil) message:updateMessage leftButtonText:noButtonText leftButtonCallback:^{
        
    } rightButtonText:yesButtonText rightButtonCallback:^
     {
             [[LocalDataManager sharedInstance] removeAllFavData];
             [favoriteArray removeAllObjects];
             [_tableView reloadData];
            [self editClick:nil];
         
     }];
    
}
- (IBAction)deleteSelectedClick:(id)sender {
    
   
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
         [_tableView setEditing:NO];
         [self deleteSelectedItem];
     }];
}


- (void) deleteSelectedItem
{
    selectedRows = [self.tableView indexPathsForSelectedRows];
    NSLog(@"%lu", (unsigned long)selectedRows.count);
    if(allowDeleteSelected){
        
        
        selectedRowSeqs = [NSMutableArray array];
        for (int i = 0; i < favoriteArray.count; i++) {
            
            for (int j = 0; j < selectedRows.count; j++) {
                if(((NSIndexPath *)[selectedRows objectAtIndex:j]).row == i){
                    DestinationDBData *data = [favoriteArray objectAtIndex:i];
                    [selectedRowSeqs addObject:data.seq];
                }
            }
            
            
        }
        
        
        for (int i = 0; i < selectedRowSeqs.count; i++) {
            NSString *seq = [selectedRowSeqs objectAtIndex:i];
            [[LocalDataManager sharedInstance] removeDestData:seq];
        }
        
        [favoriteArray removeAllObjects];
        favoriteArray = [[[LocalDataManager sharedInstance] getRecentFavData:100] mutableCopy];
        [_tableView reloadData];
    }
    allowDeleteSelected = FALSE;
    [self editClick:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"segueMain"])
    {
        if ([[segue destinationViewController] isKindOfClass:[MainViewController class]])
        {
            MainViewController *nextVC = [segue destinationViewController];
            nextVC.findData = sender;
            nextVC.findType = DEPATURE_TWOWAY;
        }
    }
}

- (IBAction)backClick:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"unwindMenu" sender:self];
    });
}

@end
