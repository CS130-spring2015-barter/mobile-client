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
#import "BrtrDataSource.h"

@interface BrtrProfileViewController ()
@property (weak, nonatomic) BrtrUser *user;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) UITextField *usernameField;
@property (weak, nonatomic) UITextField *firstNameField;
@property (weak, nonatomic) UITextField *lastNameField;
@property (weak, nonatomic) UITextField *aboutMeField;

@end

@implementation BrtrProfileViewController

BOOL isEditMode;

- (IBAction)didPushEditButton:(id)sender {
    if(isEditMode) {
        self.user.email = self.usernameField.text;
        self.user.first_name = self.firstNameField.text;
        self.user.last_name = self.lastNameField.text;
        self.user.about_me = self.aboutMeField.text;
        
        [self cancelEdit];

    }
    else {
        self.navigationItem.rightBarButtonItem.title = @"Done";
        
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        self.usernameField.userInteractionEnabled = YES;
        self.firstNameField.userInteractionEnabled = YES;
        self.lastNameField.userInteractionEnabled = YES;
        self.aboutMeField.userInteractionEnabled = YES;
        
        [self.usernameField becomeFirstResponder];
        isEditMode = YES;
    }
}

- (void) cancelEdit {
    self.navigationItem.rightBarButtonItem.title = @"Edit";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = NO;
    
    self.usernameField.userInteractionEnabled = NO;
    self.firstNameField.userInteractionEnabled = NO;
    self.lastNameField.userInteractionEnabled = NO;
    self.aboutMeField.userInteractionEnabled = NO;
    
    isEditMode = NO;
}

- (void) cancel {
    self.usernameField.text = self.user.email;
    self.firstNameField.text = self.user.first_name;
    self.lastNameField.text = self.user.last_name;
    self.aboutMeField.text = self.user.about_me;
    [self cancelEdit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [BrtrDataSource getUserForEmail:@"foo@bar.com"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// this gets the number of rows within the tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

// this actually gets the information for each cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"profileTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    long row = indexPath.row;
    switch (row) {
        case 0: {
            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
            labelField.text = @"Username";
            self.usernameField = (UITextField *)[cell viewWithTag:200];
            self.usernameField.text = self.user.email;
        } break;
        case 1: {
            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
            labelField.text = @"First";
            self.firstNameField = (UITextField *)[cell viewWithTag:200];
            self.firstNameField.text = self.user.first_name;
        } break;
        case 2: {
            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
            labelField.text = @"Last";
            self.lastNameField = (UITextField *)[cell viewWithTag:200];
            self.lastNameField.text = self.user.last_name;
        } break;
        case 3: {
            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
            labelField.text = @"About me";
            self.aboutMeField = (UITextField *)[cell viewWithTag:200];
            self.aboutMeField.text = self.user.about_me;
        } break;
        default: {
        }
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
