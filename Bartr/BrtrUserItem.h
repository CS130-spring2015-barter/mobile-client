//
//  BrtrUserItem.h
//  Bartr
//
//  Created by admin on 5/2/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BrtrItem.h"

@class BrtrUser;

@interface BrtrUserItem : BrtrItem

@property (nonatomic, retain) BrtrUser *owner;

@end
