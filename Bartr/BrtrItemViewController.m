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
@property (strong, nonatomic) IBOutlet UITextField *ownerTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

//- (void) centerContent;
//- (void) scrollViewDoubleTapped:(UITapGestureRecognizer *)recognizer;
//- (void) scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer;

@end


@implementation BrtrItemViewController

@synthesize itemImageView = _itemImageView;
@synthesize scrollView = _scrollView;
@synthesize nameTextField = _nameTextField;
@synthesize descriptionTextView = _descriptionTextView;
@synthesize editable = _editable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // sets description of item
    UIImage *image = [UIImage imageWithData:self.item.picture];
    self.itemImageView.image = image;
    self.itemImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.nameTextField.text = self.item.name;
    self.descriptionTextView.text = self.item.info;
    
    self.descriptionTextView.userInteractionEnabled = YES;
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.scrollEnabled = YES;

    self.nameTextField.userInteractionEnabled = self.editable;
    self.descriptionTextView.userInteractionEnabled = self.editable;
    self.itemImageView.userInteractionEnabled = self.editable;
}

@end

