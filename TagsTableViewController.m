//
//  TagsTableViewController.m
//  EvernoteTags
//
//  Created by Roberto Breve on 6/11/12.
//  Copyright (c) 2012 Icoms. All rights reserved.
//

#import "TagsTableViewController.h"
#import "EvernoteSDK.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>


@interface TagsTableViewController ()
@property (nonatomic, strong) UITextField *addTagField;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, assign) BOOL isEditing;
@end

@implementation TagsTableViewController

@synthesize tags = _tags;
@synthesize addTagField = _addTagField;
@synthesize addButton = _addButton, editingIndexPath = _editingIndexPath, isEditing = _isEditing;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) orderTags{
    [self.tags sortUsingComparator: ^(EDAMTag *obj1, EDAMTag *obj2) {
        NSString *tagName1  = obj1.name;
        NSString *tagName2  = obj2.name;
        return [tagName1 caseInsensitiveCompare:tagName2];
    }];
        
}

-(void) loadEvernoteTags{
    self.tags = [[NSMutableArray alloc] init];
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    [noteStore listTagsWithSuccess:^(NSArray *tags) {
        for (EDAMTag *tag in tags) {
            [self.tags addObject:tag];
        }
        [self orderTags];
        [self.tableView reloadData];
        [self hideHUD];

    } failure:^(NSError *error) {
        NSLog(@"failed %@", error);
    }];
}



-(void) createTag:(id)sender{
    EDAMTag *newTag = [[EDAMTag alloc] init];
    
    newTag.name = self.addTagField.text;
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [self.addTagField resignFirstResponder];

    self.isEditing = NO;
    
    [self showHUD:@"Creating Tag"];
    
    
    
    [noteStore createTag:newTag success:^(EDAMTag *tag) {
        
        [self.tableView setContentOffset:CGPointMake(0, -40) animated:YES];

        [self.tags removeAllObjects];
        [self loadEvernoteTags];
        [self hideForm];
        

    } failure:^(NSError *error) {
        
    }];
}


-(void) setupAddTagForm{
    self.addTagField = [[UITextField alloc] initWithFrame:CGRectMake(20, -40, 200, 30)];
    [self.addTagField setAlpha:0];
    self.addTagField.delegate = self;
    
    self.addButton= [[UIButton alloc] initWithFrame:CGRectMake(230, -40, 80, 30)];
    
    [self.addButton setBackgroundColor:[UIColor grayColor]];
    [self.addButton setTitle:@"Add" forState:UIControlStateNormal];
    [self.addButton setAlpha:0];
    
    [self.addButton addTarget:self action:@selector(createTag:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addTagField setBorderStyle:UITextBorderStyleLine];
    
    [self.tableView addSubview:self.addTagField];
    [self.tableView addSubview:self.addButton];
}

-(void) loadView{
    [super loadView];
    
  

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showHUD:@"Loading Tags"];
    [self loadEvernoteTags];
    
    [self setupAddTagForm];
     
  
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.addTagField = nil;
    self.addButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    if ([self.addTagField.text isEqualToString:@""])
        return NO;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    
    [cell.textLabel setText:self.addTagField.text];
    
    [cell.textLabel setHidden:NO];

    
    [self.addTagField resignFirstResponder];

    
    EDAMTag* tag = [self.tags objectAtIndex:[self.editingIndexPath row]];
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    [tag setName:self.addTagField.text];
     
    [noteStore updateTag:tag success:^(int32_t usn) {
        //do nothing
    } failure:^(NSError *error) {
        //couldnt edit tag alert box
        NSLog(@"%@", error);
    }];
    
    [self hideForm];

    
    return YES;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EDAMTag* tag = [self.tags objectAtIndex:[indexPath row]];
    
    [cell.textLabel setText:[tag name]];
    
    cell.tag = [[tag guid] intValue];
    
    return cell;
}

 

-(void) deleteTagFromServer:(EDAMTag *) tag forRowAtIndexPath:(NSIndexPath *) indexPath {
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    [self showHUD:@"Deleting Tag"];

    
    [noteStore expungeTagWithGuid:[tag guid] success:^(int32_t usn) {
        [self.tags removeObject:tag];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self hideHUD];
    } failure:^(NSError *error) {
        NSLog(@"Error deleting tag %@", error);
    }];
}
 
  
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EDAMTag *tag = [self.tags objectAtIndex:[indexPath row]];
        [self deleteTagFromServer:tag forRowAtIndexPath:indexPath];
    }   
      
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if (self.isEditing) {
        [self hideForm];
        [self.addTagField resignFirstResponder];
        self.isEditing = NO;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
        [cell.textLabel setHidden:NO];
        
        return;
    }
    
    self.isEditing = YES;
    
    [self.addTagField resignFirstResponder];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.editingIndexPath = indexPath;
    
    [self.addTagField setText:cell.textLabel.text];
    [cell.textLabel setHidden:YES];

    [self showForm];
    
    [self.addTagField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20]];
    [self.addTagField setFrame:CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
    [self.addTagField setReturnKeyType:UIReturnKeyDone];
    [self.addTagField becomeFirstResponder];
    
    [UIView animateWithDuration:0.35 animations:^{
        [self.tableView setContentOffset:CGPointMake(0, cell.layer.position.y-30)];
    }];

}



-(void) hideHUD{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) showHUD:(NSString*) text{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = text;
}


-(void) hideForm{
    [self.addTagField setText:@""];
    [UIView animateWithDuration:0.35 animations:^{
        [self.addButton setAlpha:0];
        [self.addTagField setAlpha:0];
    }];
}

-(void) showForm{
    self.addTagField.frame = CGRectMake(20, -40, 200, 30);
    [UIView animateWithDuration:0.25 animations:^{
        [self.addButton setAlpha:1];
        [self.addTagField setAlpha:1];
    }];
}


- (IBAction)addTag:(id)sender {
    [self.addTagField becomeFirstResponder];
    self.isEditing = YES;
    [UIView animateWithDuration:0.45 animations:^{
        //
        [self.tableView setContentOffset:CGPointMake(0, -60)];
     

    } completion:^(BOOL finished) {
        [self showForm];
    }];
    
}
@end
