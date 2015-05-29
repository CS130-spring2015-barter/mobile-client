//
//  BrtrMyItemsTableViewController.m
//  Bartr
//
//  Created by Synthia Ling on 5/28/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrMyItemsTableViewController.h"




@implementation BrtrMyItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    LCConversationListViewController *cvc = [LCConversationListViewController conversationListViewControllerWithLayerClient:ad.getLayerClient];
    cvc.delegate = cvc;
    cvc.dataSource = cvc;
    
    BrtrItem *item = [self.items objectAtIndex:indexPath.row];
    [BrtrDataSource getUsersLikedMyItem:item.i_id delegate:self];
    
    [self.navigationController pushViewController: cvc animated:YES];
}

-(void) didReceiveData:(id)data response:(NSURLResponse *)response
{
    self.user_ids = (NSArray *)data;
}

@end
