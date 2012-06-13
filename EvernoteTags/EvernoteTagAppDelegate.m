//
//  EvernoteTagAppDelegate.m
//  EvernoteTags
//
//  Created by Roberto Breve on 6/11/12.
//  Copyright (c) 2012 Icoms. All rights reserved.
//

#import "EvernoteTagAppDelegate.h"
#import "EvernoteSession.h"

@implementation EvernoteTagAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    
    NSString *EVERNOTE_HOST = @"sandbox.evernote.com";
    NSString *CONSUMER_KEY = @"rbreve";
    NSString *CONSUMER_SECRET = @"a484d72fef851aba";
    
    EvernoteSession *session = [[EvernoteSession alloc] init];
    [session setHost:EVERNOTE_HOST];
    [session setConsumerKey:CONSUMER_KEY];
    [session setConsumerSecret:CONSUMER_SECRET];
    
    [EvernoteSession setSharedSession:session];

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // delegate to the Evernote session singleton
    if ([[EvernoteSession sharedSession] handleOpenURL:url]) {
        return YES;
    } 
    return NO;
}

@end
