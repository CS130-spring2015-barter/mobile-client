//
//  BrtrItemViewController.h
//  Bartr
//
//  Created by Matt Nguyen on 5/5/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrtrItem.h"

@interface BrtrItemViewController : UIViewController <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) BrtrItem *item;
@property                     BOOL     editable;
@end
