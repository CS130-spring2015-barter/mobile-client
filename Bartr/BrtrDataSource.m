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
#include "AppDelegate.h"

@interface BrtrDataSource()
@property (nonatomic, strong) NSArray *liked_items;
@property (nonatomic, strong) NSArray *rejected_items;
- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag;
@end


@implementation BrtrDataSource
@synthesize liked_items  = _likedItems;
@synthesize rejected_items = _rejectedItems;

+(BrtrDataSource *)sharedInstance
{
    static BrtrDataSource *_sharedInstance;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}

-(void) user:(BrtrUser *)user didLikedItem:(BrtrCardItem *)item
{
    NSMutableArray *newLikedItems = [[NSMutableArray alloc] initWithArray:self.liked_items];
    [newLikedItems addObject:item];
    self.liked_items = [newLikedItems copy];

    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    [context deleteObject:item];
    [BrtrDataSource saveAllData];
}

-(void) user:(BrtrUser *)user didRejectItem:(BrtrCardItem *)item
{
    NSMutableArray *newLikedItems = [[NSMutableArray alloc] initWithArray:self.liked_items];
    [newLikedItems addObject:item];
    self.liked_items = [newLikedItems copy];

    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    [context deleteObject:item];
    [BrtrDataSource saveAllData];
}

-(void) user:(BrtrUser *)user didAddItem:(BrtrItem *)item delegate:(id<DataFetchDelegate>)theDelegate
{
    NSLog(@"BrtrDataSource: Liked an item");
}
-(void) user:(BrtrUser *)user didDeleteItem:(BrtrItem *)item delegate:(id<DataFetchDelegate>)theDelegate
{
    
}

// bruh_pls41@gmail.com
// password
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

+(NSURLRequest *)postRequestWith:(NSString *)route post:(NSString *)post
{

    NSLog(@"PostData: %@",post);
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat: @"http://barter.elasticbeanstalk.com/%@" ,route]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    return request;
}

