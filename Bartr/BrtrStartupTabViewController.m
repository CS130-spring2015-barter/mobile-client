//
//  StartupTabViewController.m
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrStartupTabViewController.h"
#import "BrtrDataSource.h"
#import "BrtrItemsTableViewController.h"
#import "BrtrProfileViewController.h"
#import "BrtrSwipeyViewController.h"

@interface BrtrStartupTabViewController ()
@property (strong, nonatomic) BrtrUser *user;
@end

@implementation BrtrStartupTabViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [BrtrDataSource loadFakeData];
    self.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UIViewController *vc = viewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *) vc;
        vc = nav.topViewController;
    }
    if ([vc isKindOfClass:[BrtrProfileViewController class]])
    {
        NSLog(@"Profile");
        
        
    }
    else if ([vc isKindOfClass:[BrtrItemsTableViewController class]])
    {
        BrtrItemsTableViewController *itvc = (BrtrItemsTableViewController *)vc;
        itvc.items = [BrtrDataSource getCardStackForUser:self.user];
        itvc.navigationItem.title = [NSString stringWithFormat:@"%@'s Liked Items", self.user.firstName];
        NSLog(@"Items");
    }
    else if ([vc isKindOfClass:[BrtrSwipeyViewController class]])
    {
        NSLog(@"Swipey");
        BrtrSwipeyViewController *svc = (BrtrSwipeyViewController *) vc;
        NSArray *cards = [BrtrDataSource getCardStackForUser:self.user];
        
    }
    else {
        NSLog(@"Unknown vc");
    }
}


-(BrtrUser *)getUser
{
    if (nil == self.user) {
        self.user = [BrtrDataSource getUserForEmail:@"foo@bar.com"];
    }
    return self.user;
}

#pragma mark - Navigation



@end
