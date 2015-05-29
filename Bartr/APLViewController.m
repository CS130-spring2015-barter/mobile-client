/*
     File: APLViewController.m
 Abstract: Main view controller for the application.
  Version: 2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "APLViewController.h"
#import "AddItemsViewController.h"

@interface APLViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;

@property (nonatomic) IBOutlet UIView *overlayView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *takePictureButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *startStopButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *delayedPhotoButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic, weak) NSTimer *cameraTimer;
@property (nonatomic) NSMutableArray *capturedImages;

@end


@implementation APLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nextButton.hidden = YES;
    self.capturedImages = [[NSMutableArray alloc] init];
    self.navigationController.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // There is not a camera on this device, so don't show the camera button.
        self.navigationItem.rightBarButtonItem = nil;
        
    }
    else {
        [self showCamera:nil];
    }
}

- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated {
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
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //[self presentViewController:self.imagePickerController animated:YES completion:NULL];
}



- (IBAction)showImagePickerForCamera:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


//- (IBAction)showImagePickerForPhotoPicker:(id)sender
//{
//    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nextButton.hidden = self.imageView.image == nil;
}




#pragma mark - Toolbar actions

- (IBAction)done:(id)sender
{
    // Dismiss the camera.
    if ([self.cameraTimer isValid])
    {
        [self.cameraTimer invalidate];
    }
    [self finishAndUpdate];
}


- (IBAction)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AddItemsViewController *itemInfoVC;
    if  ([segue.identifier isEqualToString:@"ShowItemInfoVC"]) {
        itemInfoVC = (AddItemsViewController *)segue.destinationViewController;
        itemInfoVC.itemName = self.itemName;
        itemInfoVC.itemImage = self.imageView.image;
        itemInfoVC.itemDescription = self.itemDescription;
        self.imageView.image = nil;
        [self.imageView.layer setBorderWidth: 0.0];
    }
}


- (IBAction)stopTakingPicturesAtIntervals:(id)sender
{
    // Stop and reset the timer.
    [self.cameraTimer invalidate];
    self.cameraTimer = nil;

    [self finishAndUpdate];
}


- (void)finishAndUpdate
{
    int screen_width= [[UIScreen mainScreen] bounds].size.width;
    [self dismissViewControllerAnimated:YES completion:NULL];

    if ([self.capturedImages count] > 0)
    {
        self.nextButton.hidden = NO;
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            self.imageView.frame = CGRectMake(0, 0, screen_width/2, screen_width/2);
            [self.imageView setClipsToBounds:YES];
            [self.imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
            [self.imageView.layer setBorderWidth: 2.0];
            self.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
        }
        else
        {
            // Camera took multiple pictures; use the list of images for animation.
            self.imageView.animationImages = self.capturedImages;
            self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
            self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
            [self.imageView startAnimating];
        }
        
        // To be ready to start again, clear the captured images array.
        [self.capturedImages removeAllObjects];
    }

    self.imagePickerController = nil;
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.navigationItem.leftBarButtonItem = nil;
    [self.capturedImages addObject:image];

    if ([self.cameraTimer isValid])
    {
        return;
    }

    [self finishAndUpdate];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.navigationItem.leftBarButtonItem = nil;
    [self finishAndUpdate];
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    AddItemsViewController *itemInfoVC;
    if ([unwindSegue.sourceViewController isKindOfClass:[AddItemsViewController class]]) {
        itemInfoVC = (AddItemsViewController *) unwindSegue.sourceViewController;
        self.itemName = itemInfoVC.itemName;
        self.itemDescription = itemInfoVC.itemDescription;
        self.imageView.image = itemInfoVC.itemImage;
        if (self.imageView.image == nil) {
            // TODO
            self.nextButton.hidden = YES;
            [self.imageView.layer setBorderWidth: 0.0];
        }
    }
    else {
        [self.imageView.layer setBorderWidth: 2.0];
    }
    
}

@end

