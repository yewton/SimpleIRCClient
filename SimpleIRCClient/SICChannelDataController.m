//
//  SICChannelDataController.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICChannelDataController.h"
#import "SICChannel.h"
#import "SICLog.h"

@interface SICChannelDataController ()
- (void)initializeDefaultDataList;
@end

@implementation SICChannelDataController

- (void)initializeDefaultDataList
{
    NSMutableArray *channelList = [[NSMutableArray alloc] init];
    self.channelList = channelList;
    [self addChannelWithName:@"Protocol Log"];
}

- (void) setChannelList:(NSMutableArray *)newList
{
    if (_channelList != newList) {
        _channelList = [newList mutableCopy];
    }
}

- (id)init {
    if (self = [super init]) {
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

- (NSUInteger)countOfList
{
    return [self.channelList count];
}

- (SICChannel *)objectInListAtIndex:(NSUInteger)theIndex
{
    return [self.channelList objectAtIndex:theIndex];
}

- (void)addChannelWithName:(NSString *)inputName
{
    for (SICChannel *ch in self.channelList) {
        if([ch.name caseInsensitiveCompare:inputName] == NSOrderedSame) {
            NSLog(@"%@ is existing channel.", inputName);
            return;
        }
    }
    SICChannel *channel = [[SICChannel alloc] initWithName:inputName password:@"" mode:@""];
    SICLog *log = [[SICLog alloc] initWithBody:@"Joinning..."];
    [channel addLog:log];
    NSLog(@"I'm joinning into channel: %@", channel.name);
    [self.channelList addObject:channel];
    [self.delegate afterAddingChannel:channel];
}

- (SICChannel *)getChannelWithName:(NSString *)name
{
    for (SICChannel *ch in self.channelList) {
        if([ch.name caseInsensitiveCompare:name] == NSOrderedSame) {
            return ch;
        }
    }
    return nil;
}

- (void)removeChannelAtIndex:(NSUInteger)index
{
    [self.channelList removeObjectAtIndex:index];
}

@end
