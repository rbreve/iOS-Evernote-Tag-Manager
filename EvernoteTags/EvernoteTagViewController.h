//
//  EvernoteTagViewController.h
//  EvernoteTags
//
//  Created by Roberto Breve on 6/11/12.
//  Copyright (c) 2012 Icoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EvernoteTagViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;
- (IBAction)pressAuthenticate:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *viewTagsButton;
- (IBAction)viewTags;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end
