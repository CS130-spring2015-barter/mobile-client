//
//  BrtrDataSource.m
//  Bartr
//
//  Created by admin on 4/25/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#import "BrtrDataSource.h"
#import "JCDCoreData.h"
#import "BrtrUser.h"
#import "BrtrCardItem.h"
#import "BrtrUserItem.h"
#import "BrtrLikedItem.h"
#import "BrtrBackendFields.h"
#include "AppDelegate.h"
#include "BrtrBackendFields.h"

@interface BrtrDataSource()
@property (atomic, strong) NSArray *liked_items;
@property (atomic, strong) NSArray *rejected_items;
+ (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag;
+(void) performBackgroundFetchForCardFetchWithDelegate:(id<DataFetchDelegate>)theDelegate;
@end

@implementation BrtrDataSource

@synthesize liked_items  = _likedItems;
@synthesize rejected_items = _rejectedItems;

#pragma mark - Management
+(BrtrDataSource *)sharedInstance
{
    static BrtrDataSource *_sharedInstance;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

+ (void) saveAllData
{
    [[JCDCoreData sharedInstance] saveContext];
}


#pragma mark - Utility Methods
+ (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:[BrtrDataSource sharedInstance]
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

+(NSURLRequest *)postRequestWith:(NSString *)route post:(NSString *)post
{
    NSLog(@"PostData: %@",post);
    AppDelegate *ap = (AppDelegate * )[UIApplication sharedApplication].delegate;
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat: @"%@%@" , ENDPOINT, route]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[ap getAuthToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:postData];
    return request;
}

+(NSURLRequest *)postRequestWith:(NSString *)route dict:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat: @"%@%@" , ENDPOINT, route]];
    
    AppDelegate *ap = (AppDelegate * )[UIApplication sharedApplication].delegate;
    NSString *bodyLength = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:bodyLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:[ap getAuthToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonData];
    return request;
}

+(NSURLRequest *)getRequestWith:(NSString *)route andQuery:(NSString *)query
{
    NSString *urlString = [NSString stringWithFormat: @"%@%@" , ENDPOINT, route];
    
    urlString = (query == nil) ? urlString : [NSString stringWithFormat:@"%@?%@", urlString, query];
    NSURL *url = [NSURL URLWithString:urlString];
    AppDelegate *ap = (AppDelegate * )[UIApplication sharedApplication].delegate;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[ap getAuthToken] forHTTPHeaderField:@"Authorization"];
    return request;
}

+(NSURLRequest *)putRequestWith:(NSString *)route andBody:(NSData *)body
{
    NSString *urlString = [NSString stringWithFormat: @"%@%@" , ENDPOINT, route];
    
    NSURL *url = [NSURL URLWithString:urlString];
    AppDelegate *ap = (AppDelegate * )[UIApplication sharedApplication].delegate;
    NSString *bodyLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:bodyLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:[ap getAuthToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:body];
    return request;
}

+(NSURLRequest *)deleteRequestWith:(NSString *)route andQuery:(NSString *)query
{
    NSString *urlString = [NSString stringWithFormat: @"%@%@" , ENDPOINT, route];
    
    urlString = (query == nil) ? urlString : [NSString stringWithFormat:@"%@?%@", urlString, query];
    NSURL *url = [NSURL URLWithString:urlString];
    AppDelegate *ap = (AppDelegate * )[UIApplication sharedApplication].delegate;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[ap getAuthToken] forHTTPHeaderField:@"Authorization"];
    return request;
}

+(NSData *)decodePictureDictionary:(NSDictionary *)image_dict base64encoded:(BOOL)isBase64
{
    NSData *image_data;
    NSArray *picture_buffer =  [image_dict objectForKey:@"data"];
    Byte *buffer  = malloc([picture_buffer count]);
    for (unsigned i = 0; i < [picture_buffer count]; ++i) {
        NSNumber *num = [picture_buffer objectAtIndex:i];
        buffer[i] = (Byte)[num intValue];
    }
    if (isBase64) {
        NSString *image_string = [[NSString alloc] initWithBytes:buffer length:[picture_buffer count] encoding:NSUTF8StringEncoding];
        image_data = [[NSData alloc] initWithBase64EncodedString:image_string options:0];
    }
    else {
        image_data = [[NSData alloc] initWithBytes:buffer length:[picture_buffer count]];
    }
    return image_data;
}

