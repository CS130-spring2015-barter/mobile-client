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
#include "AppDelegate.h"

@implementation BrtrDataSource

+(BrtrUser *)getUserForEmail:(NSString *)email
{
    BrtrUser *user = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BrtrUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    NSError *error;
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        user = [matches firstObject];
    } else {
        // handle error
    }
    return user;
}

+(void) loadFakeData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BrtrUser"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@", @"foo@bar.com"];
    NSError *error;
    NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || ([matches count] > 1)) {
    
    }
    else if (0 == [matches count]) {
        BrtrUser* user = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUser"
                                             inManagedObjectContext:context];
        user.firstName = @"Foo";
        user.lastName = @"Bar";
        user.about_me = @"I love this app";
        user.email = @"foo@bar.com";
        user.image = UIImageJPEGRepresentation([UIImage imageNamed:@"stock"], 1);
    }
    request = [NSFetchRequest fetchRequestWithEntityName:@"Brtr"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@", @"foo@bar.com"];
    
    [BrtrDataSource saveAllData];
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
