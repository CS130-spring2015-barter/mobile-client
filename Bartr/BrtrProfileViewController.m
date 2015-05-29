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
#import "BrtrItemsTableViewController.h"
#import "ProfileTableCell.h"
#import "BrtrBackendFields.h"
#import "BrtrDataSource.h"

@interface BrtrProfileViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) UITextField *usernameField;
@property (weak, nonatomic) UITextField *firstNameField;
@property (weak, nonatomic) UITextField *lastNameField;
@property (weak, nonatomic) UITextView *aboutMeField;
@property (retain, nonatomic) UIBarButtonItem *myItemButton;
@property (retain, nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation BrtrProfileViewController

BOOL isEditMode;

- (IBAction)didPushEditButton:(id)sender {
    if(isEditMode) {
        NSMutableDictionary *edittedFields = [[NSMutableDictionary alloc] init];
        // determine which values were changed so we may propogate them to the backend
        if (![self.usernameField.text isEqualToString:self.user.email]) {
            [edittedFields setObject:self.usernameField forKey:KEY_USER_EMAIL];
            self.user.email = self.usernameField.text;
        }
        if (![self.firstNameField.text isEqualToString: self.user.firstName]) {
            [edittedFields setObject:self.firstNameField.text forKey:KEY_USER_FIRST_NAME];
            self.user.firstName = self.firstNameField.text;
        }
        if (![self.lastNameField.text isEqualToString:self.user.lastName]) {
            [edittedFields setObject:self.lastNameField.text forKey:KEY_USER_LAST_NAME];
            self.user.lastName = self.lastNameField.text;
        }
        if (![self.aboutMeField.text isEqualToString:self.user.about_me]) {
            [edittedFields setObject:self.aboutMeField.text forKey:KEY_USER_ABOUTME];
            self.user.about_me = self.aboutMeField.text;
        }
        // Because the cropped version is displayed we must crop both for comparasion
        NSData *new_image_data = UIImageJPEGRepresentation(self.picture.image, 0.0f);
        NSData *old_image_data = UIImageJPEGRepresentation([self centerCropImage: [UIImage imageWithData: self.user.image]], 0.0f);
        if (![new_image_data isEqualToData:old_image_data]) {
            self.user.image = new_image_data;
            NSString *encoded_image_data = [new_image_data base64EncodedStringWithOptions:kNilOptions];
            [edittedFields setObject:encoded_image_data forKey:KEY_USER_IMAGE];
        }
        [BrtrDataSource updateUser:self.user withChanges:edittedFields withDelegate:nil];
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
        self.picture.userInteractionEnabled = YES;
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
    self.picture.image = [self centerCropImage: [UIImage imageWithData: self.user.image]];
    [self cancelEdit];
}

- (UIImage *)centerCropImage:(UIImage *)image
{
    // Use smallest side length as crop square length
    CGFloat squareLength = MIN(image.size.width, image.size.height);
    // Center the crop area
    CGRect clippedRect = CGRectMake((image.size.width - squareLength) / 2, (image.size.height - squareLength) / 2, squareLength, squareLength);
    
    // Crop logic
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.user = ad.user;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.picture.image = [UIImage imageWithData: self.user.image];
    if (self.picture.image == nil) {
        self.picture.image = [UIImage imageNamed:@"Icon-user"];
    }
    self.picture.image = [self centerCropImage:self.picture.image];
    UITapGestureRecognizer *tap;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCamera:)];
    }
    else
    {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLibrary:)];
    }
    [self.picture addGestureRecognizer:tap];
    self.tableView.scrollEnabled = false;
    self.myItemButton = self.navigationItem.leftBarButtonItem;
    self.picture.userInteractionEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void) navigationController: (UINavigationController *) navigationController
       willShowViewController: (UIViewController *) viewController
                     animated: (BOOL) animated
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
            viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
        } else {
            UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
            viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:button];
            viewController.navigationItem.title = @"Take Photo";
            viewController.navigationController.navigationBarHidden = NO; // important
        }
    }
}
- (IBAction)showCamera:(id)sender {
    if (!self.imagePickerController) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }
    else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
}