+(NSURLRequest *)getRequestWith:(NSString *)route andQuery:(NSString *)query
{
    NSString *urlString =[NSString stringWithFormat: @"http://barter.elasticbeanstalk.com/%@" ,route];
    
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


+(BOOL)createUserWithEmail:(NSString *)email password:(NSString *)pass
{
    NSString *post =[[NSString alloc] initWithFormat:@"first_name=%@&last_name=%@&email=%@&password=%@&about_me=%@&image=%@", @"First", @"Last", email, pass, @"About me", @"image"];
    NSDictionary *jsonData;
    NSURLRequest *request = [BrtrDataSource postRequestWith:@"user" post:post];
    @try {
        //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
        NSError *error;
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        if ([response statusCode] >= 200 && [response statusCode] < 300)
        {
            NSLog(@"Response ==> %@", responseData);
            jsonData = [NSJSONSerialization
                        JSONObjectWithData:urlData
                        options:NSJSONReadingMutableContainers
                        error:&error];
        }
        else if (nil != error) {
            NSString *error_msg = (NSString *) jsonData[@"message"];
            [[BrtrDataSource sharedInstance] alertStatus:error_msg :@"Create Failed!" :0];
            return NO;
        }
        else {
            //if (error) NSLog(@"Error: %@", error);
            jsonData = [NSJSONSerialization
                        JSONObjectWithData:urlData
                        options:NSJSONReadingMutableContainers
                        error:&error];
            [[BrtrDataSource sharedInstance] alertStatus:@"Create account fail" :[jsonData objectForKey:@"message"]: 0];
            return NO;
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        
        return NO;
    }
    [[BrtrDataSource sharedInstance] alertStatus:@"Create account successful" :[jsonData objectForKey:@"message"]: 0];
    return YES;
}
+(NSDictionary *)getUserInfoForUser:(BrtrUser *)user
{
    NSURLRequest *request = [BrtrDataSource getRequestWith:[NSString stringWithFormat:@"user/%@", user.u_id] andQuery:nil];

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
        }
        else if (nil != error) {
            NSString *error_msg = (NSString *) jsonData[@"message"];
            [[BrtrDataSource sharedInstance] alertStatus:error_msg :@"Sign in Failed!" :0];
        }

        else {
            //if (error) NSLog(@"Error: %@", error);
            [[BrtrDataSource sharedInstance]  alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [[BrtrDataSource sharedInstance] alertStatus:@"Sign in Failed." :@"Error!" :0];
    }
    return jsonData;
}

// bruh_pls41@gmail.com
// password
+(BrtrUser *)getUserForEmail:(NSString *)email password:(NSString *)pass
{
    NSString *post =[[NSString alloc] initWithFormat:@"email=%@&password=%@", email, pass];
    NSLog(@"PostData: %@",post);

    NSURLRequest *request = [BrtrDataSource postRequestWith:@"user/login" post:post];
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
                //NSDictionary *userInfo = [BrtrDataSource getUserInfoForUser:user];
                [BrtrDataSource saveAllData];
            }
            return user;
        }
        else if (nil != error) {
            NSString *error_msg = (NSString *) jsonData[@"message"];
            [[BrtrDataSource sharedInstance] alertStatus:error_msg :@"Sign in Failed!" :0];
        }

        else {
            //if (error) NSLog(@"Error: %@", error);
            [[BrtrDataSource sharedInstance]  alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [[BrtrDataSource sharedInstance] alertStatus:@"Sign in Failed." :@"Error!" :0];
    }
    return user;
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

+(NSArray *)getCardStackForUser:(BrtrUser *)user delegate:(id<DataFetchDelegate>)theDelegate
{
    NSLog(@"BrtrDataSource: Getting card stack for user");
    AppDelegate *ap = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ap startLocationManager];
    CLLocation *location = [ap getGPSData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    NSURLRequest *request = [BrtrDataSource getRequestWith:@"item/geo" andQuery:[NSString stringWithFormat:@"lat=%f&long=%f",location.coordinate.latitude, location.coordinate.latitude]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error) {
            [theDelegate fetchingDataFailed:error];
        }
        else {
            NSHTTPURLResponse *httpResponse = nil;
            NSArray *jsonData = nil;
            if([response isKindOfClass:[NSHTTPURLResponse class]])
            {
                NSLog(@"BrtrDataSource: Received a HTTPResponse");
                httpResponse = (NSHTTPURLResponse *)response;
            }
            else
            {
                // FIXME
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
                //NSLog(@"Data ===>  %@", jsonData);
                AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
                BrtrUser *user = ad.user;
                for (NSDictionary *item in jsonData) {
            
                    NSNumber *user_id = [item valueForKey: @"user_id"];
                    NSNumber *item_id = [item valueForKey: @"id"];
                    NSString *item_title = [item valueForKey: @"item_title"];
                    NSString *item_description = [item valueForKey: @"item_description"];
                    NSDictionary *item_image = [item valueForKey: @"item_image"];
                    NSArray *picture_buffer = [item_image valueForKey:@"data"];
                    
                    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
                    NSArray *matches = [context fetchObjectsWithEntityName:@"BrtrCardItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"i_id = %@", item_id]];
                    Byte *buffer  = malloc([picture_buffer count]);
                    for (unsigned i = 0; i < [picture_buffer count]; ++i) {
                        NSNumber *num = [picture_buffer objectAtIndex:i];
                        buffer[i] = (Byte)[num intValue];
                    }
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
                    fetched_item.info = item_description;
                    fetched_item.name = item_title;
                    fetched_item.picture = [[NSData alloc] initWithBytes:buffer length:[picture_buffer count]];
                }
            }
            else
            {
                // FIXME
                [theDelegate fetchingDataFailed:nil];
                return;
            }
            [BrtrDataSource saveAllData];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [theDelegate didReceiveResponse:nil response:nil];
            }];
        }
    }];

    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    return [context fetchObjectsWithEntityName:@"BrtrCardItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"user.email = %@", user.email]];
}

