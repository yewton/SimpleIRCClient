//
//  SICViewController.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/01.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICServerListViewController.h"
#import "AddServerViewController.h"
#import "SICServerDataController.h"
#import "SICChannelListViewController.h"
#import "SICServer.h"
#import "SICClient.h"

@interface SICServerListViewController () <AddServerSettingViewControllerDelegate>
@end

@implementation SICServerListViewController
@synthesize dataController = _dataController;

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addServerViewControllerDidCancel:(AddServerViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addServerViewControllerDidFinish:(AddServerViewController *)controller
                                    name:(NSString *)inputName host:(NSString *)inputHost
                                    port:(NSUInteger)inputPort nick:(NSString *)nick
                                    pass:(NSString *)pass user:(NSString *)user
                                    real:(NSString *)real useSSL:(BOOL)inputUseSSL
{
    [self.dataController addServerWithName:inputName host:inputHost
                                      port:inputPort nick:nick pass:pass
                                      user:user real:real useSSL:inputUseSSL];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataController countOfList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ServerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SICServer *serverAtIndex = [self.dataController objectInListAtIndex:indexPath.row];
    [[cell textLabel] setText:serverAtIndex.name];
    NSString *serverConfig = [NSString stringWithFormat:@"%@:%d", serverAtIndex.host, serverAtIndex.port];
    [[cell detailTextLabel] setText: serverConfig];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [self.dataController removeObjectFromServerListAtIndex:indexPath.row];
            [self.dataController saveSetting];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowAddServerView"]) {
        AddServerViewController *addController = (AddServerViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0];
        addController.delegate = self;
    } else if([[segue identifier] isEqualToString:@"ShowChannelListView"]) {
        NSUInteger index = [self.tableView indexPathForSelectedRow].row;
        SICServer *server = [self.dataController objectInListAtIndex:index];
        SICClient *client = [[SICClient alloc] initWithServer:server];
        [client connect];
        SICChannelListViewController *channelListController = (SICChannelListViewController *)[segue destinationViewController];
        channelListController.dataController = server.channelDataController;
        channelListController.client = client;
        channelListController.parent = self;
        channelListController.serverIndex = index;
        channelListController.server = server;
    }
}

@end
