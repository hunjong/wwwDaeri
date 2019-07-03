//
//  DestinationViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "DestinationViewController.h"
#import "ReachabilityViewController.h"
#import "DestinationTabViewController.h"
#import "DestinationMapViewController.h"
#import "TMap.h"
#import "DestinationDBData.h"
#import "DestinationTableViewCell.h"
#import "LocalDataManager.h"
#import "MainViewController.h"

@interface DestinationViewController () <CAPSPageMenuDelegate,UITextFieldDelegate>
{
    NSMutableArray *resultArray;
    UIEdgeInsets padding;
    DestinationTabViewController *resultController;
    DestinationTabViewController *recentController;
    DestinationTabViewController *favoriteController;
}
@end



@implementation DestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    self.searchContainer.backgroundColor = UIColorFromRGB(BASIC_COLOR);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTap)];
    singleTap.numberOfTapsRequired = 1;
    [_searchIcon setUserInteractionEnabled:YES];
    [_searchIcon addGestureRecognizer:singleTap];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Destination" bundle:nil];
    
    // Array to keep track of controllers in page menu
    NSMutableArray *controllerArray = [NSMutableArray array];
    
    // Create variables for all view controllers you want to put in the
    // page menu, initialize them, and add each to the controller array.
    // (Can be any UIViewController subclass)
    // Make sure the title property of all view controllers is set
    // Example:
    //UIViewController *controller = [[UIViewController alloc] initWithNibname:@"controllerNibnName" bundle:nil];
    //controller.title = @"SAMPLE TITLE";
    //[controllerArray addObject:controller];
    
    resultController =[story instantiateViewControllerWithIdentifier:@"destinationTab"];
    resultController.type = SEARCH_DESTINATION;
    resultController.title = @"검색결과";
    resultController.backViewController = self;
    resultController.searchDestinationArray = resultArray;
    [resultController setIsHideEditButton:YES];
    [controllerArray addObject:resultController];
    recentController = [story instantiateViewControllerWithIdentifier:@"destinationTab"];
    recentController.type = RECENT_DESTINATION;
    recentController.title = @"최근목적지";
    recentController.backViewController = self;
    [controllerArray addObject:recentController];
    favoriteController =[story instantiateViewControllerWithIdentifier:@"destinationTab"];
    favoriteController.type = FAVORITE_DESTINATION;
    favoriteController.title = @"즐겨찾기";
    favoriteController.backViewController = self;
    [controllerArray addObject:favoriteController];
    DestinationMapViewController *controller4 =[story instantiateViewControllerWithIdentifier:@"destinationMap"];
    controller4.title = @"지도찾기";
    controller4.backViewController = self;
    if(_type == DESTINATION_TWOWAY ||_type == DESTINATION_THREEWAY ){
        controller4.iconImageName = @"pin_red2";
    }else if(_type == DEPATURE_TWOWAY || _type == DEPATURE_THREEWAY){
        controller4.iconImageName = @"pin_dark_blue2";
    }else if(_type == WAYPOINT_THREEWAY){
        controller4.iconImageName = @"pin_gray2";
    }else{
        controller4.iconImageName = @"pin_red2";
    }
    [controllerArray addObject:controller4];
    // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
    // Example:
    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.0),
                                 CAPSPageMenuOptionMenuHeight: @(50),
                                 CAPSPageMenuOptionSelectionIndicatorColor: UIColorFromRGB(SECOND_COLOR),
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor clearColor],
                                 CAPSPageMenuOptionScrollMenuBackgroundColor:UIColorFromRGB(BASIC_COLOR),
                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight:@(0.0)
                                 };
    
    //NSDictionary *parameters2 = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
    //                             @"useMenuLikeSegmentedControl": @(YES),
    //                             @"menuItemSeparatorPercentageHeight": @(0.1)
    //                             };
    
    // Initialize page menu with controller array, frame, and optional parameters
    _pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.pageMenuContainer.frame.size.width, self.pageMenuContainer.frame.size.height) options:parameters];
    _pagemenu.delegate = self;
    [_pagemenu setStartIndexToPage:3];
    // Lastly add page menu as subview of base view controller view
    // or use pageMenu controller in you view hierachy as desired
    [self.pageMenuContainer addSubview:_pagemenu.view];
    padding = UIEdgeInsetsMake(0, 0, 0, self.searchIcon.frame.size.width);
   // _searchTextFieldeld.rightAnchor
    //_pagemenu.view.backgroundColor = [UIColor clearColor];
    //_pagemenu.controllerScrollView.backgroundColor = [UIColor clearColor];
    //self.view.backgroundColor = [UIColor clearColor];
    
    
    
}

-(void)searchTap{
    NSLog(@"single Tap on imageview");
    [_pagemenu moveToPage:0];
    [_searchTextField becomeFirstResponder];
    //[self tmapSearch:_searchTextField.text];
    //[_pagemenu setCurrentPageIndex:0];
}

- (void)tmapSearch:(NSString *)keyword
{
    //NSDate *now = [[NSDate alloc] init];
    resultArray = [NSMutableArray new];
    
    TMapPathData* path = [[TMapPathData alloc] init];
    //통합검색
    NSArray* result = [path requestFindAllPOI:keyword];
    
    for(TMapPOIItem* poi in result)
    {
        DestinationDBData *data = [DestinationDBData new];
        data.seq = poi.poiID;
        data.title = poi.poiName;
        data.address = poi.address;
        //data.rdate = now;
        data.lat = [[NSDecimalNumber alloc] initWithDouble:poi.frontCoordinate.latitude];
        data.lon = [[NSDecimalNumber alloc] initWithDouble:poi.frontCoordinate.longitude];
        [resultArray addObject:data];
    }
    
    resultController.searchDestinationArray = resultArray;
    [resultController reload];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void) viewDidLayoutSubviews{
    
}

- (void) reloadFavorite
{
    if(favoriteController)
    [favoriteController reload];
}

- (void) reloadRecent
{
    if(recentController)
        [recentController reload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Optional delegate
- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    if(index == 1){
        [self reloadRecent];
    }else if(index ==2){
        [self reloadFavorite];
    }
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    
}

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

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[_pagemenu setCurrentPageIndex:0];
    
    if(_pagemenu.currentPageIndex != 0){
        [_pagemenu moveToPage:0];
    }
    
    [self tmapSearch:textField.text];
    return YES;
}

- (IBAction)textFieldDidChanged:(UITextField *)theTextField
{
    
}

// 입력 형식에 맞추기 위해 특정 위치에 공백 문자 삽입
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
    [_pagemenu moveToPage:0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [self adjustRectWithWidthRightView:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    
    return [self adjustRectWithWidthRightView:bounds];
   
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return [self adjustRectWithWidthRightView:bounds];
}

- (CGRect)adjustRectWithWidthRightView:(CGRect)bounds {
    CGRect paddedRect = bounds;
    paddedRect.size.width -= CGRectGetWidth(self.searchIcon.frame);
    
    return paddedRect;
}

-(BOOL) NSStringIsValid:(NSString *)checkString
{
    NSString *stricterFilterString = @"[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\u318D\u119E\u11A2\u2022\u2025a\u00B7\uFE55_-]*";
    //NSString *stricterFilterString = @"[ㄱ-ㅎㅏ-ㅣ가-힣A-Z0-9a-z-_ ]*";
    
    NSPredicate *stringTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [stringTest evaluateWithObject:checkString];
}
- (IBAction)backClick:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"unwindMain" sender:nil];
    });
}


@end
