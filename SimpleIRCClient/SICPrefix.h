//
//  SICPrefix.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/22.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SICPrefix : NSObject
@property (nonatomic, strong) NSString* raw;
@property (nonatomic, strong) NSString* nick;
@property (nonatomic, strong) NSString* user;
@property (nonatomic, strong) NSString* address;
@property (nonatomic) BOOL isServer;
@end
