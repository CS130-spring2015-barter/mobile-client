//
//  AddTableViewController.m
//  Bartr
//
//  Created by Synthia Ling on 5/17/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AddTableViewController.h"
#import "AddItemTableCell.h"
@interface AddTableViewController ()
@property (weak, nonatomic) UITextField *itemNameField;
@property (weak, nonatomic) UITextView *itemInfoField;
@end

@implementation AddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    long row = indexPath.row;
    UITableViewCell *cell = nil;
    
    if (row == 0 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddItemTableCell"];
        if (cell == nil) {
            cell = [[AddItemTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddItemTableCell"];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddItemTableCell2"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AddItemTableCell2"];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (row) {
        case 0: {
            AddItemTableCell *infoCell = (AddItemTableCell *)cell;
            [infoCell.titleLabel setText:@"Item description"];
            self.itemInfoField = infoCell.subtitleLabel;
            self.itemInfoField.text = @"Description";
            
        } break;
        case 1: {
            UILabel *labelField = (UILabel *)[cell viewWithTag:1];
            labelField.text = @"Item Name";
            self.itemNameField = (UITextField *)[cell viewWithTag:2];
            self.itemNameField.text = @"Item Name";
            
        } break;
        default: {
            NSLog(@"ERROR: Unknown cell id");
            cell = nil;
        } break;
    }
    return cell;

}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
