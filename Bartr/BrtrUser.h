//
//  BrtrUser.h
//  Bartr
//
//  Created by admin on 4/25/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BrtrLikedItem, BrtrUserItem;

@interface BrtrUser : NSManagedObject

@property (nonatomic, retain) NSString * about_me;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSSet *liked_items;
@property (nonatomic, retain) NSSet *my_items;
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

@end