#pragma mark - Item Data Source
+(NSArray *)getCardStackForUser:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate
{
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    NSArray *matches =  [context fetchObjectsWithEntityName:@"BrtrCardItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"user.email = %@", user.email]];
    if (!matches || 0 == [matches count]) {
        [BrtrDataSource performBackgroundFetchForCardFetchWithDelegate:theDelegate];
        return nil;
    }
    else {
        return matches;
    }
}

+(void)getUserItemsForUser:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate
{
    NSLog(@"Attempting to get my items");
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    NSURLRequest *request = [BrtrDataSource getRequestWith:[NSString stringWithFormat:@"user/%@/item", user.u_id]
                                                  andQuery:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            NSLog(@"BrtrDataSource: Did not get anything for my items");
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSDictionary *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                NSLog(@"BrtrDataSource: Received ids of my items");
                NSError *error = nil;
                jsonData = [NSJSONSerialization
                            JSONObjectWithData:data
                            options:NSJSONReadingMutableContainers
                            error:&error];
                NSArray *item_ids = [jsonData objectForKey:@"item_ids"];
                [theDelegate didReceiveData:item_ids response:httpResponse];
            }
            else
            {
                NSLog(@"BrtrDataSource: Did not receive meaningful response from server");
                [theDelegate fetchingDataFailed:nil];
            }
        }
    }];
    
}
+(void)getUsersLikedMyItem:(NSNumber *) item_id delegate:(id<DataFetchDelegate>)theDelegate
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    NSURLRequest *request = [BrtrDataSource getRequestWith:[NSString stringWithFormat:@"user/%@/item", item_id] andQuery:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            NSLog(@"BrtrDataSource: Did not get users who liked item");
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSDictionary *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                NSLog(@"BrtrDataSource: Received user ids who liked my item");
                NSError *error = nil;
                jsonData = [NSJSONSerialization
                            JSONObjectWithData:data
                            options:NSJSONReadingMutableContainers
                            error:&error];
                NSArray *user_ids = [jsonData objectForKey:@"user_ids"];
                [theDelegate didReceiveData:user_ids response:httpResponse];
            }
            else
            {
                NSLog(@"BrtrDataSource: Did not receive meaningful response from server");
                [theDelegate fetchingDataFailed:nil];
            }
        }
    }];

    
}
+(void)getLikedIDsForUser:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    NSURLRequest *request = [BrtrDataSource getRequestWith:@"item/liked"
                                                  andQuery:[NSString stringWithFormat:@"%@=%@", @"user_id", user.u_id]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            NSLog(@"BrtrDataSource: Did not anything");
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSDictionary *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                NSLog(@"BrtrDataSource: Received ids of items I liked");
                NSError *error = nil;
                jsonData = [NSJSONSerialization
                            JSONObjectWithData:data
                            options:NSJSONReadingMutableContainers
                            error:&error];
                NSArray *item_ids = [jsonData objectForKey:@"item_ids"];
                [theDelegate didReceiveData:item_ids response:httpResponse];
            }
            else
            {
                NSLog(@"BrtrDataSource: Did not receive meaningful response from server");
                [theDelegate fetchingDataFailed:nil];
            }
        }
    }];
}

