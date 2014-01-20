//
//  TodoListViewController.m
//  TodoList
//
//  Created by Ankit Nitin Shah on 1/20/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "TodoListViewController.h"
#import "Todos.h"

#define MAX_TEXTVIEW_WIDTH 313
#define MAX_TEXTVIEW_HEIGHT 80
#define EXTRA_HEIGHT_PADDING 18

@interface TodoListViewController ()

@property (nonatomic, strong) Todos* todos;
@end

@implementation TodoListViewController

//called by storyboard
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        // Custom initialization
        self.todos = [[Todos alloc] init];
        [self.todos loadItems];
    }
    return self;
}

//enable edit and add buttons
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Enable Edit and Add button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddItem)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.todos.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TodoTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell with value from todo item.
    UITextView* textCell = (UITextView*)[cell viewWithTag:1];
    NSString* value = [self.todos.items objectAtIndex:indexPath.row];
    [textCell setText: value];
    
    //If cell has text with zero length, set focus.
    NSString* trimmedValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
    if(trimmedValue.length == 0){
        [textCell becomeFirstResponder];
    }
    
    [textCell setDelegate: self];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Max height width frame
    CGSize boundingSize = CGSizeMake(MAX_TEXTVIEW_WIDTH, MAX_TEXTVIEW_HEIGHT);
    //text size based on font and content
    CGRect textRect = [[self.todos.items objectAtIndex:indexPath.row]
                       boundingRectWithSize:boundingSize
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                       context:nil];
    //add some padding
    CGFloat requiredHeight = textRect.size.height + EXTRA_HEIGHT_PADDING;
    return requiredHeight;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.todos.items removeObjectAtIndex:indexPath.row];
        [self.todos saveItems];
        
        //if edited item is deleted, hide the keyboard
        if([self.tableView isEditing]){
            UITableViewCell *deletedTextCell = [tableView cellForRowAtIndexPath:indexPath];
            UITextView* deletedTextView= (UITextView*)[deletedTextCell viewWithTag:1];
            if([deletedTextView isFirstResponder]){
                [deletedTextView resignFirstResponder];
            }
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(fromIndexPath.row != toIndexPath.row){
        NSString *object = self.todos.items[fromIndexPath.row];
        [self.todos.items removeObjectAtIndex:fromIndexPath.row];
        [self.todos.items insertObject:object atIndex:toIndexPath.row];
        [self.todos saveItems];
    }
}

//Add new item
- (void) onAddItem{
    
    //check if table already contains empty todo item, if yes focus existing empty item else add new item
    int indexOfEmptyItem = [self.todos indexOfEmptyItem];
    
    if(indexOfEmptyItem != -1){
        //focus existing empty item
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfEmptyItem inSection:0]];
        [[cell viewWithTag:1] becomeFirstResponder];
    }else{
        //add new item
        [self.todos.items insertObject:@"" atIndex:0];
        NSIndexPath* zeroPositionIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[zeroPositionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}


//textfield delegate

//Handle return key
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return FALSE;
    }
    return TRUE;
}


- (void) textViewDidEndEditing:(UITextView *)textView{
    [self.todos saveItems];
    
    //FIX: Check if tableview editing in progress. Call to reload while editing could cause issue if items deleted/inserted.
    if(![self.tableView isEditing]){
        
        //reload the item, to update the textview size
        NSIndexPath* updatedItemIndex = [self.tableView indexPathForCell: (UITableViewCell*)textView.superview.superview.superview];
        [self.tableView reloadRowsAtIndexPaths:@[updatedItemIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

-(void) textViewDidChange:(UITextView *)textView{
    
    //update todo item content
    NSIndexPath* updatedItemIndex = [self.tableView indexPathForCell: (UITableViewCell*)textView.superview.superview.superview];
    [self.todos.items replaceObjectAtIndex:updatedItemIndex.row withObject:textView.text];
    
}



//tableview delegate methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    [[cell viewWithTag:1] becomeFirstResponder];
}

-(BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return FALSE;
}


@end
