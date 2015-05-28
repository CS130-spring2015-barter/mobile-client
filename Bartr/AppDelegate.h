//
//  AppDelegate.h
//  Bartr
//
//  Created by Rohan Chitalia on 4/12/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <LayerKit/LayerKit.h>
#import "BrtrUser.h"
#import "LCLayerClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BrtrUser *user;

//-(LYRClient*) getLayerClient;
-(LCLayerClient*) getLayerClient;
-(NSDictionary *) getLoginCredentials;
-(void) storeEmail:(NSString *) email password:(NSString *)password;
-(void)storeUserAuthToken:(NSString *)tok;
-(NSString *)getAuthToken;
-(void) startLocationManager;
-(CLLocation *) getGPSData;
-(void)setupLayer;
@end

