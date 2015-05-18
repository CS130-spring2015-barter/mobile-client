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

@interface BrtrSwipeyViewController () <DataFetchDelegate>

@end

@implementation BrtrSwipeyViewController
@synthesize user;
-(void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
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

    return [BrtrDataSource getCardStackForUser:user];
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
    NSLog(@"BrtrSwipeyView: Received a HTTPResponse");
    //NSLog(@"BrtrSwipeyView: Response code: %ld", (long)[response ]);
    
//    if ([response statusCode] >= 200 && [response statusCode] < 300)
//    {
//        NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
//        NSLog(@"Response ==> %@", responseData);
//        
//        NSError *error = nil;
//        jsonData = [NSJSONSerialization
//                    JSONObjectWithData:urlData
//                    options:NSJSONReadingMutableContainers
//                    error:&error];
//    }
//    else if (nil != error) {
//        NSString *error_msg = (NSString *) jsonData[@"message"];
//        [[BrtrDataSource sharedInstance] alertStatus:error_msg :@"Sign in Failed!" :0];
//    }
//    
//    else {
//        //if (error) NSLog(@"Error: %@", error);
//        [[BrtrDataSource sharedInstance]  alertStatus:@"Connection Failed" :@"Sign in Failed!" :0];
//    }
}

- (void) fetchingDataFailed:(NSError *)error;
{
    NSLog(@"BrtrSwipeyView: Error %@; %@", error, [error localizedDescription]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end