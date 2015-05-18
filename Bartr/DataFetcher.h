//
//  DataFetcher.h
//  Bartr
//
//  Created by Tung Nguyen on 5/17/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataFetchDelegate.h"

@interface DataFetcher : NSObject
@property (weak, nonatomic) id<DataFetchDelegate> delegate;
- (void)fetchData: (NSString *)urlAsString error:(NSError **)error;
@end
