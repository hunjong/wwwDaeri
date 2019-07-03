//
//  NoticeViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "NoticeViewController.h"
#import "NoticeTableViewCell.h"

@interface NoticeViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *noticeArray;
}

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleView.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    _tableView.hidden = NO;
    _detailView.hidden = YES;
    // TODO: 서버에서 array 가져오기
    noticeArray = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numOfSections = 0;
    if ([noticeArray count] > 0)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                 = 1;
        //yourTableView.backgroundView   = nil;
        self.tableView.backgroundView = nil;
    }
    else
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = NSLocalizedString(@"search_empty_result", nil);
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [noticeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"noticeCell";
    
    NoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.dateLabel.text = @"2018년 8월 18일";
    
    // TODO: 서버와 날짜비교후 아이콘넣기
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"Icon_new.png"];
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"안녕하세요..."];
    [myString appendAttributedString:attachmentString];
    
    cell.titleLabel.attributedText = myString;
    
    //cell.title.text = [noticeArray objectAtIndex:indexPath.row];
    return cell;
}

- (NSString *)dateString
{
    NSDate *today = [NSDate date];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY년 MMM d일 EEEE"];
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"]];
    
    NSString *dateString = [dateFormat stringFromDate:today];
    
    NSLog(@"Today : %@", dateString);
    return dateString;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
