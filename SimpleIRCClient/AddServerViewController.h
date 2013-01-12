//
//  SICAddServerSettingViewController.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/06.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddServerSettingViewControllerDelegate;

@interface AddServerViewController : UITableViewController<UITextFieldDelegate>
@property (weak, nonatomic) id <AddServerSettingViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonDone;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *host;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextField *nick;
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *pass;
@property (weak, nonatomic) IBOutlet UITextField *real;
@property (weak, nonatomic) IBOutlet UISwitch *useSSL;
@end

@protocol AddServerSettingViewControllerDelegate <NSObject>
- (void)addServerViewControllerDidCancel:(AddServerViewController *)controller;
- (void)addServerViewControllerDidFinish:(AddServerViewController *)controller
                                    name: (NSString *)inputName host:(NSString *)inputHost
                                    port:(NSUInteger) inputPort nick:(NSString *)nick pass:(NSString *)pass
                                    user:(NSString *)user real:(NSString *) real useSSL:(BOOL) inputUseSSL;
@end
