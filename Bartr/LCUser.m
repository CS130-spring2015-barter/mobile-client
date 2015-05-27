//
//  LCUser.m
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "LCUser.h"

@implementation LCUser

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
