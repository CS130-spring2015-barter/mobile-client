//
//  ChatUser.m
//  Bartr
//
//  Created by Synthia Ling on 5/24/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatUser.h"
@implementation ChatUser

- (instancetype)initWithParticipantIdentifier:(NSString *)participantIdentifier {
    self = [super init];
    if (self) {
        _participantIdentifier = participantIdentifier;
        _firstName = participantIdentifier;
        _lastName = participantIdentifier;
        _fullName = participantIdentifier;
        _avatarInitials = [participantIdentifier substringToIndex:1];
    }
    
    return self;
}

+ (instancetype)userWithParticipantIdentifier:(NSString *)participantIdentifier {
    return [[self alloc] initWithParticipantIdentifier:participantIdentifier];
}

@end
