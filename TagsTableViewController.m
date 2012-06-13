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

#define SCROLL_OFFSET -40

@interface TagsTableViewController ()
@property (nonatomic, strong) UITextField *tagTextField;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSIndexPath *editingIndexPath;
@property (nonatomic, assign) BOOL isEditing;
@end

@implementation TagsTableViewController

@synthesize tags = _tags;
@synthesize tagTextField = _tagTextField;
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
    
    newTag.name = self.tagTextField.text;
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [self.tagTextField resignFirstResponder];

    self.isEditing = NO;
    
    [self showHUD:@"Creating Tag"];
    
    
    
    [noteStore createTag:newTag success:^(EDAMTag *tag) {
        
        [self.tableView setContentOffset:CGPointMake(0, SCROLL_OFFSET) animated:YES];

        [self.tags removeAllObjects];
        [self loadEvernoteTags];
        [self hideForm];
        

    } failure:^(NSError *error) {
        
    }];
}


-(void) setupAddTagForm{
    self.tagTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, SCROLL_OFFSET, 200, 30)];
    [self.tagTextField setAlpha:0];
    self.tagTextField.delegate = self;
    
    self.addButton= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.addButton.frame = CGRectMake(230, SCROLL_OFFSET, 80, 30); 
    [self.addButton setTitle:@"Add" forState:UIControlStateNormal];
    [self.addButton setAlpha:0];
    
    [self.addButton addTarget:self action:@selector(createTag:) forControlEvents:UIControlEventTouchUpInside];


    [self.tableView addSubview:self.tagTextField];
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
    self.tagTextField = nil;
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
    
    if ([self.tagTextField.text isEqualToString:@""])
        return NO;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
    
    [cell.textLabel setText:self.tagTextField.text];
    
    [cell.textLabel setHidden:NO];

    
    [self.tagTextField resignFirstResponder];

    
    EDAMTag* tag = [self.tags objectAtIndex:[self.editingIndexPath row]];
    
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    
    [tag setName:self.tagTextField.text];
     
    [noteStore updateTag:tag success:^(int32_t usn) {
        

    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" 
                                                         message:@"Error editing Tag" 
                                                        delegate:nil 
                                               cancelButtonTitle:@"OK" 
                                               otherButtonTitles:nil];
        [alert show];
    }];
    
    [self hideForm];
    [self undimCellLabels];

    
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
        NSLog(@"%@", error);
        [self hideHUD];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" 
                                                        message:@"Error Deleting Tag" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];

        [alert show];
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
        [self.tagTextField resignFirstResponder];
        self.isEditing = NO;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.editingIndexPath];
        [cell.textLabel setHidden:NO];
        [self undimCellLabels];
        return;
    }
    
    self.isEditing = YES;
    
    [self.tagTextField resignFirstResponder];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.editingIndexPath = indexPath;
    
    [self.tagTextField setText:cell.textLabel.text];
    [cell.textLabel setHidden:YES];

    [self showForm];
    
    [self.tagTextField setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20]];
    [self.tagTextField setFrame:CGRectMake(10, cell.frame.origin.y+10, cell.frame.size.width, cell.frame.size.height)];
    [self.tagTextField setReturnKeyType:UIReturnKeyDone];
    [self.tagTextField becomeFirstResponder];
    
    [UIView animateWithDuration:0.35 animations:^{
        [self.tableView setContentOffset:CGPointMake(0, cell.layer.position.y-30)];
    }];
    
    [self dimCellLabels];

}


- (void) dimCellLabels{
    [self setCellLabelsOpacity:0.4];
}

- (void) undimCellLabels{
    [self setCellLabelsOpacity:1];
}


- (void) setCellLabelsOpacity:(CGFloat) alpha{
    for (UITableViewCell *cell in self.tableView.visibleCells){
        [cell.textLabel setAlpha:alpha];
    }
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
    [self.tagTextField setText:@""];
    [UIView animateWithDuration:0.35 animations:^{
        [self.addButton setAlpha:0];
        [self.tagTextField setAlpha:0];
    }];
}

-(void) showForm{
    self.tagTextField.frame = CGRectMake(20, SCROLL_OFFSET, 200, 30);
    [UIView animateWithDuration:0.25 animations:^{
        [self.addButton setAlpha:1];
        [self.tagTextField setAlpha:1];
    }];
}


- (IBAction)didPressAdd:(id)sender {
    [self.tagTextField becomeFirstResponder];
    self.isEditing = YES;
    [UIView animateWithDuration:0.45 animations:^{
        //
        [self.tableView setContentOffset:CGPointMake(0, -60)];
     

    } completion:^(BOOL finished) {
        [self showForm];
    }];
    
}
@end
