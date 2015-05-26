
//
//  ChatConvo.h
//  Bartr
//
//  Created by Synthia Ling on 5/25/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//
#import <LayerKit/LayerKit.h>
#import "ATLConversationListViewController.h"
#import "ATLParticipantTableViewController.h"
#import "ATLConversationViewController.h"
#import "ChatUser.h"

@interface ConversationListViewController : ATLConversationListViewController <ATLParticipantTableViewControllerDelegate>
- (void)selectConversation:(LYRConversation *)conversation;
+ (NSSet *)participants;
@end
