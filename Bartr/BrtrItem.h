//
//  BrtrItem.h
//  Bartr
//
//  Created by admin on 4/25/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BrtrItem : NSManagedObject

@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * picture;

@end
