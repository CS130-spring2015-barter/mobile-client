//
//  ChatUser.h
//  Bartr
//
//  Created by Synthia Ling on 5/24/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ATLParticipant.h"
#import "ATLAvatarItem.h"

@interface ChatUser : NSObject <ATLParticipant, ATLAvatarItem>

@property(nonatomic, readonly) NSString *firstName;
@property(nonatomic, readonly) NSString *lastName;
@property(nonatomic, readonly) NSString *fullName;
@property(nonatomic, readonly) NSString *participantIdentifier;
@property(nonatomic, readonly) UIImage *avatarImage;
@property(nonatomic, readonly) NSString *avatarInitials;

- (instancetype)initWithParticipantIdentifier:(NSString *)participantIdentifier;

+ (instancetype)userWithParticipantIdentifier:(NSString *)participantIdentifier;


@end
