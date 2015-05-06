//
//  BrtrItemViewController.m
//  Bartr
//
//  Created by Matt Nguyen on 5/5/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrItemViewController.h"

@interface BrtrItemViewController ()
@property (nonatomic, strong) UIImageView *imageView;

- (void) centerContent;
- (void) scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer;
- (void) scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer;

@end


@implementation BrtrItemViewController
@synthesize pictureScrollView = _pictureScrollView;
@synthesize imageView = _imageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // creates an image view
    UIImage *image = [UIImage imageNamed:@"FakePhoto.png"];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
    [self.pictureScrollView addSubview:self.imageView];
    
    
    self.pictureScrollView.contentSize = image.size;
    
    
}

- (void) centerContent {
    
}
- (void) scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer {
    
}

- (void) scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer {
    
}



@end

