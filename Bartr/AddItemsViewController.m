//
//  AddItemsViewController.m
//  Bartr
//
//  Created by admin on 5/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AddItemsViewController.h"
#import "APLViewController.h"

@interface AddItemsViewController ()
@property IBOutlet UITableView *tableView;

@property UIBarButtonItem *backButton;
@end

@implementation AddItemsViewController
@synthesize tableView = _tableView;
@synthesize itemName;
@synthesize itemDescription;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.hidesBackButton = YES;
    self.backButton = self.navigationItem.leftBarButtonItem;
    self.navigationItem.backBarButtonItem = self.navigationItem.leftBarButtonItem;
    [self updateStatusOfBackButton];
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
            cell.textLabel.text = @"Name";
            UITextField* textField = (UITextField *)[cell viewWithTag:100];
            textField.delegate = self;
            textField.text = self.itemName;
            [textField setReturnKeyType:UIReturnKeyDone];            
        } break;
        case 1: {
            cell.textLabel.text = @"Description";
            UITextView *textView = (UITextView *)[cell viewWithTag:100];
            textView.text = self.itemDescription;
            textView.delegate = self;
            
        } break;
        default:
            break;
    }
    [cell sizeToFit];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    [self updateStatusOfBackButton];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    self.itemDescription = textView.text;
    [self updateStatusOfBackButton];
}

-(void) updateStatusOfBackButton
{
    if (self.itemDescription && self.itemName
    && ![self.itemDescription isEqualToString:@""]
    && ![self.itemName isEqualToString:@""] )
    {
        self.navigationItem.leftBarButtonItem = self.backButton;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
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




@end
