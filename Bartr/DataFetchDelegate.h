//
//  DataFetchDelegate.h
//  Bartr
//
//  Created by Tung Nguyen on 5/17/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

@protocol DataFetchDelegate
- (void) didReceiveData:(id) data response:(NSURLResponse *)response;
- (void) fetchingDataFailed:(NSError *)error;
@end
