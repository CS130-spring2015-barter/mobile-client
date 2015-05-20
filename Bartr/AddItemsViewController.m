//
//  AddItemsViewController.m
//  Bartr
//
//  Created by admin on 5/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AddItemsViewController.h"
#import "TextFormCell.h"
@interface AddItemsViewController ()
@property IBOutlet UITableView *tableView;
@end

@implementation AddItemsViewController
@synthesize tableView = _tableView;
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
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = indexPath.row == 0 ? @"AddItemCell" : @"AddItemDescCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        /* only called when cell is created */
    }

    switch (indexPath.row) {
        case 0: {
            UITextField* textField = [cell viewWithTag:100];
            cell.textLabel.text = @"Name";
            textField = [[UITextField alloc] initWithFrame:CGRectMake(175,15,260,40)];
            textField.delegate = self;
            textField.clearButtonMode = YES;
            textField.tag = 100; /* I would recommend a cell subclass with a textfield member over the tag method in real code*/
            [textField setReturnKeyType:UIReturnKeyDone];
            [cell addSubview:textField];
            break;
        }
        case 1: {
            cell.textLabel.text = @"Description";
            UITextView *textView = [cell viewWithTag:100];
            textView = [[UITextView alloc] initWithFrame:CGRectMake(175,15,260,40)];
            textView.delegate = self;
            textView.tag = 100; /* I would recommend a cell subclass with a textfield member over the tag method in real code*/
            [textView setReturnKeyType:UIReturnKeyDone];
            [cell addSubview:textView];
            break;
        }
        default:
            break;
    }
    [cell sizeToFit];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id textField = (UITextField *)[cell viewWithTag:100];
    [textField becomeFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        // size for 0
        return 40;
    }
    else {
        // size for desc
        return 100;
    }
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 
*/


@end
