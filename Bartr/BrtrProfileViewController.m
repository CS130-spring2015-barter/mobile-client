//
//  BarterViewController.m
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "BrtrProfileViewController.h"
#import "AppDelegate.h"
#import "BrtrUser.h"
#import "BrtrDataSource.h"
#import "JCDCoreData.h"
#import "BrtrStartupTabViewController.h"
#import "BrtrItemsTableViewController.h"
#import "ProfileTableCell.h"

@interface BrtrProfileViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) UITextField *usernameField;
@property (weak, nonatomic) UITextField *firstNameField;
@property (weak, nonatomic) UITextField *lastNameField;
@property (weak, nonatomic) UITextField *aboutMeField;
@property (retain, nonatomic) UIBarButtonItem *myItemButton;
@end

@implementation BrtrProfileViewController

BOOL isEditMode;

- (IBAction)didPushEditButton:(id)sender {
    if(isEditMode) {
        self.user.email = self.usernameField.text;
        self.user.firstName = self.firstNameField.text;
        self.user.lastName = self.lastNameField.text;
        self.user.about_me = self.aboutMeField.text;
        [BrtrDataSource saveAllData];
        [self.tableView reloadData];
        [self cancelEdit];
        
    }
    else {
        self.navigationItem.rightBarButtonItem.title = @"Done";
        
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        self.usernameField.userInteractionEnabled = NO;
        self.firstNameField.userInteractionEnabled = YES;
        self.lastNameField.userInteractionEnabled = YES;
        self.aboutMeField.userInteractionEnabled = YES;
        self.picture.userInteractionEnabled = YES;
        [self.usernameField becomeFirstResponder];
        
        isEditMode = YES;
    }
}

- (void) cancelEdit {
    self.navigationItem.rightBarButtonItem.title = @"Edit";
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.picture.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem = self.myItemButton;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.hidesBackButton = NO;
    
    self.usernameField.userInteractionEnabled = NO;
    self.firstNameField.userInteractionEnabled = NO;
    self.lastNameField.userInteractionEnabled = NO;
    self.aboutMeField.userInteractionEnabled = NO;
    isEditMode = NO;
}

- (void) cancel {
    self.usernameField.text = self.user.email;
    self.firstNameField.text = self.user.firstName;
    self.lastNameField.text = self.user.lastName;
    self.aboutMeField.text = self.user.about_me;
    [self cancelEdit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BrtrStartupTabViewController *root = (BrtrStartupTabViewController *)self.tabBarController;
    self.user = [root getUser];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.picture.image  = [UIImage imageWithData: self.user.image];
    self.tableView.scrollEnabled = false;
    self.myItemButton = self.navigationItem.leftBarButtonItem;
    self.picture.userInteractionEnabled = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPicture:)];
    [self.picture addGestureRecognizer:tap];
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

-(void) clickPicture:(UITapGestureRecognizer *)tap
{
    if([UIImagePickerController isSourceTypeAvailable:
        UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *picker= [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        
        [self presentModalViewController:picker animated:YES];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@", [info allKeys]);
    UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.user.image = UIImagePNGRepresentation(selectedImage);
    self.picture.image = selectedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    CGRect frame = self.tableView.frame;
    frame.size.height = self.tableView.contentSize.height;
    self.tableView.frame = frame;
    [self.tableView sizeToFit];
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
    static NSString *simpleTableIdentifier = @"ProfileTableCell";
    ProfileTableCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        cell = [[ProfileTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    long row = indexPath.row;
    switch (row) {
        case 0: {
            [cell.titleLabel setText:@"Hello"];
            cell.subtitleLabel.text = @"Show up";
        } break;
        case 1: {
            [cell.titleLabel setText:@"Hello1"];
        } break;
        case 2: {
            [cell.titleLabel setText:@"Hello2"];
        } break;
        case 3: {
            [cell.titleLabel setText:@"Hello3"];
        } break;
        default: {
            NSLog(@"ERROR: Unknown cell id");
            cell = nil;
        } break;
    }
//    switch (row) {
//        case 0: {
//            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
//            labelField.text = @"Email";
//            self.usernameField = (UITextField *)[cell viewWithTag:200];
//            self.usernameField.text = self.user.email;
//        } break;
//        case 1: {
//            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
//            labelField.text = @"First";
//            self.firstNameField = (UITextField *)[cell viewWithTag:200];
//            self.firstNameField.text = self.user.firstName;
//        } break;
//        case 2: {
//            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
//            labelField.text = @"Last";
//            self.lastNameField = (UITextField *)[cell viewWithTag:200];
//            self.lastNameField.text = self.user.lastName;
//        } break;
//        case 3: {
//            UILabel *labelField = (UILabel *)[cell viewWithTag:199];
//            labelField.text = @"About me";
//            self.aboutMeField = (UITextField *)[cell viewWithTag:200];
//            self.aboutMeField.text = self.user.about_me;
//        } break;
//        default: {
//            NSLog(@"ERROR: Unknown cell id");
//            cell = nil;
//        } break;
//    }
    
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = segue.destinationViewController;
    
    BrtrItemsTableViewController *itvc;
    if ([@"ShowMyItems" isEqual: segue.identifier]) {
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = ((UINavigationController *)vc).topViewController;
        }
        if ([vc isKindOfClass:[BrtrItemsTableViewController class]]) {
            itvc = (BrtrItemsTableViewController *) vc;
            itvc.items = [[NSArray alloc] initWithArray: [self.user.my_items allObjects]];
            AppDelegate *ad = [UIApplication sharedApplication].delegate;
            itvc.navigationItem.title = [NSString stringWithFormat:@"%@'s Items", ad.user.firstName];
            itvc.allowEditableItems = YES;
        }
        else {
            // error
        }
    
    }
}


@end
