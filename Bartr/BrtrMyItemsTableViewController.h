//
//  BrtrMyItemsTableViewController.h
//  Bartr
//
//  Created by Synthia Ling on 5/28/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BrtrDataSource.h"
#import "BrtrItemsTableViewController.h"
#import "LCConversationListViewController.h"

@interface BrtrMyItemsTableViewController : BrtrItemsTableViewController 

//@property (strong, nonatomic)AppDelegate* ad;
@property (strong, nonatomic)NSArray* user_ids;
@end
