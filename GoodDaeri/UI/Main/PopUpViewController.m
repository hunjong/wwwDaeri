//
//  PopUpViewController.m
//  GoodDaeri
//
//  Created by Choi Hunjong on 2018. 6. 13..
//  Copyright © 2018년 Choi Hunjong. All rights reserved.
//

#import "PopUpViewController.h"
#import "NetworkManager.h"
#import "responseData.h"
#import "UIImageView+AFNetworking.h"

@interface PopUpViewController ()
{
    UIImageView *popUp2;
    NSString *directoryPath;
    NSString *imageName;
    NSString *extension;
    NSString *imageUrl;
}

//- (IBAction)closeForWeekClick:(id)sender;
//- (IBAction)closeClick:(id)sender;
@end

@implementation PopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imageUrl = self.introData.ad_image_url;
    
    [self.popUpImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    /*
    [self.popUpImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loading_bg_photo"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        if ([[extension lowercaseString] isEqualToString:@"png"]) {
            [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
        } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
        }
         
    } failure:NULL];
     */
    //NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:SAVEKEY_POPUP_URL];
}

-(void)tapDetected{
    NSLog(@"single Tap on imageview");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.introData.ad_url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeForWeekClick:(id)sender {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] + 604800;
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:SAVEKEY_POPUP];
}


- (IBAction)closeClick:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController performSegueWithIdentifier:@"segueIntro" sender:self];
    });
}
@end
