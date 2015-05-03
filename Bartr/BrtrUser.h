//
//  BrtrUser.h
//  Bartr
//
//  Created by admin on 5/2/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BrtrItem, BrtrLikedItem, BrtrUserItem;

@interface BrtrUser : NSManagedObject

@property (nonatomic, retain) NSString * about_me;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * u_id;
@property (nonatomic, retain) NSSet *liked_items;
@property (nonatomic, retain) NSSet *my_items;
@property (nonatomic, retain) NSSet *item_stack;
@end

@interface BrtrUser (CoreDataGeneratedAccessors)

- (void)addLiked_itemsObject:(BrtrLikedItem *)value;
- (void)removeLiked_itemsObject:(BrtrLikedItem *)value;
- (void)addLiked_items:(NSSet *)values;
- (void)removeLiked_items:(NSSet *)values;

- (void)addMy_itemsObject:(BrtrUserItem *)value;
- (void)removeMy_itemsObject:(BrtrUserItem *)value;
- (void)addMy_items:(NSSet *)values;
- (void)removeMy_items:(NSSet *)values;

- (void)addItem_stackObject:(BrtrItem *)value;
- (void)removeItem_stackObject:(BrtrItem *)value;
- (void)addItem_stack:(NSSet *)values;
- (void)removeItem_stack:(NSSet *)values;

@end
