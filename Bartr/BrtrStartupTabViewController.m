//
//  StartupTabViewController.m
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AppDelegate.h"
#import "BrtrStartupTabViewController.h"
#import "BrtrDataSource.h"
#import "BrtrItemsTableViewController.h"
#import "BrtrProfileViewController.h"
#import "BrtrSwipeyViewController.h"
#import "JCDCoreData.h"
#import "LCConversationListViewController.h"
#import "BrtrMyItemsTableViewController.h"

@interface BrtrStartupTabViewController  ()
@property (strong, nonatomic) BrtrUser *user;
@end

@implementation BrtrStartupTabViewController
@synthesize user;

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *ad = (AppDelegate *)[UIApplication  sharedApplication].delegate;
    self.delegate = self;
    self.user = ad.user;
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
    else if ([vc isKindOfClass:[BrtrMyItemsTableViewController class]])
    {
        __block BrtrMyItemsTableViewController *__unsafe_unretained itvc = (BrtrMyItemsTableViewController *)vc;
        itvc.items = [[NSArray alloc] initWithArray: [self.user.my_items allObjects]];
        AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
        itvc.navigationItem.title = @"Your Items";
        itvc.allowEditableItems = YES;
        itvc.reloadCall = ^(){[BrtrDataSource getUserItemsForUser:ad.user delegate:itvc]; [itvc reloadData];};
        
    }
    else if ([vc isKindOfClass:[BrtrItemsTableViewController class]])
    {
        __block BrtrItemsTableViewController *__unsafe_unretained itvc = (BrtrItemsTableViewController *)vc;
        NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
        AppDelegate *ap = (AppDelegate *)[UIApplication sharedApplication].delegate;
        itvc.items = [context fetchObjectsWithEntityName:@"BrtrLikedItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"user.email = %@", ap.user.email]];
        //[BrtrDataSource getLikedIDsForUser:self.user delegate:itvc];
        itvc.navigationItem.title = [NSString stringWithFormat:@"%@'s Liked Items", self.user.firstName];
        itvc.allowEditableItems = NO;
        itvc.reloadCall = ^(){[BrtrDataSource getLikedIDsForUser:self.user delegate:itvc]; [itvc reloadData];};
       // NSLog(@"Items");
    }
    else if ([vc isKindOfClass:[BrtrSwipeyViewController class]])
    {
        //NSLog(@"Swipey");
        
    }
    else if ([vc isKindOfClass:[LCConversationListViewController class]]) {
        AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
        LCConversationListViewController *cvc = (LCConversationListViewController *)vc;
        cvc = [LCConversationListViewController conversationListViewControllerWithLayerClient:ad.getLayerClient];
        cvc.delegate = cvc;
        cvc.dataSource = cvc;
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)viewController;
            [nav popViewControllerAnimated:NO];
            [nav pushViewController:cvc animated:NO];
        }
        else {
            NSUInteger index = [self.viewControllers indexOfObjectIdenticalTo:viewController];
            NSMutableArray *new_view_controllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
            [new_view_controllers setObject:cvc atIndexedSubscript:index];
            self.viewControllers = [new_view_controllers copy];
        }
    }
    else {
       // NSLog(@"Unknown vc");
    }
}

-(void) logout
{
    // Delete User credential from NSUserDefaults and other data related to user
    
    AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UIViewController* rootController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    appDelegateTemp.window.rootViewController = navigation;

}


#pragma mark - Navigation



@end
