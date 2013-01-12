//
//  SICLog.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2013/01/06.
//  Copyright (c) 2013年 yewton. All rights reserved.
//

#import "SICLog.h"

@implementation SICLog
@synthesize sender = _sender, body = _body, time = _time, notice = _notice;

-(id) initWithSender:(NSString *)sender body:(NSString *)body
{
    self = [super init];
    if (self) {
        _sender = sender;
        _body = body;
        _time = [NSDate date];
        _notice = NO;
    }
    return self;
}

-(id) initWithBody:(NSString *)body
{
    return [self initWithSender:nil body:body];
}

@end
