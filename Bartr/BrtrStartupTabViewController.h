//
//  StartupTabViewController.h
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrtrUser;

@interface BrtrStartupTabViewController : UITabBarController

-(BrtrUser *) getUser;

@end
