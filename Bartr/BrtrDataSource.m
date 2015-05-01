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
        user = [NSEntityDescription insertNewObjectForEntityForName:@"BrtrUser"
                                            inManagedObjectContext:context];
        user.email = email;
        [[JCDCoreData sharedInstance] saveContext];
    }
    return user;
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
