//
//  SICServer.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SICChannelDataController;

@interface SICServer : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *pass;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, strong) SICChannelDataController *channelDataController;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *real;

-(id)initWithName:(NSString *)name host:(NSString *)host port:(NSUInteger)port nick:(NSString *)nick pass:(NSString *)pass user: (NSString *)user real: (NSString *) real useSSL:(BOOL)useSSL;

-(NSArray *)getChannels;
@end
