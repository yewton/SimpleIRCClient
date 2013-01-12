//
//  SICPrefix.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/22.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICPrefix.h"

@implementation SICPrefix
@synthesize raw = _raw, nick = _nick, user = _user, address = _address, isServer = _isServer;

- (id)init
{
    self = [super init];
    if (self) {
        _raw = @"";
        _nick = @"";
        _user = @"";
        _address = @"";
    }
    return self;
}

@end
