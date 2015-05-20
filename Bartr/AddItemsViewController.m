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


- (TextFormCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFormCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell" forIndexPath:indexPath];
    if (nil == cell) {
        cell =(TextFormCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddItemCell"];
    }
    UITextField *textField = cell.textField;
    textField.delegate = self;
    textField.userInteractionEnabled = YES;
    cell.userInteractionEnabled = YES;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Name";
            textField.text = @"foo";
            break;
        case 1:
            cell.textLabel.text = @"Description";
            textField.text = @"bar";
            break;
        default:
            break;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFormCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.textField becomeFirstResponder];
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


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
    

@end
