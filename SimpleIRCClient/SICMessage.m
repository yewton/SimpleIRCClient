//
//  SICMessage.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/22.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICMessage.h"
#import "SICPrefix.h"
#import "NSStringHelper.h"

@implementation SICMessage

@synthesize receivedAt = _receivedAt, sender = _sender, command = _command, numericReply = _numericReply, params = _params;

-(id) initWithString:(NSString *)str
{
    self = [super init];
    if (self) {
        [self parseLine: str];
    }
    return self;
}

- (void)parseLine:(NSString*)line
{
    _sender = [SICPrefix new];
    _command = @"";
    _receivedAt = 0;
    _params = [NSMutableArray new];
    
    NSMutableString* s = [line mutableCopy];
    
    while ([s hasPrefix:@"@"]) {
        NSString* t = [s getToken];
        t = [t substringFromIndex:1];
        
        int i = [t findCharacter:'='];
        if (i < 0) {
            continue;
        }
        
        NSString* key = [t substringToIndex:i];
        NSString* value = [t substringFromIndex:i+1];
        
        if ([key isEqualToString:@"t"]) {
            _receivedAt = [value longLongValue];
        }
    }
    
    if (_receivedAt == 0) {
        time(&_receivedAt);
    }
    
    if ([s hasPrefix:@":"]) {
        NSString* t = [s getToken];
        t = [t substringFromIndex:1];
        _sender.raw = t;
        
        int i = [t findCharacter:'!'];
        if (i < 0) {
            _sender.nick = t;
            _sender.isServer = YES;
        }
        else {
            _sender.nick = [t substringToIndex:i];
            t = [t substringFromIndex:i+1];
            
            i = [t findCharacter:'@'];
            if (i >= 0) {
                _sender.user = [t substringToIndex:i];
                _sender.address = [t substringFromIndex:i+1];
            }
        }
    }
    
    _command = [[s getToken] uppercaseString];
    _numericReply = [_command intValue];
    
    while (s.length) {
        if ([s hasPrefix:@":"]) {
            [_params addObject:[s substringFromIndex:1]];
            break;
        }
        else {
            [_params addObject:[s getToken]];
        }
    }
}

- (NSString*)description
{
    NSMutableString* ms = [NSMutableString string];

    [ms appendString:@"<IRCMessage "];
    if (_command) {
        [ms appendString:_command];
    }
    for (NSString* s in _params) {
        if (s == nil) { continue; }
        [ms appendString:@" "];
        [ms appendString:s];
    }
    [ms appendString:@">"];
    return ms;
}

@end
