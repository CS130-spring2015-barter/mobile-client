//
//  LCConversationViewController.h
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "ATLConversationViewController.h"

@interface LCConversationViewController : ATLConversationViewController <ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate>
-(void)sendMessage:(NSString *)messageText toReceiver:(NSString *) rec_id;
@property (strong, nonatomic) NSString *u_id;
@end
