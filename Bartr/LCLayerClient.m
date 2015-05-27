//
//  LCLayerClient.m
//  LayerChatExample
//
//  Created by Pulkit Goyal on 05/04/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "LCLayerClient.h"

@implementation LCLayerClient

#pragma mark - Authentication
- (void)authenticateWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError *error))completion {
    // Check to see if the layerClient is already authenticated.
    if (self.authenticatedUserID) {
        // If the layerClient is authenticated with the requested userID, complete the authentication process.
        if ([self.authenticatedUserID isEqualToString:userID]) {
            NSLog(@"Layer Authenticated as User %@", self.authenticatedUserID);
            if (completion) completion(YES, nil);
            return;
        } else {
            //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
            [self deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                if (!error) {
                    [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
                        if (completion) {
                            completion(success, error);
                        }
                    }];
                } else {
                    if (completion) {
                        completion(NO, error);
                    }
                }
            }];
        }
    } else {
        // If the layerClient isn't already authenticated, then authenticate.
        [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
            if (completion) {
                completion(success, error);
            }
        }];
    }
}

- (void)authenticationTokenWithUserId:(NSString *)userID completion:(void (^)(BOOL success, NSError *error))completion {

    // Request an authentication Nonce from Layer
    [self requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (!nonce) {
            if (completion) {
                completion(NO, error);
            }
            return;
        }

        // Acquire identity Token from Layer Identity Service
        [self requestIdentityTokenForUserID:userID appID:[self.appID UUIDString] nonce:nonce completion:^(NSString *identityToken, NSError *error) {
            if (!identityToken) {
                if (completion) {
                    completion(NO, error);
                }
                return;
            }

            // Submit identity token to Layer for validation
            [self authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                if (authenticatedUserID) {
                    if (completion) {
                        completion(YES, nil);
                    }
                    NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
                } else {
                    completion(NO, error);
                }
            }];
        }];
    }];
}

/**
* TODO Update this function to obtain authentication token from your backend.
* Requirements on the backend: https://developer.layer.com/docs/guides/ios#authentication
*/
- (void)requestIdentityTokenForUserID:(NSString *)userID appID:(NSString *)appID nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion {
    NSParameterAssert(userID);
    NSParameterAssert(appID);
    NSParameterAssert(nonce);
    NSParameterAssert(completion);

    NSURL *identityTokenURL = [NSURL URLWithString:@"https://layer-identity-provider.herokuapp.com/identity_tokens"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSDictionary *parameters = @{@"app_id" : appID, @"user_id" : userID, @"nonce" : nonce};
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }

        // Deserialize the response
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![responseObject valueForKey:@"error"]) {
            NSString *identityToken = responseObject[@"identity_token"];
            completion(identityToken, nil);
        }
        else {
            NSString *domain = @"layer-identity-provider.herokuapp.com";
            NSInteger code = [responseObject[@"status"] integerValue];
            NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey : @"Layer Identity Provider Returned an Error.",
                    NSLocalizedRecoverySuggestionErrorKey : @"There may be a problem with your APPID."
            };

            NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
            completion(nil, error);
        }

    }] resume];
}

#pragma mark - Utilities
- (NSUInteger)countOfUnreadMessages {
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    LYRPredicate *unreadPred = [LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    LYRPredicate *userPred = [LYRPredicate predicateWithProperty:@"sentByUserID" operator:LYRPredicateOperatorIsNotEqualTo value:self.authenticatedUserID];
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPred, userPred]];
    return [self countForQuery:query error:nil];
}

- (NSUInteger)countOfMessages {
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    return [self countForQuery:query error:nil];
}

- (NSUInteger)countOfConversations {
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    return [self countForQuery:query error:nil];
}

- (LYRMessage *)messageForIdentifier:(NSURL *)identifier {
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)existingConversationForIdentifier:(NSURL *)identifier {
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    return [self executeQuery:query error:nil].firstObject;
}

- (LYRConversation *)existingConversationForParticipants:(NSSet *)participants {
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:participants];
    query.limit = 1;
    return [self executeQuery:query error:nil].firstObject;
}

@end
