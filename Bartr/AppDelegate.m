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
#import "ConversationListViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate ()
@property BOOL authenticatedUser;
@property (nonatomic)  KeychainItemWrapper *keychainItem;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic) LYRClient *layerClient;
@end

@implementation AppDelegate
@synthesize user = _user;
@synthesize authenticatedUser;
@synthesize keychainItem = _keychainItem;
@synthesize locationManager = _locationManager;


- (void)requestIdentityTokenForUserID:(NSString *)userID appID:(NSString *)appID nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion
{
    NSParameterAssert(userID);
    NSParameterAssert(appID);
    NSParameterAssert(nonce);
    NSParameterAssert(completion);
    
    NSURL *identityTokenURL = [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com/identity_tokens"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSDictionary *parameters = @{ @"app_id": appID, @"user_id": userID, @"nonce": nonce };
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        // Deserialize the response
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(![responseObject valueForKey:@"error"])
        {
            NSString *identityToken = responseObject[@"identity_token"];
            completion(identityToken, nil);
        }
        else
        {
            NSString *domain = @"layer-identity-provider.herokuapp.com";
            NSInteger code = [responseObject[@"status"] integerValue];
            NSDictionary *userInfo =
            @{
              NSLocalizedDescriptionKey: @"Layer Identity Provider Returned an Error.",
              NSLocalizedRecoverySuggestionErrorKey: @"There may be a problem with your APPID."
              };
            
            NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
            completion(nil, error);
        }
        
    }] resume];
}

- (void)authenticateLayerWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError * error))completion
{
    // Check to see if the layerClient is already authenticated.
    if (self.layerClient.authenticatedUserID) {
        // If the layerClient is authenticated with the requested userID, complete the authentication process.
        if ([self.layerClient.authenticatedUserID isEqualToString:userID]){
            NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUserID);
            if (completion) completion(YES, nil);
            return;
        } else {
            //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
            [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                if (!error){
                    [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
                        if (completion){
                            completion(success, error);
                        }
                    }];
                } else {
                    if (completion){
                        completion(NO, error);
                    }
                }
            }];
        }
    } else {
        // If the layerClient isn't already authenticated, then authenticate.
        [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
            if (completion){
                completion(success, error);
            }
        }];
    }
}

- (void)authenticationTokenWithUserId:(NSString *)userID completion:(void (^)(BOOL success, NSError* error))completion{
    
    /*
     * 1. Request an authentication Nonce from Layer
     */
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (!nonce) {
            if (completion) {
                completion(NO, error);
            }
            return;
        }
        
        /*
         * 2. Acquire identity Token from Layer Identity Service
         */
        [self requestIdentityTokenForUserID:userID appID:[self.layerClient.appID UUIDString] nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            if (!identityToken) {
                if (completion) {
                    completion(NO, error);
                }
                return;
            }
            
            /*
             * 3. Submit identity token to Layer for validation
             */
            [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                if (authenticatedUserID) {
                    if (completion) {
                        completion(YES, nil);
                    }
                    NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
                } else {
                    completion(NO, error);
                }
            }];
        }];
    }];
}



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
    
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"c219d8fa-002d-11e5-8cc1-8b63dd004c78"];
    self.layerClient = [LYRClient clientWithAppID:appID];
    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to connect to Layer: %@", error);
        } else {
            // For the purposes of this Quick Start project, let's authenticate as a user named 'Device'.  Alternatively, you can authenticate as a user named 'Simulator' if you're running on a Simulator.
            NSString *userIDString = @"Device";
            // Once connected, authenticate user.
            // Check Authenticate step for authenticateLayerWithUserID source
            [self authenticateLayerWithUserID:userIDString completion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                }
            }];
        }
    }];
    
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
    [self.keychainItem setObject:password forKey:(__bridge NSString *)(kSecValueData)];
    [self.keychainItem setObject:data forKey:(__bridge id)(kSecAttrAccount)];
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