+(void)getItemsWithIDs:(NSArray *)ids user:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate liked:(BOOL)liked
{
    NSURLRequest *request = [BrtrDataSource getRequestWith:@"item" andQuery:[NSString stringWithFormat:@"%@=%@", @"ids", [[ids valueForKey:@"description"] componentsJoinedByString:@","]]];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";

    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            NSLog(@"BrtrDataSource: Did not anything trying to get item info");
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSMutableArray *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                NSLog(@"BrtrDataSource: Received info for items");
                NSError *error = nil;
                jsonData = [NSJSONSerialization
                            JSONObjectWithData:data
                            options:NSJSONReadingMutableContainers
                            error:&error];

                NSMutableArray *cards = [[NSMutableArray alloc] init];
                for (NSDictionary *item in jsonData) {
                    NSNumber *user_id = [item valueForKey: @"user_id"];
                    NSNumber *item_id = [item valueForKey: KEY_ITEM_ID];
                    NSString *item_title = [item valueForKey: KEY_ITEM_TITLE];
                    NSString *item_description = [item valueForKey: KEY_ITEM_DESC];
                    NSDictionary *image_dict = [item valueForKey:KEY_ITEM_IMAGE];
                    NSData* item_image = [BrtrDataSource decodePictureDictionary:image_dict base64encoded:YES];

                    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
                    
                    NSString *entity_name;
                    if (liked) {
                        entity_name = @"BrtrLikedItem";
                    }
                    else {
                        entity_name = @"BrtrUserItem";
                    }
                    
                    NSArray *matches = [context fetchObjectsWithEntityName:entity_name sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"i_id = %@", item_id]];
                    
                    BrtrItem* item;
                    if (matches && [matches count] == 1) {
                        item = [matches objectAtIndex: 0];
                        
                    } else if (0 == [matches count]) {
                        item = [NSEntityDescription insertNewObjectForEntityForName:entity_name inManagedObjectContext:context];
                    } else {
                        NSLog(@"Error in get card items");
                    }
                    
                    item.i_id = item_id;
                    item.info = item_description;
                    item.name = item_title;
                    item.picture = item_image;
                    
                    if (liked) {
                        BrtrLikedItem *liked_item = (BrtrLikedItem *)item;
                        liked_item.user = user;
                        liked_item.owner_id = user_id;
                        [cards addObject:liked_item];
                    }
                    else {
                        BrtrUserItem *user_item = (BrtrUserItem *)item;
                        user_item.owner = user;
                        [cards addObject:user_item];
                    }
                }
                [BrtrDataSource saveAllData];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [theDelegate didReceiveData:[cards  copy] response:response];
                }];
            }
            else
            {
                NSLog(@"BrtrDataSource: Did not receive meaningful response from server for item info");
                [theDelegate fetchingDataFailed:nil];
            }
        }
    }];
}

-(void) user:(BrtrUser *)user didLikeItem:(BrtrCardItem *)item delegate:(id<DataFetchDelegate>)theDelegate
{
    NSMutableArray *newLikedItems = [[NSMutableArray alloc] initWithArray:self.liked_items];
    [newLikedItems addObject:item];
    self.liked_items = [newLikedItems copy];
    
    NSLog(@"BrtrDataSource: Attemping to like item number %@", item.i_id);
    [self performBackgroundFetchWith:@"item/liked" AndUser:user andItem:item WithDelegate:theDelegate];
}

-(void) user:(BrtrUser *)user didRejectItem:(BrtrCardItem *)item delegate:(id<DataFetchDelegate>)theDelegate
{
    NSMutableArray *newSeenItems = [[NSMutableArray alloc] initWithArray:self.rejected_items];
    [newSeenItems addObject:item];
    self.rejected_items = [newSeenItems copy];
    
    NSLog(@"BrtrDataSource: Attemping to reject item number %@", item.i_id);
    [self performBackgroundFetchWith:@"item/seen" AndUser:user andItem:item WithDelegate:theDelegate];
}



+(void) user:(BrtrUser *)user didAddItemWithName:(NSString *)name andInfo:(NSString *)info andImage:(NSData *)image delegate:(id<DataFetchDelegate>)theDelegate
{
    NSLog(@"BrtrDataSource: Attempting to add item");
    
    NSMutableDictionary *item_info = [[NSMutableDictionary alloc] init];
    NSString *encoded_pic_data = [image base64EncodedStringWithOptions:kNilOptions];
    
    [item_info setObject:[NSString stringWithFormat:@"%@", user.u_id] forKey:KEY_USER_ID];
    [item_info setObject:name forKey:KEY_ITEM_TITLE];
    [item_info setObject:info forKey:KEY_ITEM_DESC];
    [item_info setObject:encoded_pic_data forKey:KEY_ITEM_IMAGE];
    NSURLRequest *request = [BrtrDataSource postRequestWith:ROUTE_ITEM_ADD dict:item_info];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";

    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSDictionary *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            NSString *responseData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSError *serialError;
            jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableContainers
                                                       error:&serialError];
            
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300) {
                NSLog(@"Response ==> %@", responseData);
                NSLog(@"BrtrDataSource: Successfully added an item");
                
                // Creates new object in DB and persists it
                NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
                BrtrUserItem *new_item = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUserItem" inManagedObjectContext:context];
                new_item.name = name;
                new_item.info = info;
                new_item.picture = image;
                new_item.i_id = [jsonData objectForKey:@"item_id"];
                new_item.owner = user;
                
                [BrtrDataSource saveAllData];
                [theDelegate didReceiveData:nil response:response];
            }
            else if(error != nil) {
                NSString *error_msg = (NSString *) jsonData[@"message"];
                NSLog(@"BrtrDataSource: Could not add item");
                NSLog(@"Error: %@", error_msg);
                [theDelegate fetchingDataFailed:error];
                return;
            }
            else {
                [theDelegate fetchingDataFailed:nil];
                return;
            }
        }
    }];
}

