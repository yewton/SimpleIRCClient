//
//  SICServer.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICServer.h"
#import "SICChannelDataController.h"

@implementation SICServer
@synthesize name = _name, host = _host, port = _port, useSSL = _useSSL, channelDataController = _channelDataController, nick =_nick, pass = _pass, user = _user, real = _real;

-(id)initWithName:(NSString *)name host:(NSString *)host port:(NSUInteger)port nick:(NSString *)nick pass:(NSString *)pass user:(NSString *) user real:(NSString *)real useSSL:(BOOL)useSSL
{
    self = [super init];
    if (self) {
        _name = name;
        _nick = nick;
        _host = host;
        _port = port;
        _user = user;
        _real = real;
        _pass = pass;
        _useSSL = useSSL;
        _channelDataController = [[SICChannelDataController alloc] init];
        return self;
    }
    return nil;
}

-(NSArray *)getChannels
{
    return self.channelDataController.channelList;
}

- (void)addChannelWithName:(NSString *) name
{
    [self.channelDataController addChannelWithName:name];
}

@end
