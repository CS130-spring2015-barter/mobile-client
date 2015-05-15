//
//  LoginViewController.m
//  Bartr
//
//  Created by admin on 5/11/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "BrtrDataSource.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITableView *userFields;
@property (weak, nonatomic) UITextField *emailField;
@property (weak, nonatomic) UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag;
@end

@implementation LoginViewController

- (IBAction)loginButtonPressed:(UIButton *)sender {
    BrtrUser *user = nil;
    if([self.emailField.text isEqualToString:@""] || [self.passwordField.text isEqualToString:@""] ) {
        
        [self alertStatus:@"Please enter Email and Password" :@"Sign in Failed!" :0];
        
    }
    else {
      //user = [BrtrDataSource getUserForEmail:self.emailField.text password:self.passwordField.text];
    }
    if (nil != user) {
        AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
        appDelegateTemp.user = user;
        // store user name and password
        appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else {
        self.passwordField.text = @"Password";
        self.passwordField.secureTextEntry = NO;
    }
}
- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        // hook up forgot password backend stuff
        NSLog(@"Forgot password");
    }
}

- (IBAction)forgotPasswordButtonPressed:(UIButton *)sender
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:@"Please enter email below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
}

- (IBAction)createAccountButtonPressed:(UIButton *)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userFields.delegate = self;
    self.userFields.dataSource = self;

    self.userFields.estimatedRowHeight = 44;
    self.userFields.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
    self.loginButton.layer.cornerRadius = 10;


}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)userFields
{
    return 1;
}

-(NSInteger ) tableView:(UITableView *)userFields numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.passwordField == textField) {
        textField.secureTextEntry = YES;
        [textField becomeFirstResponder];
    }
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    if (self.passwordField == textField) {
        if ([textField.text isEqualToString:@""]) {
            textField.secureTextEntry = NO;
            textField.text = @"Password";
        }
        else {
            textField.clearsOnBeginEditing = NO;
        }
    }
    else if (self.emailField == textField) {
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"Email";
        }
        else {
            textField.clearsOnBeginEditing = NO;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)userFields cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [userFields dequeueReusableCellWithIdentifier:@"UserInfoCell" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserInfoCell"];
    }
    long row = indexPath.row;
    userFields.layer.cornerRadius = 10;

    UITextField *inputField = (UITextField *)[cell viewWithTag:100];
    inputField.delegate = self;
    inputField.clearsOnBeginEditing = YES;
    if (0 == row)
    {
        inputField.text = @"Email";
        self.emailField = inputField;
    }
    else if (1 == row) {
        inputField.text = @"Password";
        inputField.secureTextEntry = NO;
        self.passwordField = inputField;
    }
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)userFields:(UITableView *)userFields canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)userFields:(UITableView *)userFields commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [userFields deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)userFields:(UITableView *)userFields moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)userFields:(UITableView *)userFields canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
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
