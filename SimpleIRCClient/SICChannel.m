//
//  SICChannel.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICChannel.h"
#import "SICLog.h"

@implementation SICChannel
@synthesize name = _name, password = _password, mode = _mode, log = _log;

const NSUInteger MAX_LOG_SIZE = 100;

-(id) initWithName:(NSString *)name password:(NSString *)password mode:(NSString *)mode
{
    self = [super init];
    if (self) {
        _name = name;
        _password = password;
        _mode = mode;
        _log = [NSMutableArray array];
        if ([name hasPrefix:@"#"]) { // TODO: both `&` and `%` should be ok
            _special = NO;
        } else {
            _special = YES;
        }
        return self;
    }
    return nil;
}

-(void) setLog:(NSMutableArray *)newLogs
{
    if (_log != newLogs) {
        _log = [newLogs mutableCopy];
    }
}

-(void) addLog:(SICLog *)message
{
    if (MAX_LOG_SIZE <= _log.count) {
        [_log removeObjectAtIndex:0];
    }
    [_log addObject:message];
    // NSLog(@"%@: added message:%@", _name, message.body);
}

@end
