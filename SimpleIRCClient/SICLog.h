//
//  SICLog.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2013/01/06.
//  Copyright (c) 2013年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SICLog : NSObject
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *sender;
@property (nonatomic, assign) BOOL notice;

-(id) initWithSender:(NSString *)sender body:(NSString *)body;
-(id) initWithBody:(NSString *)body;
@end