- (void) showLibrary: (id) sender {
    if (!self.imagePickerController) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }
    else {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)finishAndUpdate
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.imagePickerController = nil;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self finishAndUpdate];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@", [info allKeys]);
    UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.picture.image = [self centerCropImage: selectedImage];
    [self finishAndUpdate];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    CGRect frame = self.tableView.frame;
    frame.size.height = self.tableView.contentSize.height;
    self.tableView.frame = frame;
    self.picture.layer.cornerRadius = self.picture.frame.size.height /2;
    self.picture.layer.masksToBounds = YES;
    self.picture.layer.borderWidth = 0;
    [self.tableView sizeToFit];
    self.picture.contentMode = UIViewContentModeScaleAspectFit;
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
    long row = indexPath.row;
    UITableViewCell *cell = nil;
    
    if (row == 0 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileTableCell"];
        if (cell == nil) {
            cell = [[ProfileTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProfileTableCell"];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileTableCell2"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProfileTableCell2"];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *labelField = (UILabel *)[cell viewWithTag:1];
    UITextField *textField = (UITextField *)[cell viewWithTag:2];
    textField.delegate = self;
    switch (row) {
        case 0: {
            ProfileTableCell *aboutCell = (ProfileTableCell *)cell;
            [aboutCell.titleLabel setText:@"About me"];
            self.aboutMeField = aboutCell.subtitleLabel;
            self.aboutMeField.text = self.user.about_me;
        } break;
        case 1: {
            UILabel *labelField = (UILabel *)[cell viewWithTag:1];
            labelField.text = @"Email";
            self.usernameField = textField;
            self.usernameField.text = self.user.email;
        } break;
        case 2: {
            labelField.text = @"First";
            self.firstNameField = textField;
            self.firstNameField.text = self.user.firstName;
        } break;
        case 3: {
            labelField.text = @"Last";
            self.lastNameField = textField;
            self.lastNameField.text = self.user.lastName;
        } break;
        default: {
            NSLog(@"ERROR: Unknown cell id");
            cell = nil;
        } break;
    }
    return cell;
}

// Dynamically set the height for the cells on the comments table based on their text
// FIX ME: need to change size of font when its established
- (CGFloat)tableView:(UITableView *) heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size = 0.0f;
    CGFloat totalSize =self.navigationController.navigationBar.frame.size.height  + self.tabBarController.tabBar.frame.size.height + self.picture.frame.size.height;
    CGFloat defaultCellSize = totalSize/4;

    // Get the string of text from each comment
    NSString *text = self.user.about_me;
    // Calculate the size of the text using the fixed width of the cell
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:10.0f] constrainedToSize:CGSizeMake(279, 1000)];
    CGFloat aboutMeSize = defaultCellSize + textSize.height;
    CGFloat maxAboutMeSize = totalSize - ((defaultCellSize - 10.0f) * 3.0f);
    
    if(aboutMeSize > maxAboutMeSize) {
        aboutMeSize = maxAboutMeSize;
        defaultCellSize = defaultCellSize - 5.0f;
    }
    else if(aboutMeSize < defaultCellSize) {
        aboutMeSize = defaultCellSize;
    }
    
    if(indexPath.row == 0) {
        size = aboutMeSize;
    }
    else {
        size = defaultCellSize;
    }
    
    return size;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isEditMode) {
        long row = indexPath.row;
        switch (row) {
            case 0:
                self.aboutMeField.userInteractionEnabled = YES;
                self.aboutMeField.editable = YES;
                [self.aboutMeField becomeFirstResponder];
                break;
            case 1:
                break;
            case 2:
                self.firstNameField.userInteractionEnabled = YES;
                [self.firstNameField becomeFirstResponder];
                break;
            case 3:
                self.lastNameField.userInteractionEnabled = YES;
                [self.lastNameField becomeFirstResponder];
                break;
            default:
                break;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = segue.destinationViewController;
    
    __block  BrtrItemsTableViewController * __unsafe_unretained itvc;
    if ([@"ShowMyItems" isEqual: segue.identifier]) {
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = ((UINavigationController *)vc).topViewController;
        }
        if ([vc isKindOfClass:[BrtrItemsTableViewController class]]) {
            itvc = (BrtrItemsTableViewController *) vc;
            itvc.items = [[NSArray alloc] initWithArray: [self.user.my_items allObjects]];
            AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
            itvc.navigationItem.title = [NSString stringWithFormat:@"%@'s Items", ad.user.firstName];
            itvc.allowEditableItems = YES;
            itvc.reloadCall = ^(){[BrtrDataSource getUserItemsForUser:self.user delegate:itvc];  [itvc reloadData]; };
        }
        else {
            // error
        }
    
    }
}


@end
