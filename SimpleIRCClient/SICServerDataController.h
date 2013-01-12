//
//  SICServerDataController.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SICServer;

@interface SICServerDataController : NSObject <NSCoding>
@property (nonatomic, copy) NSMutableArray *serverList;
- (NSUInteger)countOfList;
- (SICServer *)objectInListAtIndex:(NSUInteger)theIndex;
- (SICServer *)addServerWithName:(NSString *)inputName host:(NSString *)inputHost
                     port:(NSUInteger) inputPort nick:(NSString *)inputNick pass:(NSString *)inputPass
                     user:(NSString *) user real:(NSString *) real useSSL:(BOOL) inputUseSSL;
- (void)removeObjectFromServerListAtIndex:(NSUInteger)index;
- (void)saveSetting;
- (void)removeChannelAtIndex:(NSUInteger)index serverIndex:(NSUInteger) serverIndex;
@end
