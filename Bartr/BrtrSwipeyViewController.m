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

-(void)userClickedItem:(BrtrCardItem *)card
{
    //[self performSegueWithIdentifier:@"ShowItem" sender:self];
}

-(NSArray *) getMultipleCardsUsingDelegate:(id<DataFetchDelegate>) delegate {
    return [BrtrDataSource getCardStackForUser:user delegate:delegate];
}

-(void) itemSwipedRight:(BrtrCardItem *)item
{
    [[BrtrDataSource sharedInstance] user:user didLikedItem:item];
}

-(void) itemSwipedLeft:(BrtrCardItem *)item
{
    [[BrtrDataSource sharedInstance] user:user didRejectItem:item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end