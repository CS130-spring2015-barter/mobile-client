//
//  AppDelegate.m
//  Bartr
//
//  Created by Rohan Chitalia on 4/12/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AppDelegate.h"
#import "JCDCoreData.h"
#import "BrtrDataSource.h"

@interface AppDelegate ()
@property BOOL authenticatedUser;
@end

@implementation AppDelegate
@synthesize user = _user;
@synthesize authenticatedUser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //authenticatedUser: check from NSUserDefaults User credential if its present then set your navigation flow accordingly
    if (self.authenticatedUser)
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
     [[JCDCoreData sharedInstance] saveContext];
}

-(BrtrUser *)user
{
    if (nil == _user) {
        _user = [BrtrDataSource getUserForEmail:@"foo@bar.com"];
    }
    return _user;
}



@end
