//
//  ChatViewController.m
//  Bartr
//
//  Created by Synthia Ling on 5/21/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()
@property (nonatomic) LYRConversation *conversation;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendMessage:(NSString *)messageText{
    // If no conversations exist, create a new conversation object with two participants
    // For the purposes of this Quick Start project, the 3 participants in this conversation are 'Device'  (the authenticated user id), 'Simulator', and 'Dashboard'.
    if (!self.conversation) {
        NSError *error = nil;
        self.conversation = [self.layerClient newConversationWithParticipants:[NSSet setWithArray:@[ @"Simulator", @ "Dashboard" ]] options:nil error:&error];
        if (!self.conversation) {
            NSLog(@"New Conversation creation failed: %@", error);
        }
    }
    
    // Creates a message part with text/plain MIME Type
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    LYRMessage *message = [self.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:nil];
    
    // Sends the specified message
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message queued to be sent: %@", messageText);
    } else {
        NSLog(@"Message send failed: %@", error);
    }
}


@end

