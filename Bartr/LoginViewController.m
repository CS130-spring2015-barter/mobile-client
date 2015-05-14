//
//  LoginViewController.m
//  Bartr
//
//  Created by admin on 5/11/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITableView *userFields;
@property (weak, nonatomic) UITextField *emailField;
@property (weak, nonatomic) UITextField *passwordField;
@end

@implementation LoginViewController
- (IBAction)loginButtonPressed:(id)sender {
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];

    appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userFields.delegate = self;
    self.userFields.dataSource = self;

    self.userFields.estimatedRowHeight = 44;
    self.userFields.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.


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

//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//
//    UIEdgeInsets contentInsets;
//    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
//        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
//    } else {
//        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
//    }
//
//    self.userFields.contentInset = contentInsets;
//    self.userFields.scrollIndicatorInsets = contentInsets;
//    [self.userFields scrollToRowAtIndexPath:[self.userFields indexPathForSelectedRow] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//}

//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    self.userFields.contentInset = UIEdgeInsetsZero;
//    self.userFields.scrollIndicatorInsets = UIEdgeInsetsZero;
//}

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