+(void) user:(BrtrUser *)user didDeleteItem:(BrtrUserItem *)item delegate:(id<DataFetchDelegate>)theDelegate
{
    NSLog(@"BrtrDataSource: Attempting to delete item %@", item.i_id);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    NSURLRequest *request = [BrtrDataSource deleteRequestWith:[NSString stringWithFormat:@"item/%@", item.i_id]
                                                     andQuery:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            NSLog(@"BrtrDataSource: Did not anything when trying to delete");
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                NSLog(@"BrtrDataSource: Successfully deleted item");
                NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
                [context deleteObject:item];
            }
            else
            {
                NSLog(@"BrtrDataSource: Did not receive meaningful response from server");
                [theDelegate fetchingDataFailed:nil];
            }
        }
    }];
}

#pragma mark - User Data Source
+(BOOL)createUserWithEmail:(NSString *)email password:(NSString *)pass
{
    NSData *image_data = UIImagePNGRepresentation([UIImage imageNamed:@"Icon-user"]);
    NSString *image_string = [image_data base64EncodedStringWithOptions:kNilOptions];
    NSString *post =[[NSString alloc] initWithFormat:@"%@=%@&%@=%@&%@=%@&%@=%@&%@=%@&%@=%@", KEY_USER_FIRST_NAME, @"First",
                                                                                             KEY_USER_LAST_NAME, @"Last",
                                                                                             KEY_USER_EMAIL, email,
                                                                                             KEY_USER_PASSWORD, pass,
                                                                                             KEY_USER_ABOUTME, @"About me",
                                                                                             KEY_USER_IMAGE  , image_string];
    NSDictionary *jsonData;
    NSURLRequest *request = [BrtrDataSource postRequestWith:@"user" post:post];
    @try {
        //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
        NSError *error;
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        //NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        if ([response statusCode] >= 200 && [response statusCode] < 300)
        {
            jsonData = [NSJSONSerialization
                        JSONObjectWithData:urlData
                        options:NSJSONReadingMutableContainers
                        error:&error];
        }
        else if (nil != error) {
            NSString *error_msg = (NSString *) jsonData[@"message"];
            [BrtrDataSource alertStatus:error_msg :@"Create Failed!" :0];
            return NO;
        }
        else {
            //if (error) NSLog(@"Error: %@", error);
            jsonData = [NSJSONSerialization
                        JSONObjectWithData:urlData
                        options:NSJSONReadingMutableContainers
                        error:&error];
            [BrtrDataSource alertStatus:@"Create account fail" :[jsonData objectForKey:@"message"]: 0];
            return NO;
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        
        return NO;
    }
    [BrtrDataSource alertStatus:@"Create account successful" :[jsonData objectForKey:@"message"]: 0];
    return YES;
}

+(BrtrUser *)getUserForEmail:(NSString *)email
{
    BrtrUser *user = nil;
    NSError *error = nil;
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    NSArray *matches = [context fetchObjectsWithEntityName:@"BrtrUser" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"email = %@", email]];
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        user = [matches firstObject];
    } else {
        // handle error
    }
    return user;
}

