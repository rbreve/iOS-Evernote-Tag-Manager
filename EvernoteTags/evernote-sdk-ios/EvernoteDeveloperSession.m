//
//  EvernoteDeveloperSession.m
//  evernote-sdk-ios
//
//  Created by Matthew McGlincy on 5/8/12.
//  Copyright (c) 2012 n/a. All rights reserved.
//

#import "ENAPI.h"
#import "EvernoteDeveloperSession.h"

@implementation EvernoteDeveloperSession

@synthesize developerToken = _developerToken;

- (void)dealloc
{
    [_developerToken release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)authenticateWithCompletionHandler:(EvernoteAuthCompletionHandler)completionHandler
{
    // authenticate is idempotent; check if we're already authenticated
    if (self.isAuthenticated) {
        completionHandler(nil);
        return;
    }
    
    // TODO: verify host and developer token?
    if (!self.host || !self.developerToken) {
        [NSException raise:@"Invalid EvernoteDeveloperSession" 
                    format:@"Please use a valid host and developer token."];
    }
    
    self.completionHandler = completionHandler;    
    [self authenticateWithDeveloperToken];
}

- (void)authenticateWithDeveloperToken
{
    @try {
        // contact UserStore for our edamUserId and noteStoreUrl
        EDAMUserStoreClient *userStore = [self userStore];
        EDAMUser *user = [userStore getUser:self.developerToken];
        NSString *noteStoreUrl = [userStore getNoteStoreUrl:self.developerToken];
        // TODO: userID is an int32, but we're currently persisting it as an NSString
        NSString *edamUserId = [NSString stringWithFormat:@"%d", user.id];
        // save credentials into the keychain. 
        // Our developer session is now "authenticated".
        [self saveCredentialsWithEdamUserId:edamUserId
                               noteStoreUrl:noteStoreUrl
                        authenticationToken:self.developerToken];
        self.completionHandler(nil);
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@", exception);
        NSError *error = [ENAPI errorFromNSException:exception];
        self.completionHandler(error);
    }
}

@end
