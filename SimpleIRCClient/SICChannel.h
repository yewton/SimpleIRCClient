//
//  SICChannel.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SICLog;

@protocol SICChannelDelegate;

@interface SICChannel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *mode;
@property (nonatomic, assign) BOOL special;
@property (nonatomic, copy) NSMutableArray *log;
@property (nonatomic, weak) id <SICChannelDelegate> delegate;

-(id) initWithName:(NSString *)name password:(NSString *)password mode:(NSString *)mode;
-(void) addLog:(SICLog *)message;
@end
