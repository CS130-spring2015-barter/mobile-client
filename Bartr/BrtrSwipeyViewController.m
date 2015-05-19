//
//  BrtrSwipeyViewController.m
//  Bartr
//
//  Created by admin on 4/19/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "BrtrSwipeyViewController.h"
#import "BrtrUser.h"
#import "BrtrStartupTabViewController.h"
#import "DraggableViewBackground.h"
#import "BrtrCardItem.h"
#import "BrtrDataSource.h"
#import "AppDelegate.h"
#import "DataFetchDelegate.h"
#import "JCDCoreData.h"

@interface BrtrSwipeyViewController () <DataFetchDelegate>

@end

@implementation BrtrSwipeyViewController
@synthesize user;
-(void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.user = ad.user;
    
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.bounds andDelegate:self];
    [self.view addSubview:draggableBackground];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)userClickedItem:(BrtrCardItem *)card
{
    //[self performSegueWithIdentifier:@"ShowItem" sender:self];
}

-(NSArray *) getMultipleCards {

    return [BrtrDataSource getCardStackForUser:user delegate:self];
}

-(void) itemSwipedRight:(BrtrCardItem *)item
{
    [[BrtrDataSource sharedInstance] user:self.user didLikedItem:item];
}

-(void) itemSwipedLeft:(BrtrCardItem *)item
{
    [[BrtrDataSource sharedInstance] user:self.user didRejectItem:item];
}

- (void) didReceiveResponse:(NSData *) data response:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = nil;
    NSDictionary *jsonData = nil;
    if([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSLog(@"BrtrSwipeyView: Received a HTTPResponse");
        httpResponse = (NSHTTPURLResponse *)response;
    }
    else
    {
        // FIXME
        NSLog(@"BrtrSwipeyView: ERROR did not receive HTTPResponse");
        return;
    }
    
    NSLog(@"BrtrSwipeyView: Response code: %ld", (long)[httpResponse statusCode]);
    if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
    {
        // creates json object out of HTTPResponse
        NSError *error = nil;
        jsonData = [NSJSONSerialization
                    JSONObjectWithData:data
                    options:NSJSONReadingMutableContainers
                    error:&error];
        NSLog(@"Data ===>  %@", jsonData);
        //NSString *i_id = [jsonData objectForKey:@"item_description"];
        
        // persists the data retrieved
        //NSManagedObjectContext *context = [[JCDCoreData sharedInstance] defaultContext];
//        NSArray *matches = [context fetchObjectsWithEntityName:@"BrtrItem" sortedBy:nil withPredicate:[NSPredicate predicateWithFormat:@"i_id = %@", i_id]];
    }
    else
    {
        // FIXME
        NSLog(@"BrtrSwipeyView: Error in response code");
        return;
    }
}

- (void) fetchingDataFailed:(NSError *)error;
{
    //NSLog(@"BrtrSwipeyView: Error %@; %@", error, [error localizedDescription]);
    NSLog(@"BrtrSwipeyView: Error when trying to fetch cards");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end