+(NSDictionary *)getUserInfoForUserWithId:(NSNumber *)u_id
{
    NSURLRequest *request = [BrtrDataSource getRequestWith:[NSString stringWithFormat:ROUTE_USER_GET, u_id]  andQuery:nil];
    
    NSDictionary *jsonData;
    @try {
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        if ([response statusCode] >= 200 && [response statusCode] < 300)
        {
            NSError *error = nil;
            jsonData = [NSJSONSerialization
                        JSONObjectWithData:urlData
                        options:NSJSONReadingMutableContainers
                        error:&error];
        }
        else if (nil != error) {
            NSString *error_msg = (NSString *) jsonData[@"message"];
            [BrtrDataSource alertStatus:error_msg :@"Sign in Failed!" :0];
        }
        
        else {
            //if (error) NSLog(@"Error: %@", error);
            [BrtrDataSource alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [BrtrDataSource alertStatus:@"Sign in Failed." :@"Error!" :0];
    }
    return jsonData;
}

+(NSDictionary *)getUserInfoForUser:(BrtrUser *)user
{
    return [BrtrDataSource getUserInfoForUserWithId:user.u_id];
}

+(BrtrUser *)getUserForEmail:(NSString *)email password:(NSString *)pass
{
    NSString *post =[[NSString alloc] initWithFormat:@"%@=%@&%@=%@", KEY_USER_EMAIL, email, KEY_USER_PASSWORD, pass];
    NSLog(@"PostData: %@",post);

    NSURLRequest *request = [BrtrDataSource postRequestWith:ROUTE_USER_LOGIN post:post];
    BrtrUser *user = nil;
    NSDictionary *jsonData;
    @try {
        //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];

        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        if ([response statusCode] >= 200 && [response statusCode] < 300)
        {
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"Response ==> %@", responseData);

            NSError *error = nil;
            jsonData = [NSJSONSerialization
                                      JSONObjectWithData:urlData
                                      options:NSJSONReadingMutableContainers
                                      error:&error];


            NSLog(@"Login SUCCESS");
            // fetch from database
            NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
            NSArray *matches = [context fetchObjectsWithEntityName:@"BrtrUser" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"email = %@", email]];
            AppDelegate *ap = (AppDelegate *)[UIApplication sharedApplication].delegate;
            BrtrUser *user = nil;
            [ap storeUserAuthToken:[jsonData objectForKey:@"token"]];
            if (!matches || error || ([matches count] > 1)) {
                // handle error
            } else if ([matches count]) {
                user = [matches firstObject];
                user.u_id = [jsonData objectForKey:@"user_id"];
            } else {
                user = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUser"
                                              inManagedObjectContext:context];
                user.email = email;
                user.u_id = [jsonData objectForKey:@"user_id"];
                NSDictionary *userInfo = [BrtrDataSource getUserInfoForUser:user];
                user.firstName = [userInfo objectForKey:KEY_USER_FIRST_NAME];
                user.lastName  = [userInfo objectForKey:KEY_USER_LAST_NAME];
                user.about_me  = [userInfo objectForKey:KEY_USER_ABOUTME];
                NSDictionary *image_dict = [userInfo objectForKey:KEY_USER_IMAGE];
                user.image = [BrtrDataSource decodePictureDictionary:image_dict base64encoded:YES];
                [BrtrDataSource saveAllData];
            }
            return user;
        }
        else if (nil != error) {
            NSString *error_msg = (NSString *) jsonData[@"message"];
            [BrtrDataSource alertStatus:error_msg :@"Sign in Failed!" :0];
        }

        else {
            //if (error) NSLog(@"Error: %@", error);
            [BrtrDataSource alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [BrtrDataSource alertStatus:@"Sign in Failed." :@"Error!" :0];
    }
    return user;
}

+(void) updateUser:(BrtrUser *)user withChanges:(NSDictionary *)userInfo withDelegate:(id<DataFetchDelegate>)delegate
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"UserOperationsQueue";
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
    NSURLRequest *request = [BrtrDataSource putRequestWith:[[NSString alloc] initWithFormat:ROUTE_USER_UPDATE, user.u_id] andBody:jsonData];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            [delegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSMutableArray *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                NSError *error = nil;
                jsonData = [NSJSONSerialization
                            JSONObjectWithData:data
                            options:NSJSONReadingMutableContainers
                            error:&error];
                NSLog(@"Response ==> %@", jsonData);
            }
        }
    }];
}

