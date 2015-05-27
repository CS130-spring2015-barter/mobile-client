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
#import "AppDelegate.h"
#import "DataFetchDelegate.h"
#import "JCDCoreData.h"
#import "BrtrItemViewController.h"

@interface BrtrSwipeyViewController ()

@end

@implementation BrtrSwipeyViewController

@synthesize user;
-(void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.user = ad.user;
    
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.bounds andDelegate:self];
    [self.view addSubview:draggableBackground];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
 [self.navigationController setNavigationBarHidden:YES animated:NO];
}


-(NSArray *) getMultipleCardsUsingDelegate:(id<DataFetchDelegate>) delegate {
    return [BrtrDataSource getCardStackForUser:user delegate:delegate];
}

-(void) itemSwipedRight:(BrtrCardItem *)item usingDelegate:(id<DataFetchDelegate>)delegate
{
    [[BrtrDataSource sharedInstance] user:self.user didLikeItem:item delegate:delegate];
}

-(void) itemSwipedLeft:(BrtrCardItem *)item usingDelegate:(id<DataFetchDelegate>) delegate
{
    [[BrtrDataSource sharedInstance] user:self.user didRejectItem:item delegate:delegate];
}


-(void) userClickedItem:(BrtrCardItem *)card
{
    BrtrItemViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    ivc.item = card;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end