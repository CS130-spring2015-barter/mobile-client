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
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()

@property (nonatomic)  KeychainItemWrapper *keychainItem;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@end

@implementation AppDelegate
@synthesize user = _user;
@synthesize keychainItem = _keychainItem;
@synthesize locationManager = _locationManager;





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //authenticatedUser: check from NSUserDefaults User credential if its present then set your navigation flow accordingly
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        [self.keychainItem resetKeychainItem];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSDictionary *creds = [self getLoginCredentials];
    if (creds && [creds objectForKey:@"email"] && [creds objectForKey:@"password"]) {
        self.user = [BrtrDataSource getUserForEmail:[creds objectForKey:@"email"] password:[creds objectForKey:@"password"]];
    }
    if (self.user)
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }

    return YES;
}

-(void) startLocationManager
{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

-(CLLocation *) getGPSData
{
    return self.lastLocation;
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] > 0) {
        self.lastLocation = [locations lastObject];
        [self.locationManager stopUpdatingLocation];
    }
}

-(NSDictionary *)getCredDict
{
    NSData *cred_dict_rep = [self.keychainItem objectForKey:(__bridge NSString*)kSecValueData];
    NSError* error;
    NSDictionary* cred_dict = [NSPropertyListSerialization propertyListWithData:cred_dict_rep options:NSPropertyListImmutable format:nil error:&error];
    return [cred_dict isKindOfClass:[NSDictionary class]] ? cred_dict : [[NSDictionary alloc] init];
}

-(NSDictionary *) getLoginCredentials
{
    NSString *email = [self.keychainItem objectForKey:(__bridge NSString*)kSecAttrAccount];
    NSDictionary *cred_dict = [self getCredDict];
    NSString *pass = [cred_dict objectForKey:@"password"];
    if (nil == email || nil == pass) {
        return nil;
    }
    return [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:email    , pass       , nil]
                                  forKeys:       [[NSArray alloc] initWithObjects:@"email" , @"password", nil]];
}

-(NSString *)getAuthToken
{
    NSDictionary *cred_dict = [self getCredDict];
    return [cred_dict objectForKey:@"token"];
}

-(void) storeEmail:(NSString *) email password:(NSString *)password
{
    NSDictionary *cred_dict = [self getCredDict];
    NSMutableDictionary *mutable_cred_dict = [[NSMutableDictionary alloc] initWithDictionary:cred_dict];
    [mutable_cred_dict setValue:password forKey:@"password"];
    cred_dict = [mutable_cred_dict copy];
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:cred_dict format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    [self.keychainItem setObject:data forKey:(__bridge NSString *)(kSecValueData)];
    [self.keychainItem setObject:email forKey:(__bridge NSString *)(kSecAttrAccount)];
}

-(void)storeUserAuthToken:(NSString *)tok
{
    NSDictionary *cred_dict = [self getCredDict];
    NSMutableDictionary *mutable_cred_dict;
    mutable_cred_dict = [[NSMutableDictionary alloc] initWithDictionary:cred_dict];    [mutable_cred_dict setValue:tok forKey:@"token"];
    cred_dict = [mutable_cred_dict copy];
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:cred_dict format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    [self.keychainItem setObject:data forKey:(__bridge NSString *)(kSecValueData)];
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

-(KeychainItemWrapper *) keychainItem
{
    if (nil == _keychainItem) {
        _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BrtrUserData" accessGroup:nil];
    }
    return _keychainItem;
}



@end
