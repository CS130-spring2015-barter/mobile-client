//
//  DataFetcher.m
//  Bartr
//
//  Created by Tung Nguyen on 5/17/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "DataFetcher.h"
#import "BrtrDataSource.h"

@implementation DataFetcher

- (void)fetchData: (NSString *)urlAsString error:(NSError **)error
{
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"FetchDataQueue";
    NSLog(@"%@", url);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        BrtrDataSource *sharedDataSource = [BrtrDataSource sharedInstance];
        
        if(error) {
            [self.delegate fetchingDataFailed:error];
        }
        else {
            [self.delegate didReceiveResponse:data response:response];
        }
        
        [sharedDataSource reapDataFetcher:self];
    }];
}
@end
