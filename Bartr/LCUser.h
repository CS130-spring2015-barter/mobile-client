//
//  LCUser.h
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLParticipant.h"

@interface LCUser : NSObject <ATLParticipant, ATLAvatarItem>

@property(nonatomic, readonly) NSString *firstName;
@property(nonatomic, readonly) NSString *lastName;
@property(nonatomic, readonly) NSString *fullName;
@property(nonatomic, readonly) NSString *participantIdentifier;
@property(nonatomic, readonly) UIImage *avatarImage;
@property(nonatomic, readonly) NSString *avatarInitials;

- (instancetype)initWithParticipantIdentifier:(NSString *)participantIdentifier;

+ (instancetype)userWithParticipantIdentifier:(NSString *)participantIdentifier;


@end
