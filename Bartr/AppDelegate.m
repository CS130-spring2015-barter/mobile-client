//
//  AppDelegate.m
//  Bartr
//
//  Created by Mickey Sweatt on 4/12/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

// Location Manager code based on:
// https://github.com/voyage11/Location/tree/master/Location

#import "AppDelegate.h"
#import "JCDCoreData.h"
#import "BrtrDataSource.h"
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import <CoreLocation/CoreLocation.h>
#import "ATLMessagingUtilities.h"
#import "LCLayerClient.h"
#import "LocationShareModel.h"

static NSString *const kLayerAppID = @"c219d8fa-002d-11e5-8cc1-8b63dd004c78";

@interface AppDelegate()
@property (nonatomic)  KeychainItemWrapper *keychainItem;
@property (strong,nonatomic) LocationShareModel * shareModel;
@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;
@property (nonatomic) LCLayerClient *layerClient;
@end

@implementation AppDelegate
@synthesize user = _user;
@synthesize keychainItem = _keychainItem;
@synthesize shareModel = _shareModel;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //authenticatedUser: check from NSUserDefaults User credential if its present then set your navigation flow accordingly
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        [self.keychainItem resetKeychainItem];
        [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSDictionary *creds = [self getLoginCredentials];
    if (creds && [creds objectForKey:KEY_USER_NAME] && [creds objectForKey:KEY_AUTH_CREDS]) {
        self.user = [BrtrDataSource getUserForEmail:[creds objectForKey:KEY_USER_NAME] password:[creds objectForKey:KEY_AUTH_CREDS]];
    }
    if (self.user)
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else
    {
        self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }
    [self initializeLocationManager:launchOptions];
    return YES;
}

-(void)initializeLocationManager:(NSDictionary *)launchOptions
{
    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    [self addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];
    
    UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
            self.shareModel.anotherLocationManager.delegate = self;
            self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
            
            if(IS_OS_8_OR_LATER) {
                [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
            }
            [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
            
            [self addResumeLocationToPList];
        }
    }

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    //NSLog(@"locationManager didUpdateLocations: %@",locations);
    
    for(int i=0;i<locations.count;i++){
        
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.myLocation = theLocation;
        self.myLocationAccuracy = theAccuracy;
    }
    
    [self addLocationToPList:self.shareModel.afterResume];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    
    [self addApplicationStatusToPList:@"applicationDidEnterBackground"];
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self addApplicationStatusToPList:@"applicationDidBecomeActive"];
    
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
}


-(void)applicationWillTerminate:(UIApplication *)application{
    NSLog(@"applicationWillTerminate");
    [self addApplicationStatusToPList:@"applicationWillTerminate"];
    [[JCDCoreData sharedInstance] saveContext];
}


///////////////////////////////////////////////////////////////
// Below are 3 functions that add location and Application status to PList
// The purpose is to collect location information locally

-(void)addResumeLocationToPList{
    
    NSLog(@"addResumeLocationToPList");
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:@"UIApplicationLaunchOptionsLocationKey" forKey:@"Resume"];
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }
    
    if(self.shareModel.myLocationDictInPlist)
    {
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}



-(void)addLocationToPList:(BOOL)fromResume{
    NSLog(@"addLocationToPList");
    
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.latitude]  forKey:@"Latitude"];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.longitude] forKey:@"Longitude"];
    [self.shareModel.myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocationAccuracy] forKey:@"Accuracy"];
    
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    
    if(fromResume)
        [self.shareModel.myLocationDictInPlist setObject:@"YES" forKey:@"AddFromResume"];
    else
        [self.shareModel.myLocationDictInPlist setObject:@"NO" forKey:@"AddFromResume"];
    
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }
    
    NSLog(@"Dict: %@",self.shareModel.myLocationDictInPlist);
    
    if(self.shareModel.myLocationDictInPlist)
    {
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}



-(void)addApplicationStatusToPList:(NSString*)applicationStatus{
    
    NSLog(@"addApplicationStatusToPList");
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    UIAlertView *alert;
    if([CLLocationManager locationServicesEnabled]){
        NSLog(@"Location Services Enabled");
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
            alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                               message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
            [alert show];
        }
    }
    self.shareModel.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [self.shareModel.myLocationDictInPlist setObject:applicationStatus forKey:@"applicationStatus"];
    [self.shareModel.myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [self.shareModel.myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile){
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    }
    else{
        self.shareModel.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
        if (self.shareModel.myLocationArrayInPlist == nil) {
            self.shareModel.myLocationArrayInPlist = [[NSMutableArray alloc] init];
        }
    }
    
    if(self.shareModel.myLocationDictInPlist)
    {
        [self.shareModel.myLocationArrayInPlist addObject:self.shareModel.myLocationDictInPlist];
        [savedProfile setObject:self.shareModel.myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE] ) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}

- (void)setupLayer: (NSString *) userIDString{
    if (kLayerAppID) {
        _layerClient = [LCLayerClient clientWithAppID:[[NSUUID alloc] initWithUUIDString:kLayerAppID]];
        self.layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImageJPEGPreview, ATLMIMETypeTextPlain, nil];
        [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Failed to connect to Layer: %@", error);
            } else {
                [self.layerClient authenticateWithUserID:userIDString completion:^(BOOL success, NSError *error) {
                    if (!success) {
                        NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                    }
                }];
            }
        }];
    }
}


-(CLLocationCoordinate2D) getGPSData
{
    return self.myLocation;
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
    NSString *pass = [cred_dict objectForKey:KEY_AUTH_CREDS];
    if (nil == email || nil == pass) {
        return nil;
    }
    return [[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:email    , pass       , nil]
                                  forKeys:       [[NSArray alloc] initWithObjects:KEY_USER_NAME, KEY_AUTH_CREDS, nil]];
}

//-(LYRClient*) getLayerClient
-(LCLayerClient*) getLayerClient
{
    return self.layerClient;
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

-(KeychainItemWrapper *) keychainItem
{
    if (nil == _keychainItem) {
        _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"BrtrUserData" accessGroup:nil];
    }
    return _keychainItem;
}



@end
