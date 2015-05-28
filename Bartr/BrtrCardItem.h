//
//  BrtrCardItem.h
//  
//
//  Created by Synthia Ling on 5/28/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BrtrItem.h"

@class BrtrUser;

@interface BrtrCardItem : BrtrItem

@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) BrtrUser *user;

@end
