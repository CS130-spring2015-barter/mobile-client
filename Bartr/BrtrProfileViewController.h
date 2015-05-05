//
//  BarterViewController.h
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BrtrUser;

@interface BrtrProfileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray *profileInfo;
@property (weak, nonatomic) BrtrUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
