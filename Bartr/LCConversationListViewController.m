//
//  LCConversationListViewController.m
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Atlas/Controllers/ATLParticipantTableViewController.h>
#import "LCConversationListViewController.h"
#import "LCUser.h"
#import "LCConversationViewController.h"

@implementation LCConversationListViewController
- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Conversation List Data Source

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation {
    NSMutableSet *participantIdentifiers = [conversation.participants mutableCopy];
    [participantIdentifiers minusSet:[NSSet setWithObject:self.layerClient.authenticatedUserID]];

    if (participantIdentifiers.count == 0) return @"Personal Conversation";
    NSMutableSet *participants = [[self participantsForIdentifiers:participantIdentifiers] mutableCopy];
    if (participants.count == 0) return @"No Matching Participants";
    if (participants.count == 1) return [[participants allObjects][0] fullName];

    NSMutableArray *firstNames = [NSMutableArray new];
    [participants enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id <ATLParticipant> participant = obj;
        if (participant.firstName) {
            // Put the last message sender's name first
            if ([conversation.lastMessage.sentByUserID isEqualToString:participant.participantIdentifier]) {
                [firstNames insertObject:participant.firstName atIndex:0];
            } else {
                [firstNames addObject:participant.firstName];
            }
        }
    }];
    NSString *firstNamesString = [firstNames componentsJoinedByString:@", "];
    return firstNamesString;
}

#pragma mark - Conversation List Delegate

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation {
    [self presentConversationControllerForConversation:conversation];
}

#pragma mark - Participant Delegate

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id <ATLParticipant>)participant {
    [self.navigationController popViewControllerAnimated:NO];

    // Create a new conversation
    NSError *error = nil;
    LYRConversation *conversation = [self.layerClient newConversationWithParticipants:[NSSet setWithArray:@[self.layerClient.authenticatedUserID, participant.participantIdentifier]] options:nil error:&error];
    if (!conversation) {
        NSLog(@"New Conversation creation failed: %@", error);
    } else {
        [self presentConversationControllerForConversation:conversation];
    }
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion {
}

#pragma mark - Helpers

- (void)presentConversationControllerForConversation:(LYRConversation *)conversation {
    ATLConversationViewController *conversationViewController = [LCConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    conversationViewController.conversation = conversation;
    [self.navigationController pushViewController:conversationViewController animated:YES];
}

- (NSSet *)participantsForIdentifiers:(NSSet *)identifiers {
    NSMutableSet *participants = [[NSMutableSet alloc] initWithCapacity:identifiers.count];
    for (NSString *identifier in identifiers) {
        [participants addObject:[LCUser userWithParticipantIdentifier:identifier]];
    }
    return participants;
}

#pragma mark - Conversation Selection From Push Notification

- (void)selectConversation:(LYRConversation *)conversation {
    if (conversation) {
        [self presentConversationControllerForConversation:conversation];
    }
}

@end