-(void)performBackgroundFetchWith:(NSString *)route AndUser:(BrtrUser *)user andItem:(BrtrCardItem *)item WithDelegate:(id<DataFetchDelegate>)theDelegate
{
    NSMutableDictionary *item_dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    __block NSArray* items_arr;
    if([route  isEqual: @"item/liked"]) {
        items_arr = [self.liked_items copy];
        for (BrtrCardItem* item in self.liked_items) {
            [items addObject:[item.i_id stringValue]];
        }
    }
    else {
        items_arr = [self.rejected_items copy];
        for (BrtrCardItem* item in self.rejected_items) {
            [items addObject:[item.i_id stringValue]];
        }
    }
    
    [item_dict setObject:[NSString stringWithFormat:@"%@", user.u_id] forKey:@"user_id"];
    [item_dict setObject:items forKey:@"item_ids"];
    
    NSURLRequest *request = [BrtrDataSource postRequestWith:route dict:item_dict];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse for liked/rejected item");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse for liked/rejected item");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                NSLog(@"BrtrDataSource: Successfully liked/rejected item");
                
                NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
                NSMutableArray *mut_items_arr = [[NSMutableArray alloc] initWithArray:items_arr];
                for (NSString *item_id in items) {
                    for (BrtrCardItem* i in items_arr) {
                        if([item_id isEqual:[i.i_id stringValue]]) {
                            [mut_items_arr removeObject:i];
                            [context deleteObject:i];
                            break;
                        }
                    }
                }

                if([route isEqual:@"item/liked"]) {
                    for (BrtrCardItem* i in self.liked_items) {
                        NSArray *matches = [context fetchObjectsWithEntityName:@"BrtrLikedItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"i_id = %@", i.i_id]];
                        BrtrLikedItem *liked_item;
                        if (matches && [matches count] == 1) {
                            liked_item = [matches objectAtIndex: 0];
                        } else if (0 == [matches count]) {
                            liked_item = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrLikedItem" inManagedObjectContext:context];
                        } else {
                            NSLog(@"Error in get card items");
                        }

                        liked_item.i_id = i.i_id;
                        liked_item.info = i.info;
                        liked_item.name = i.name;
                        liked_item.picture = i.picture;
                        liked_item.user = user;
                        liked_item.owner_id = i.owner_id;
                    }
                    self.liked_items = [mut_items_arr copy];
                }
                else {
                    self.rejected_items = [mut_items_arr copy];
                }
                [BrtrDataSource saveAllData];
            }
            else
            {
                NSLog(@"BrtrDataSource: Did not successfully like/reject item");
                return;
            }
        }
    }];
}

+(void)performBackgroundFetchForCardFetchWithDelegate:(id<DataFetchDelegate>)theDelegate
{
    NSLog(@"BrtrDataSource: Getting card stack for user");
    AppDelegate *ap = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    CLLocationCoordinate2D location = [ap getGPSData];

    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    NSURLRequest *request = [BrtrDataSource getRequestWith:ROUTE_ITEM_GET
                                                  andQuery:[NSString stringWithFormat:@"%@=%f&%@=%f&%@=%@",KEY_USER_LOC_LAT, location.latitude, KEY_USER_LOC_LONG, location.latitude, @"user_id", ap.user.u_id]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSMutableArray *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                NSLog(@"BrtrDataSource: ERROR did not receive HTTPResponse");
                return;
            }
            
            NSLog(@"BrtrDataSource: Response code: %ld", (long)[httpResponse statusCode]);
            if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            {
                // creates json object out of HTTPResponse
                NSError *error = nil;
                jsonData = [NSJSONSerialization
                            JSONObjectWithData:data
                            options:NSJSONReadingMutableContainers
                            error:&error];
                AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
                BrtrUser *user = ad.user;
                NSMutableArray *cards = [[NSMutableArray alloc] init];
                for (NSDictionary *item in jsonData) {
                    NSNumber *owner_id = [item valueForKey: KEY_USER_ID];
                    NSNumber *item_id = [item valueForKey: KEY_ITEM_ID];
                    NSString *item_title = [item valueForKey: KEY_ITEM_TITLE];
                    NSString *item_description = [item valueForKey: KEY_ITEM_DESC];
                    NSDictionary *image_dict = [item valueForKey: KEY_ITEM_IMAGE];
                    NSData *item_image = [BrtrDataSource decodePictureDictionary:image_dict base64encoded:YES];
                    
                    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
                    NSArray *matches = [context fetchObjectsWithEntityName:@"BrtrCardItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"i_id = %@", item_id]];
                    BrtrCardItem *fetched_item;
                    if (matches && [matches count] == 1) {
                        fetched_item = [matches objectAtIndex: 0];
                        
                    } else if (0 == [matches count]) {
                        fetched_item = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrCardItem" inManagedObjectContext:context];
                        
                    } else {
                        NSLog(@"Error in get card items");
                    }
                    fetched_item.user = user;
                    fetched_item.i_id = item_id;
                    fetched_item.owner_id = owner_id;
                    fetched_item.info = item_description;
                    fetched_item.name = item_title;
                    fetched_item.picture = item_image;
                    [cards addObject:fetched_item];
                }
                [BrtrDataSource saveAllData];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [theDelegate didReceiveData:[cards  copy] response:response];
                }];
            }
            else
            {
                [theDelegate fetchingDataFailed:nil];
                return;
            }
        }
    }];
}

@end