+(NSArray *)getUserItemsForUser:(BrtrUser *)user
{
   NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
   return [context fetchObjectsWithEntityName:@"BrtrUserItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"user.email = %@", user.email]];
}

+(NSArray *)getLikedItemsForUser:(BrtrUser *)user
{
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    return [context fetchObjectsWithEntityName:@"BrtrLikedItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"user.email = %@", user.email]];
}

+(void) loadFakeData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BrtrUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@", @"foo@bar.com"];
    NSError *error;
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    NSArray *matches = [context executeFetchRequest:request error:&error];
    // first lookup if the user is already in the database
    if (!matches || error || ([matches count] > 1)) {

    } else if (0 == [matches count]) { /* create a new user if no user */
        BrtrUser* user = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUser"
                                             inManagedObjectContext:context];
        user.firstName = @"Foo";
        user.lastName = @"Bar";
        user.about_me = @"I love this app";
        user.email = @"foo@bar.com";
        user.image = UIImageJPEGRepresentation([UIImage imageNamed:@"stock"], 1);

        for (int i = 0; i < 6; ++i) {
            BrtrCardItem *cardItem = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrCardItem"
                inManagedObjectContext:context];
            cardItem.user = user;
            if (i == 0) {
                cardItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"polo"], 1.0);
                cardItem.name = [NSString stringWithFormat: @"Lacoste Polo %d" , i];
                cardItem.info = @"Dark Navy Blue";
            }
            else if (i == 1) {
                cardItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"starwars"], 1.0);
                cardItem.name = [NSString stringWithFormat: @"Lightsaber %d" , i];
                cardItem.info = @"Please use with caution";
            }
            else if (i == 2) {
                cardItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"iwatch"], 1.0);
                cardItem.name = [NSString stringWithFormat: @"Apple Watch %d" , i];
                cardItem.info = @"Mint condition, even tells time";
            }
            else if (i == 3) {
                cardItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"lambo"], 1.0);
                cardItem.name = [NSString stringWithFormat: @"Lamborghini Aventador %d" , i];
                cardItem.info = @"Incredible Car for incredible people";
            }
            else if (i == 4) {
                cardItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"bed"], 1.0);
                cardItem.name = [NSString stringWithFormat: @"Ikea Bed %d" , i];
                cardItem.info = @"Great for sleeping and other activities as well";
            }
            else {
                cardItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"everclear"], 1.0);
                cardItem.name = [NSString stringWithFormat: @"Everclear %d" , i];
                cardItem.info = @"Don't drink and drive (or code)";
            }
        }
        BrtrCardItem *likeItem = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrLikedItem"
                                                               inManagedObjectContext:context];
        likeItem.user = user;
        likeItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"ball"], 1.0);
        likeItem.name = @"Basketball";
        likeItem.info = @"Signed by Michael Jordan";

        BrtrCardItem *likeItem2 = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrLikedItem"
                                                               inManagedObjectContext:context];
        likeItem2.user = user;
        likeItem2.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"harry"], 1.0);
        likeItem2.name = @"Harry Potter and the Chamber of Secrets";
        likeItem2.info = @"The second book of the series!";
        
        BrtrUserItem *userItem = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUserItem" inManagedObjectContext:context];
        userItem.owner = user;
        userItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"boxer"], 1.0);
        userItem.name = @"Boxers";
        userItem.info = @"Sexy men's blue boxers. Great comfort!";
        [BrtrDataSource saveAllData];
    } else {
    }
    [BrtrDataSource saveAllData];
    // next populate the item stack
}

+ (void) saveAllData
{
    [[JCDCoreData sharedInstance] saveContext];
}
@end
