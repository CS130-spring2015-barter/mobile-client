//
//  BrtrSwipeyViewController.h
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableViewBackground.h"
#import "BrtrUser.h"
@interface BrtrSwipeyViewController : UIViewController <DraggableViewBackgroundDelegate>
@property (weak,nonatomic)BrtrUser* user;

@end
