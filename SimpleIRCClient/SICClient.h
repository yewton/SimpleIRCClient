//
//  SICClient.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SICServer;

@interface SICClient : NSObject<NSStreamDelegate>
@property (nonatomic, copy) NSMutableArray *messages;
@property (nonatomic, strong) SICServer *server;
@property (nonatomic, strong) NSInputStream *inStream;
@property (nonatomic, strong) NSOutputStream *outStream;
@property (nonatomic, assign) BOOL connected;

-(id) initWithServer: (SICServer *)server;
-(void) connect;
-(void) disconnect;
-(void) joinChannelWithName:(NSString *)name pass:(NSString *)pass;
-(void) joinChannelWithName:(NSString *)name;
-(void) partChannelWithName:(NSString *)name;
-(void) sendPrivMsg:(NSString *)msg toChannel:(NSString *)channel;
-(void) sendNotice:(NSString *)msg toChannel:(NSString *)channel;
@end
