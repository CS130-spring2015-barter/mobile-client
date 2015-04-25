//
//  BarterViewController.m
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrProfileViewController.h"
#import "AppDelegate.h"
#import "BrtrUser.h"

@interface BrtrProfileViewController ()
@property (weak, nonatomic) BrtrUser *user;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@end

@implementation BrtrProfileViewController
- (IBAction)didPushEditButton:(id)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    self.user = app.user;
    // Do any additional setup after loading the view.
}

// this gets the number of rows within the tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.profileInfo count];
}

// this actually gets the information for each cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ProfileTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    int row = indexPath.row;
    switch (row) {
        case 0:
            cell.textLabel.text = @"Email";
            cell.detailTextLabel.text = [self.user email];
            break;
        case 1:
            cell.textLabel.text = @"First";
            cell.detailTextLabel.text = [self.user first_name];
        case 2:
            cell.textLabel.text = @"Last";
            cell.detailTextLabel.text = [self.user last_name];
        case 3:
            cell.textLabel.text = @"About me";
            cell.detailTextLabel.text = [self.user about_me];
        default:
            break;
    }
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
