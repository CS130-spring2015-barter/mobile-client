//
//  AddItemsViewController.m
//  Bartr
//
//  Created by admin on 5/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AddItemsViewController.h"
#import "BrtrDataSource.h"
#import "APLViewController.h"
#import "AppDelegate.h"

@interface AddItemsViewController()
@property IBOutlet UITableView *tableView;
@property UITextField *itemNameField;
@property UITextView  *itemDescriptionField;
@property UIBarButtonItem *doneButton;
@end

@implementation AddItemsViewController
@synthesize tableView = _tableView;
@synthesize itemName;
@synthesize itemDescription;
@synthesize itemDescriptionField;
@synthesize itemNameField;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.doneButton = self.navigationItem.rightBarButtonItem;
    [self updateStatusOfDoneButton];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    switch (indexPath.row) {
        case 0: {
            UITextField* textField = (UITextField *)[cell viewWithTag:100];
            textField.delegate = self;
            textField.text = self.itemName;
            self.itemNameField = textField;
            [textField setReturnKeyType:UIReturnKeyDone];            
        } break;
        case 1: {
            UITextView *textView = (UITextView *)[cell viewWithTag:100];
            textView.delegate = self;
            textView.text = self.itemDescription;
            self.itemDescriptionField = textView;
            [textView setReturnKeyType:UIReturnKeyDone];
        } break;
        default:
            break;
    }
    [cell sizeToFit];
    return cell;
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

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.itemDescriptionField becomeFirstResponder];
    return NO;
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
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
                andImage:UIImageJPEGRepresentation(self.itemImage, 0.0f) delegate:nil];
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

@end
