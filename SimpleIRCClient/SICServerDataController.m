//
//  SICServerDataController.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICServerDataController.h"
#import "SICChannelDataController.h"
#import "SICServer.h"
#import "SICChannel.h"

@interface SICServerDataController ()
- (void)initializeDefaultDataList;
@end

@implementation SICServerDataController
@synthesize serverList = _serverList;

- (void)initializeDefaultDataList
{
    NSMutableArray *serverList = [[NSMutableArray alloc] init];
    self.serverList = serverList;
}

- (id)init
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSData *data = [pref dataForKey:@"setting"];
    
    if (data) {
        self = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
       [self initializeDefaultDataList];
    }
    [self saveSetting];
    return self;
}

- (void)saveSetting
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [pref setObject:data forKey:@"setting"];
    [pref synchronize]; // TODO check return value
}

- (void)setServerList:(NSMutableArray *)newList
{
    if (_serverList != newList) {
        _serverList = [newList mutableCopy];
    }
}

- (NSUInteger)countOfList
{
    return [self.serverList count];
}

- (SICServer *)objectInListAtIndex:(NSUInteger)theIndex
{
    return [self.serverList objectAtIndex:theIndex];
}

- (void)removeObjectFromServerListAtIndex:(NSUInteger)index
{
    [self.serverList removeObjectAtIndex:index];
    [self saveSetting];
}

- (SICServer *)addServerWithName:(NSString *)inputName host:(NSString *)inputHost
                     port:(NSUInteger) inputPort nick:(NSString *)nick pass:(NSString *)pass user:(NSString *)user real:(NSString *) real useSSL:(BOOL) inputUseSSL
{
    SICServer *server = nil;
    if ([self validateName:inputName host:inputHost port:inputPort nick:nick pass:pass user:user real:real useSSL:inputUseSSL]) {
        server = [[SICServer alloc] initWithName:inputName host:inputHost port:inputPort nick:nick pass:pass user:user real:real useSSL:inputUseSSL];
        [self.serverList addObject:server];
        [self saveSetting];
    }
    return server;
}

- (BOOL) validateName:(NSString *)name host:(NSString *)host
                 port:(NSUInteger) port nick:(NSString *) nick pass:(NSString *)pass user:(NSString *)user
                 real:(NSString *)real useSSL:(BOOL)useSSL
{
    NSArray *notEmptyParams = [NSArray arrayWithObjects:name, host, nick, user, real, nil];
    for (NSString *s in notEmptyParams) {
        if (s.length <= 0) { return NO; }
    }
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSMutableArray *servers = [NSMutableArray array];
    for (SICServer *server in self.serverList) {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        [setting setObject:server.name forKey:@"name"];
        [setting setObject:server.host forKey:@"host"];
        [setting setObject:[NSNumber numberWithUnsignedInteger:server.port] forKey:@"port"];
        [setting setObject:server.nick forKey:@"nick"];
        [setting setObject:server.pass forKey:@"pass"];
        [setting setObject:server.user forKey:@"user"];
        [setting setObject:server.real forKey:@"real"];
        [setting setObject:[NSNumber numberWithBool: server.useSSL] forKey:@"useSSL"];
        NSMutableArray *channels = [NSMutableArray array];
        for (SICChannel *channel in server.getChannels) {
            [channels addObject:channel.name];
        }
        [setting setObject:channels forKey:@"channels"];
        [servers addObject:setting];
    }
    [aCoder encodeObject:servers forKey:@"IRCSetting"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        NSMutableArray *serverList = [[NSMutableArray alloc] init];
        self.serverList = serverList;
        NSArray *data = [aDecoder decodeObjectForKey:@"IRCSetting"];
        for (NSDictionary *dict in data) {
            NSString *name = [dict valueForKey:@"name"];
            NSString *host = [dict valueForKey:@"host"];
            NSUInteger port = [[dict valueForKey:@"port"] intValue];
            NSString *nick = [dict valueForKey:@"nick"];
            NSString *pass = [dict valueForKey:@"pass"];
            NSString *user = [dict valueForKey:@"user"];
            NSString *real = [dict valueForKey:@"real"];
            BOOL useSSL = [[dict valueForKey:@"useSSL"] boolValue];
            SICServer *server = [self addServerWithName:name host:host port:port
                                                   nick:nick pass:pass user:user real:real useSSL:useSSL];
            for (NSString *channel in [dict valueForKey:@"channels"]) {
                [server.channelDataController addChannelWithName:channel];
            }
        }
    }
    return self;
}

- (void)removeChannelAtIndex:(NSUInteger)index serverIndex:(NSUInteger)serverIndex
{
    [[self objectInListAtIndex:serverIndex].channelDataController removeChannelAtIndex:index];
    [self saveSetting];
}

@end
