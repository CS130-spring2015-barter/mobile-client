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
    NSString *email    = self.emailField.text;
    NSString *password = self.passwordField.text;
    if([email isEqualToString:@"Email"] || [password isEqualToString:@"Password"]
    || [email isEqualToString:@""]      || [password isEqualToString:@""]) {
        [self alertStatus:@"Please enter Email and Password" :@"Sign in Failed!" :0];
    }
    else {
        // Validate emails
        NSError* error;
        NSRegularExpression *regex = [[NSRegularExpression alloc ]initWithPattern:@"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$" options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *result = [regex firstMatchInString:email options:0 range:NSMakeRange(0, [email length])];
        if (nil == result) {
            [self alertStatus:@"Invalid email" :@"Sign in Failed" :0];
        }
        else {
            user = [BrtrDataSource getUserForEmail:email password:password];
        }
        //user = [BrtrDataSource getUserForEmail:email password:password];

    }
    if (nil != user) {
        AppDelegate *appDelegateTemp = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        appDelegateTemp.user = user;
        // store user name and password
        [appDelegateTemp storeEmail:email password:password];
        appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    }
    else {
        self.passwordField.text = @"Password";
        self.passwordField.secureTextEntry = NO;
        self.passwordField.clearsOnBeginEditing = YES;
        [self.passwordField resignFirstResponder];
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

-(void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) {
        if ([alertView.title isEqualToString:@"Create User"]) {
            NSString *email    = [alertView textFieldAtIndex:0].text;
            NSString *password = [alertView textFieldAtIndex:1].text;
            if ([ email isEqualToString: @""] || [password isEqualToString: @""])
            {
                NSLog(@"Nope");
            }
            else {
                [BrtrDataSource createUserWithEmail:email password:password];
            }
        }
    }
}

- (IBAction)createAccountButtonPressed:(UIButton *)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Create User" message:@"Please enter information below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
    av.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
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


@end
