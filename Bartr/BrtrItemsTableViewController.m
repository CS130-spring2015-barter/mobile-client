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
#import "BrtrBackendFields.h"



@interface BrtrItemsTableViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation BrtrItemsTableViewController
@synthesize refreshControl;
@synthesize reloadCall;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor grayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl endRefreshing];
    }
}

-(void) updateData
{
    self.reloadCall();
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.items && [self.items count] > 0) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    }
    else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Avenir-Book" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        [self.tableView beginUpdates];
        BrtrUserItem* selected_item = [self.items objectAtIndex:indexPath.row];
        [BrtrDataSource user:ad.user didDeleteItem:selected_item delegate:self];
        
        NSMutableArray *mut_items = [NSMutableArray arrayWithArray:self.items];
        [mut_items removeObjectAtIndex:indexPath.row];
        self.items = [mut_items copy];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        

    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.items count] != 0) {
        if ([[self.items objectAtIndex:0] isKindOfClass:[BrtrUserItem class]]) {
            return YES;
        }
    }
    return NO;
}

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
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSArray *cards = (NSArray *)data;
    AppDelegate *ap = (AppDelegate * )[UIApplication sharedApplication].delegate;

    if([cards count] == 0) {
        return;
    }
    
    NSString *myItemsUrl = [NSString stringWithFormat: @"%@%@" , ENDPOINT, [NSString stringWithFormat:@"user/%@/item", ap.user.u_id]];
    
    // Received ids for my items
    if ([[[httpResponse URL] absoluteString] isEqual:myItemsUrl]) {
        [BrtrDataSource getItemsWithIDs:cards user:ap.user delegate:self liked:NO];
    }
    // received ids for my liked items
    else if ([[cards objectAtIndex:0] isKindOfClass:[NSNumber class]]){
        [BrtrDataSource getItemsWithIDs:cards user:ap.user delegate:self liked:YES];
    }
    // received cards
    else {
        self.items = cards;
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
