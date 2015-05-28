//
//  BrtrItem.h
//  Bartr
//
//  Created by admin on 5/2/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BrtrUser;

@interface BrtrItem : NSManagedObject

@property (nonatomic, retain) NSNumber * i_id;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * picture;
//@property (nonatomic, retain) BrtrUser *user;

@end
