//
//  LCImageViewController.h
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "JTSImageViewController.h"

@interface LCImageViewController : JTSImageViewController <LYRProgressDelegate>
@property(nonatomic, strong) LYRMessage *message;

- (id)initWithImageInfo:(JTSImageInfo *)info mode:(enum JTSImageViewControllerMode)mode backgroundStyle:(enum JTSImageViewControllerBackgroundOptions)style message:(LYRMessage *)message;
@end
