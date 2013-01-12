//
//  SICLogViewController.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2013/01/05.
//  Copyright (c) 2013年 yewton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SICChannel;
@class SICClient;
@class SICServer;

@interface SICLogViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong)SICChannel *channel;
@property (nonatomic, weak) SICClient *client;
@property (nonatomic, weak) SICServer *server;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *privmsgButton;
@property (weak, nonatomic) IBOutlet UIButton *noticeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleConnectionButton;
- (IBAction)sendPrivMsg:(id)sender;
- (IBAction)sendNotice:(id)sender;
- (IBAction)toggleConnection:(id)sender;

@end
