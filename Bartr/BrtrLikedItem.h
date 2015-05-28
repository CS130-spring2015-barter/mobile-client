//
//  BrtrLikedItem.h
//  Bartr
//
//  Created by Tung Nguyen on 5/27/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BrtrItem.h"

@class BrtrUser;

@interface BrtrLikedItem : BrtrItem

@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) BrtrUser *user;

@end
