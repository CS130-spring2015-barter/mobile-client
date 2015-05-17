//
//  AppDelegate.h
//  Bartr
//
//  Created by Rohan Chitalia on 4/12/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "BrtrUser.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BrtrUser *user;

-(NSDictionary *) getLoginCredentials;
-(void) storeEmail:(NSString *) email password:(NSString *)password;
-(void)storeUserAuthToken:(NSString *)tok;
-(NSString *)getAuthToken;
@end

