//
//  EvernoteTagViewController.m
//  EvernoteTags
//
//  Created by Roberto Breve on 6/11/12.
//  Copyright (c) 2012 Icoms. All rights reserved.
//

#import "EvernoteTagViewController.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"

@interface EvernoteTagViewController ()

@end

@implementation EvernoteTagViewController
@synthesize usernameLabel;
@synthesize viewTagsButton;
@synthesize authenticateButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.usernameLabel setText:@"Authenticating..."];
    
    [self checkAuthentication];
}



- (void)viewDidUnload
{
    [self setAuthenticateButton:nil];
    [self setViewTagsButton:nil];
    [self setUsernameLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


-(void) updateUsername{
    EvernoteUserStore *userStore=[EvernoteUserStore userStore];
    [userStore getUserWithSuccess:^(EDAMUser *user) {
        [self.usernameLabel setText:[user username]];
        
    } failure:^(NSError *error) {
        
        [self.usernameLabel setText:@"Not logged in"];
        [self.viewTagsButton setHidden:YES];
        [self.authenticateButton setHidden:NO];

    }];
}

-(void)checkAuthentication{
    NSLog(@"");
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (session.isAuthenticated){
        [self.viewTagsButton setHidden:NO];
        [self.authenticateButton setHidden:YES];
        [self updateUsername];
    }else{
        [self.viewTagsButton setHidden:YES];
        [self.usernameLabel setText:@"Please Login."];
    }
    
}

- (IBAction)pressAuthenticate:(id)sender {
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithCompletionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                             message:@"Could not authenticate" 
                                                            delegate:nil 
                                                   cancelButtonTitle:@"OK" 
                                                   otherButtonTitles:nil];
            [alert show];
        } else {
            [self.authenticateButton setHidden:YES];
            [self.viewTagsButton setHidden:NO];
            [self updateUsername];
            

        } 
    }];
}

- (IBAction)viewTags {
    
}
@end
