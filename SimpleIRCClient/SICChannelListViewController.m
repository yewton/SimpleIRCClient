//
//  SICChannelListViewController.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICChannelListViewController.h"
#import "SICChannelDataController.h"
#import "SICChannel.h"
#import "SICClient.h"
#import "SICLogViewController.h"
#import "SICServerDataController.h"
#import "SICServerListViewController.h"

@interface SICChannelListViewController () <ChannelDataControllerDelegate>
@end

@implementation SICChannelListViewController
@synthesize dataController = _dataController, parent = _parent, serverIndex = _serverIndex;

- (void)setDataController:(SICChannelDataController *)dataController
{
    _dataController = dataController;
    _dataController.delegate = self;
}

- (void)afterAddingChannel:(SICChannel *)ch
{
    [[self.parent dataController] saveSetting];
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataController countOfList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ChannelCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    SICChannel *channelAtIndex = [self.dataController objectInListAtIndex:indexPath.row];
    [[cell textLabel] setText:channelAtIndex.name];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return indexPath.row != 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        SICChannel *channel = [self.dataController objectInListAtIndex:indexPath.row];
        [self.client partChannelWithName:channel.name];
        [self.parent.dataController removeChannelAtIndex:indexPath.row serverIndex:self.serverIndex];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSUInteger index = [self.tableView indexPathForSelectedRow].row;

    SICLogViewController *vc = (SICLogViewController *)[segue destinationViewController];
    vc.channel = [self.dataController objectInListAtIndex:index];
    vc.client = self.client;
    vc.server = self.server;
}

- (IBAction)addChannel:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"add channel"
                          message: @"Input a channel name."
                          delegate: self
                          cancelButtonTitle: @"Cancel"
                          otherButtonTitles: @"Add", nil];
    UITextField *textField = [[UITextField alloc]
                              initWithFrame:CGRectMake(12.0, 50.0, 260, 25.0)];
    
    textField.placeholder = @"#channel_name";
    [textField setBackgroundColor:[UIColor whiteColor]];
    [alert addSubview:textField];
    [alert show];
    [textField becomeFirstResponder];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return; // cancel
    }
    UITextField *textField = (UITextField *)[[alertView subviews] lastObject];
    [self.client joinChannelWithName:textField.text];
    NSLog(@"%@", textField.text);
}

@end
