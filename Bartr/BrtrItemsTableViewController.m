//
//  BartarItemsTVCTableViewController.m
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrItemsTableViewController.h"
#import "BrtrStartupTabViewController.h"
#import "BrtrItemViewController.h"
#import "BrtrUser.h"
#import "BrtrUserItem.h"
#import "BrtrItem.h"
#import "BrtrItemViewController.h"
#import "BrtrDataSource.h"
#import "ItemTableViewCell.h"
#import "AppDelegate.h"

@interface BrtrItemsTableViewController ()

@end

@implementation BrtrItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.items count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableViewCell *cell = (ItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ItemCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    long row = indexPath.row;
    BrtrItem *item = (BrtrItem *)[self.items objectAtIndex:row];
    cell.imageView.image = [UIImage imageWithData:item.picture];
    cell.textLabel.text = item.name;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    long row = [self.tableView indexPathForCell:sender].row;

    UIViewController *vc = segue.destinationViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)vc).topViewController;
    }
    
    if ([vc isKindOfClass:[BrtrItemViewController class] ]) {
        BrtrItemViewController *ivc = (BrtrItemViewController *)vc;
        ivc.item = [self.items objectAtIndex:row];
        ivc.editable = self.allowEditableItems;
    }
    else {
        // error
        NSLog(@"Unrecognized VC in BrtrItemTVC segue");
    }
}

- (void) didReceiveData:(id) data response:(NSURLResponse *)response
{
    
    NSArray *liked_cards = (NSArray *)data;
    if([liked_cards count] == 0) {
        return;
    }
    // Received ids
    if([[liked_cards objectAtIndex:0] isKindOfClass:[NSNumber class]]) {
        AppDelegate *ap = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [BrtrDataSource getLikedItemsForUser:ap.user ids:liked_cards delegate:self];
    }
    // Received item info
    else {
        // FIXME
        self.items = liked_cards;
    }
}

-(void)setItems:(NSArray *)items
{
    _items = items;
    [self.tableView reloadData];
}

- (void) fetchingDataFailed:(NSError *)error
{
    NSLog(@"BrtrItemsTableViewController: Error when trying to fetch cards");
}

@end
