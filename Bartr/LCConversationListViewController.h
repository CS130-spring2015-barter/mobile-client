//
//  LCConversationListViewController.h
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "ATLConversationListViewController.h"
#import "ATLConversationViewController.h"

@protocol ATLParticipantTableViewControllerDelegate;

@interface LCConversationListViewController : ATLConversationListViewController <ATLParticipantTableViewControllerDelegate>
- (void)selectConversation:(LYRConversation *)conversation;
@property (nonatomic, strong) NSSet *participants;
@end
