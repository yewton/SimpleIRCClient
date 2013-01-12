//
//  SICMessage.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/22.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SICPrefix;
@interface SICMessage : NSObject

@property (nonatomic) time_t receivedAt;
@property (nonatomic, strong) SICPrefix* sender;
@property (nonatomic, strong) NSString* command;
@property (nonatomic) int numericReply;
@property (nonatomic, strong) NSMutableArray* params;

- (id) initWithString: (NSString *)str;
- (NSString *)description;
@end
