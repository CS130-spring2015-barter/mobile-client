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


+(BOOL)createUserWithEmail:(NSString *)email password:(NSString *)pass
{
    NSString *post =[[NSString alloc] initWithFormat:@"first=%@&last=%@&email=%@&password=%@&about_me=%@&image=%@", @"First", @"Last", email, pass, @"About me", @"image"];
    NSDictionary *jsonData;
    NSURLRequest *request = [BrtrDataSource postRequestWith:@"user" post:post];
    @try {
        //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
        if ([response statusCode] >= 200 && [response statusCode] < 300)
        {
            NSLog(@"Response ==> %@", responseData);
            
            NSError *error = nil;
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
            [[BrtrDataSource sharedInstance]  alertStatus:@"Connection Failed" :@"Create Failed!" :0];
            return NO;
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [[BrtrDataSource sharedInstance] alertStatus:@"Sign in Failed." :@"Error!" :0];
        return NO;
    }
    return YES;
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
            AppDelegate *ap = [UIApplication sharedApplication].delegate;
            BrtrUser *user = nil;
            [ap storeUserAuthToken:[jsonData objectForKey:@"token"]];
            if (!matches || error || ([matches count] > 1)) {
                // handle error
            } else if ([matches count]) {
                user = [matches firstObject];
            } else {
                
                user = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUser"
                                              inManagedObjectContext:context];
                user.email = email;
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

+(NSArray *)getCardStackForUser:(BrtrUser *)user
{
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
    BrtrUser* user  = nil;
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
        user = [matches firstObject];
    }
    [BrtrDataSource saveAllData];
    // next populate the item stack

    
}

+ (void) saveAllData
{
    [[JCDCoreData sharedInstance] saveContext];
}

/*
 + (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
 inManagedObjectContext:(NSManagedObjectContext *)context
 {
 Photo *photo = nil;
 
 NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
 request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
 
 NSError *error;
 NSArray *matches = [context executeFetchRequest:request error:&error];
 
 if (!matches || error || ([matches count] > 1)) {
 // handle error
 } else if ([matches count]) {
 photo = [matches firstObject];
 } else {
 photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
 inManagedObjectContext:context];
 photo.unique = unique;
 photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
 photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
 photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
 
 NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
 photo.whoTook = [Photographer photographerWithName:photographerName
 inManagedObjectContext:context];
 
 }
 
 return photo;
 }
 */
@end
