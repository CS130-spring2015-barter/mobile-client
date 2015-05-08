//
//  BrtrSwipeyViewController.m
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrSwipeyViewController.h"
#import "BrtrUser.h"
#import "BrtrStartupTabViewController.h"
#import "DraggableViewBackground.h"
#import "BrtrCardItem.h"
#import "BrtrDataSource.h"
@interface BrtrSwipeyViewController ()

@end

@implementation BrtrSwipeyViewController
@synthesize user;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    BrtrStartupTabViewController *root = (BrtrStartupTabViewController *)self.tabBarController;
    user = [root getUser];
    
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.bounds andDelegate:self];
    [self.view addSubview:draggableBackground];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(NSArray *) getMultipleCards {

    return [BrtrDataSource getCardStackForUser:user];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}


@end