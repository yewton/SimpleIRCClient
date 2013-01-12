//
//  SICViewController.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/01.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SICServerDataController;

@interface SICServerListViewController : UITableViewController
@property (strong, nonatomic) SICServerDataController *dataController;
@end
