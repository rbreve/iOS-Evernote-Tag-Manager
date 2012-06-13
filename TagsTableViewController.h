//
//  TagsTableViewController.h
//  EvernoteTags
//
//  Created by Roberto Breve on 6/11/12.
//  Copyright (c) 2012 Icoms. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagsTableViewController : UITableViewController <UITextFieldDelegate>

- (IBAction)didPressAdd:(id)sender;

@property (nonatomic, strong) NSMutableArray *tags;
@end
