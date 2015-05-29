//
//  BrtrDataSource.h
//  Bartr
//
//  Created by admin on 4/25/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrtrUser.h"
#import "BrtrCardItem.h"
#import "DataFetchDelegate.h"

@interface BrtrDataSource : NSObject

+(BrtrUser *)getUserForEmail:(NSString *)email;
+(BrtrUser *) getUserForEmail:(NSString *)email password:(NSString *)pass;
+(void) updateUser:(BrtrUser *)user withChanges:(NSDictionary *)userInfo withDelegate:(id<DataFetchDelegate>)delegate;
+ (void) saveAllData;
+(BOOL)createUserWithEmail:(NSString *)email password:(NSString *)pass;
+(BrtrDataSource *)sharedInstance;

+(NSArray *)getCardStackForUser:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate;
+(void)getUserItemsForUser:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate;
+(void)getUsersLikedMyItem:(NSNumber *) item_id delegate:(id<DataFetchDelegate>)theDelegate;
+(void)getLikedIDsForUser:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate;
+(void)getItemsWithIDs:(NSArray *)ids user:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate liked:(BOOL)liked;

-(void) user:(BrtrUser *)user didLikeItem:(BrtrCardItem *)item delegate:(id<DataFetchDelegate>)theDelegate;
-(void) user:(BrtrUser *)user didRejectItem:(BrtrCardItem *)item delegate:(id<DataFetchDelegate>)theDelegate;
+(void) user:(BrtrUser *)user didAddItemWithName:(NSString *)name andInfo:(NSString *)info andImage:(NSData *)image delegate:(id<DataFetchDelegate>)theDelegate;
+(void) user:(BrtrUser *)user didDeleteItem:(BrtrUserItem *)item delegate:(id<DataFetchDelegate>)theDelegate;
+(NSDictionary *)getUserInfoForUserWithId:(NSNumber *)u_id;
@end
