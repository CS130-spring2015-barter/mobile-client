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

@implementation BrtrDataSource

+(BrtrUser *)getUserForEmail:(NSString *)email
{
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    NSArray *matches = [context fetchObjectsWithEntityName:@"BrtrUser" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"email = %@", email]];
    NSError *error = nil;
    BrtrUser *user = nil;
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        user = [matches firstObject];
    } else {
        // handle error
    }
    return user;
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
        
        for (int i = 0; i < 3; ++i) {
            BrtrCardItem *cardItem = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrCardItem"
                inManagedObjectContext:context];
            cardItem.user = user;
            cardItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"stock"], 1.0);
            cardItem.name = [NSString stringWithFormat: @"Rohan %d" , i];
            cardItem.info = @"House cleaning service";
        }
        BrtrUserItem *userItem = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUserItem" inManagedObjectContext:context];
        userItem.owner = user;
        userItem.picture = UIImageJPEGRepresentation([UIImage imageNamed:@"stock"], 1.0);
        userItem.name = @"House cleaning service";
        userItem.info = @"We do good work!";
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
