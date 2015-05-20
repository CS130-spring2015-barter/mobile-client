//
//  AddItemsViewController.m
//  Bartr
//
//  Created by admin on 5/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AddItemsViewController.h"
<<<<<<< HEAD
#import "BrtrDataSource.h"
#import "APLViewController.h"
#import "AppDelegate.h"

@interface AddItemsViewController ()
@property IBOutlet UITableView *tableView;
@property UITextField *itemNameField;
@property UITextView  *itemDescriptionField;
@property UIBarButtonItem *doneButton;
=======
#import "TextFormCell.h"
@interface AddItemsViewController ()
@property IBOutlet UITableView *tableView;
>>>>>>> c46c0dc... Make AddItemViewController cells editable
@end

@implementation AddItemsViewController
@synthesize tableView = _tableView;
<<<<<<< HEAD
@synthesize itemName;
@synthesize itemDescription;
@synthesize itemDescriptionField;
@synthesize itemNameField;

=======
>>>>>>> c46c0dc... Make AddItemViewController cells editable
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
<<<<<<< HEAD
    self.doneButton = self.navigationItem.rightBarButtonItem;
    [self updateStatusOfDoneButton];
=======
    
>>>>>>> c46c0dc... Make AddItemViewController cells editable
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


<<<<<<< HEAD
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = indexPath.row == 0 ? @"AddItemCell" : @"AddItemDescCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        /* only called when cell is created */
    }

    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"Name";
            UITextField* textField = (UITextField *)[cell viewWithTag:100];
            textField.delegate = self;
            textField.text = self.itemName;
            self.itemNameField = textField;
            [textField setReturnKeyType:UIReturnKeyDone];            
        } break;
        case 1: {
            cell.textLabel.text = @"Description";
            UITextView *textView = (UITextView *)[cell viewWithTag:100];
            textView.text = self.itemDescription;
            self.itemDescriptionField = textView;
            textView.delegate = self;
            
        } break;
        default:
            break;
    }
    [cell sizeToFit];
=======
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
    
>>>>>>> c46c0dc... Make AddItemViewController cells editable
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
<<<<<<< HEAD
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    id textField = [cell viewWithTag:100];
    [textField becomeFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    self.itemName = textField.text;
    [self updateStatusOfDoneButton];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    self.itemDescription = textView.text;
    [self updateStatusOfDoneButton];
}

-(void) updateStatusOfDoneButton
{
    if (self.itemDescription && self.itemName
    && ![self.itemDescription isEqualToString:@""]
    && ![self.itemName isEqualToString:@""] )
    {
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}
- (IBAction)userDidPressDoneButton:(UIBarButtonItem *)sender {

    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    BrtrUser *user  = ad.user;
    [BrtrDataSource user:user
             didAddItemWithName:self.itemName
             andInfo:self.itemDescription
                andImage:UIImagePNGRepresentation(self.itemImage) delegate:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"Done");
    self.itemImage = nil;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if  ([segue.identifier isEqualToString:@"unwind"]) {
        self.itemName = itemNameField.text;
        self.itemDescription = itemDescriptionField.text;
    }
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



=======
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
    
>>>>>>> c46c0dc... Make AddItemViewController cells editable

@end
