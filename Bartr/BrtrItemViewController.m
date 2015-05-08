//
//  BrtrItemViewController.m
//  Bartr
//
//  Created by Matt Nguyen on 5/5/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrItemViewController.h"


@interface BrtrItemViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ownerTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

//- (void) centerContent;
//- (void) scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer;
//- (void) scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer;

@end


@implementation BrtrItemViewController

@synthesize itemImageView = _itemImageView;
@synthesize scrollView = _scrollView;
@synthesize nameTextField = _nameTextField;
@synthesize ownerTextField = _ownerTextField;
@synthesize descriptionTextView = _descriptionTextView;

- (void)viewDidLoad {
    
    // sets description of item
    UIImage *image = [UIImage imageWithData:self.item.picture];
    self.itemImageView.image = image;
    self.nameTextField.text = self.item.name;
    self.descriptionTextView.text = self.item.info;
}

//@synthesize pictureScrollView = _pictureScrollView;
//@synthesize imageView = _imageView;
//
//// delegate function that tells the controller which view is getting viewed
//- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return self.imageView;
//}
//
//// when zooming, you need to recenter the content so it doesn't zoom weird
//- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
//    [self centerContent];
//}
//
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    // creates an image view
//    UIImage *image = [UIImage imageNamed:@"stock"];
//    self.imageView = [[UIImageView alloc] initWithImage:image];
//    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=self.pictureScrollView.bounds.size};
//    [self.pictureScrollView addSubview:self.imageView];
//    
//    
//    self.pictureScrollView.contentSize = image.size;
//    
//    // creates gesture recognizer for double tap
//    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
//    doubleTapRecognizer.numberOfTapsRequired = 2;
//    doubleTapRecognizer.numberOfTouchesRequired = 1;
//    [self.pictureScrollView addGestureRecognizer:doubleTapRecognizer];
//    
//    // creates gesture recognizer for 2 finger tapping
//    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc]
//                                                      initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
//    twoFingerTapRecognizer.numberOfTapsRequired = 1;
//    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
//    [self.pictureScrollView addGestureRecognizer:twoFingerTapRecognizer];
//}
//
//// remember that view sizes aren't defined till viewWillAppear
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    // sets up zoom scale for the picture
//    // do this here because size of views are known here not in viewDidLoad
//    CGRect scrollFrame = self.pictureScrollView.frame;
//    CGFloat heightScale =  scrollFrame.size.height / self.pictureScrollView.contentSize.height;
//    CGFloat widthScale = scrollFrame.size.width / self.pictureScrollView.contentSize.width;
//    CGFloat zoomScale = MIN(heightScale, widthScale);
//    self.pictureScrollView.minimumZoomScale = zoomScale;
//    self.pictureScrollView.zoomScale = zoomScale;
//    self.pictureScrollView.maximumZoomScale = 1.0f;
//    
//    [self centerContent];
//}
//
//
//// forces image to be in the center of scrollView
//// in cases where the picture is smaller than the bounds of the scrollView
//// creates a new image frame that moves the pics origin
//- (void) centerContent {
//    CGSize boundSize = self.pictureScrollView.bounds.size;
//    CGRect newFrame = self.imageView.frame;
//    
//    newFrame.origin.y = 0.0f;
//    newFrame.origin.x = 0.0f;
//    
//    if(newFrame.size.height < boundSize.height) {
//        newFrame.origin.y = (boundSize.height - newFrame.size.height) / 2.0f;
//    }
//    
//    if(newFrame.size.width < boundSize.width) {
//        newFrame.origin.x = (boundSize.width - newFrame.size.width) / 2.0f;
//    }
//    
//    self.imageView.frame = newFrame;
//}
//
//// handles zoom when user dobule taps at a particular point
//- (void) scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer {
//    // specifies which point that the user wants to zoom in on
//    CGPoint pointToZoom = [recognizer locationInView:self.imageView];
//    
//    // calculates the scale of the zoom
//    CGFloat zoomScale = self.pictureScrollView.zoomScale * 1.5f;
//    zoomScale = MIN(zoomScale, self.pictureScrollView.maximumZoomScale);
//    
//    // calculate the rectangle that you want to zoom in on
//    // this rectangle will be placed by the pointToZoom calculated above
//    CGSize pictureScrollViewSize = self.pictureScrollView.bounds.size;
//    
//    // defines size of rectangle
//    CGFloat width = pictureScrollViewSize.width / zoomScale;
//    CGFloat height = pictureScrollViewSize.height / zoomScale;
//    CGFloat xPoint = pointToZoom.x - (width/2.0f);
//    CGFloat yPoint = pointToZoom.y - (height/2.0f);
//    
//    CGRect zoomRect = CGRectMake(xPoint, yPoint, width, height);
//    
//    // informs scroll view to zoom in to the rectangle defined
//    [self.pictureScrollView zoomToRect:zoomRect animated:YES];
//}
//
//// handles zoom when user pinches
//// in this case we don't care where the user tapped with 2 fingers
//- (void) scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer {
//    CGFloat zoomScale = self.pictureScrollView.zoomScale * 1.5f;
//    zoomScale = MAX(zoomScale, self.pictureScrollView.minimumZoomScale);
//    [self.pictureScrollView setZoomScale:zoomScale animated:YES];
//}



@end

