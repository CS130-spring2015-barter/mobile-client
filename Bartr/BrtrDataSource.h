//
//  BrtrDataSource.h
//  Bartr
//
//  Created by admin on 4/25/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrtrUser.h"

@interface BrtrDataSource : NSObject

+(BrtrUser *) getUserForEmail:(NSString *)email;
+ (void) saveAllData;
+ (void) loadFakeData;
@end
