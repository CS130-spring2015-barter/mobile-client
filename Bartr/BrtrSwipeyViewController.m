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
#import "LCConversationViewController.h"
#import "BrtrBackendFields.h"

@interface BrtrSwipeyViewController ()
@property (nonatomic, strong) DraggableViewBackground* cardView;
@end

@implementation BrtrSwipeyViewController

@synthesize user;
-(void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.user = ad.user;
    
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.bounds andDelegate:self];
    self.cardView = draggableBackground;
    [self.view addSubview:draggableBackground];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
 [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (0 == [self.cardView.allCards count]) {
        [BrtrDataSource getCardStackForUser:self.user delegate:self.cardView];
    }
}


-(NSArray *) getMultipleCardsUsingDelegate:(id<DataFetchDelegate>) delegate {
    return [BrtrDataSource getCardStackForUser:user delegate:delegate];
}

-(void) itemSwipedRight:(BrtrCardItem *)item usingDelegate:(id<DataFetchDelegate>)delegate
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    __block BrtrCardItem *temp_item = item;
    __block BrtrUser     *temp_user = self.user;
    [queue addOperationWithBlock:^{
        AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *item_name = temp_item.name;
        [[BrtrDataSource sharedInstance] user:temp_user didLikeItem:temp_item delegate:delegate];
        LCConversationViewController *conv = [LCConversationViewController conversationViewControllerWithLayerClient:[ad getLayerClient]];
        NSDictionary *user_info = [BrtrDataSource getUserInfoForUserWithId:temp_item.owner_id];
        NSString *message = [NSString stringWithFormat:@"Hello %@ I am interested in your %@", [user_info  objectForKey:KEY_USER_FIRST_NAME ], item_name];
        [conv sendMessage:message toReceiver:[user_info objectForKey:KEY_USER_EMAIL]];
    }];
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