//
//  BartarItemsTVCTableViewController.h
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataFetchDelegate.h"

@interface BrtrItemsTableViewController : UITableViewController <DataFetchDelegate>

typedef void (^VoidBlock)();

@property (nonatomic, strong) NSArray *items;
@property                     BOOL     allowEditableItems; 
@property (readwrite, copy ) VoidBlock reloadCall;

- (void)reloadData;
@end
