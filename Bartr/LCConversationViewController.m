//
//  LCConversationViewController.m
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Atlas/Utilities/ATLMessagingUtilities.h>
#import "LCConversationViewController.h"
#import "LCUser.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
#import "LCImageViewController.h"

@implementation LCConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - Conversation Data Source

- (id <ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier {
    // TODO Return the user corresponding to this participant identifier
    return [LCUser userWithParticipantIdentifier:participantIdentifier];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date {
    return [[NSAttributedString alloc] initWithString:[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus {
    NSMutableDictionary *mutableRecipientStatus = [recipientStatus mutableCopy];
    if ([mutableRecipientStatus valueForKey:self.layerClient.authenticatedUserID]) {
        [mutableRecipientStatus removeObjectForKey:self.layerClient.authenticatedUserID];
    }

    NSString *statusString = [NSString new];
    if (mutableRecipientStatus.count > 1) {
        __block NSUInteger readCount = 0;
        __block BOOL delivered;
        __block BOOL sent;
        [mutableRecipientStatus enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSNumber *statusNumber, BOOL *stop) {
            LYRRecipientStatus status = (LYRRecipientStatus) statusNumber.integerValue;
            switch (status) {
                case LYRRecipientStatusInvalid:
                    break;
                case LYRRecipientStatusSent:
                    sent = YES;
                    break;
                case LYRRecipientStatusDelivered:
                    delivered = YES;
                    break;
                case LYRRecipientStatusRead:
                    NSLog(@"Read");
                    readCount += 1;
                    break;
            }
        }];
        if (readCount) {
            NSString *participantString = readCount > 1 ? @"Participants" : @"Participant";
            statusString = [NSString stringWithFormat:@"Read by %lu %@", (unsigned long) readCount, participantString];
        } else if (delivered) {
            statusString = @"Delivered";
        } else if (sent) {
            statusString = @"Sent";
        }
    } else {
        __block NSString *blockStatusString = [NSString new];
        [mutableRecipientStatus enumerateKeysAndObjectsUsingBlock:^(NSString *userID, NSNumber *statusNumber, BOOL *stop) {
            if ([userID isEqualToString:self.layerClient.authenticatedUserID]) return;
            LYRRecipientStatus status = (LYRRecipientStatus) statusNumber.integerValue;
            switch (status) {
                case LYRRecipientStatusInvalid:
                    blockStatusString = @"Not Sent";
                case LYRRecipientStatusSent:
                    blockStatusString = @"Sent";
                case LYRRecipientStatusDelivered:
                    blockStatusString = @"Delivered";
                    break;
                case LYRRecipientStatusRead:
                    blockStatusString = @"Read";
                    break;
            }
        }];
        statusString = blockStatusString;
    }
    return [[NSAttributedString alloc] initWithString:statusString attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:11]}];

}

#pragma mark - Conversation Delegate

- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectMessage:(LYRMessage *)message {
    LYRMessagePart *JPEGMessagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEG);
    if (JPEGMessagePart) {
        [self presentImageViewControllerWithMessage:message];
        return;
    }
    LYRMessagePart *PNGMessagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImagePNG);
    if (PNGMessagePart) {
        [self presentImageViewControllerWithMessage:message];
    }
}

#pragma mark - Helpers

- (void)presentImageViewControllerWithMessage:(LYRMessage *)message {
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = [self loadLowResImageForMessage:message];

    // Setup view controller
    JTSImageViewController *imageViewer = [[LCImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled message:message];

    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOffscreen];
}

- (UIImage *)loadLowResImageForMessage:(LYRMessage *)message {
    LYRMessagePart *lowResImagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEGPreview);
    LYRMessagePart *imageInfoPart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageSize);

    if (!lowResImagePart) {
        // Default back to image/jpeg MIMEType
        lowResImagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEG);
    }

    // Retrieve low-res image from message part
    if (!(lowResImagePart.transferStatus == LYRContentTransferReadyForDownload || lowResImagePart.transferStatus == LYRContentTransferDownloading)) {
        if (lowResImagePart.fileURL) {
            return [UIImage imageWithContentsOfFile:lowResImagePart.fileURL.path];
        } else {
            return [UIImage imageWithData:lowResImagePart.data];
        }
    }
    return nil;
}

@end
