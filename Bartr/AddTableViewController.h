//
//  AddTableViewController.h
//  Bartr
//
//  Created by Synthia Ling on 5/17/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
    @property (retain, nonatomic) IBOutlet UITableView *tableView;
@end
