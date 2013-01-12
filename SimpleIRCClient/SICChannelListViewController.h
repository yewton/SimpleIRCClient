//
//  SICChannelListViewController.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SICChannelDataController;
@class SICClient;
@class SICServerListViewController;
@class SICServer;

@interface SICChannelListViewController : UITableViewController<UIAlertViewDelegate>
- (IBAction)addChannel:(id)sender;
@property (strong, nonatomic) SICChannelDataController *dataController;
@property (strong, nonatomic) SICClient *client;
@property (strong, nonatomic) SICServer *server;
@property (assign, nonatomic) NSUInteger serverIndex;
@property (weak, nonatomic) SICServerListViewController *parent;
@end
