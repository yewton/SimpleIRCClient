//
//  SICClient.m
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import "SICClient.h"
#import "SICServer.h"
#import "SICChannel.h"
#import "SICMessage.h"
#import "SICPrefix.h"
#import "SICLog.h"
#import "SICChannelDataController.h"
#import "NSMutableArray+QueueAdditions.h"

#define LF  0xa
#define CR  0xd

@interface SICClient ()
@property BOOL hasBytesAvailable;
@property (nonatomic, copy) NSMutableArray *readQueue;
@property (nonatomic, strong) NSMutableData *buffer;
@end

@interface NSStream (insecureSSL)
- (void)setInsecureSSLProperty;
+ (NSDictionary *)getInsecureSSLSetting;
@end
    
@implementation NSStream (insecureSSL)
- (void)setInsecureSSLProperty
{
    [self setProperty:NSStreamSocketSecurityLevelTLSv1 forKey:NSStreamSocketSecurityLevelKey];
}

+ (NSDictionary *)getInsecureSSLSetting
{
    static NSDictionary *setting = nil;
    if (setting == nil) {
        setting = [[NSDictionary alloc] initWithObjectsAndKeys:
                   (id)kCFBooleanTrue, kCFStreamSSLAllowsExpiredCertificates,
                   (id)kCFBooleanTrue, kCFStreamSSLAllowsAnyRoot,
                   (id)kCFBooleanFalse, kCFStreamSSLValidatesCertificateChain,
                   kCFNull, kCFStreamSSLPeerName,
                   nil];
    }
    return setting;
}
@end

@interface NSInputStream (insecureSSL)
@end

@implementation NSInputStream (insecureSSL)
- (void)setInsecureSSLProperty
{
    [super setInsecureSSLProperty];
    CFReadStreamSetProperty((CFReadStreamRef)self,
                            kCFStreamPropertySSLSettings,
                            (CFTypeRef)[NSStream getInsecureSSLSetting]);
}
@end

@interface NSOutputStream (insecureSSL)
@end

@implementation NSOutputStream (insecureSSL)
- (void)setInsecureSSLProperty
{
    [super setInsecureSSLProperty];
    CFWriteStreamSetProperty((CFWriteStreamRef)self,
                            kCFStreamPropertySSLSettings,
                            (CFTypeRef)[NSStream getInsecureSSLSetting]);
}
@end

@implementation SICClient
@synthesize messages = _messages, inStream = _inStream, outStream = _outStream;
@synthesize connected = _connected, buffer = _buffer, hasBytesAvailable = _hasBytesAvailable;

- (id)initWithServer:(SICServer *)server
{
    _connected = NO;
    _hasBytesAvailable = NO;
    self = [super init];
    if (self) {
        _server = server;
    }
    return self;
}

- (void)prepare
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL,
                                       (__bridge CFStringRef)self.server.host,
                                       self.server.port,
                                       &readStream,
                                       &writeStream);
    self.inStream = (__bridge NSInputStream *)readStream;
    self.outStream = (__bridge NSOutputStream *)writeStream;
    if (self.server.useSSL) {
        [self.inStream setInsecureSSLProperty];
        [self.outStream setInsecureSSLProperty];
    }
    [self.inStream setDelegate:self];
    [self.inStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

+ (NSString *)createMessageWithCommand: (NSString *) command params: (NSString *)params
{
    return [[NSString alloc] initWithFormat:@"%@ %@\r\n", command, params];
}

- (void)dealloc
{
    [self disconnect];
}

- (void)disconnect
{
    if (self.connected) {
        [self.inStream close];
        [self.outStream close];
        self.connected = NO;
        [self broadcast:@"Disconnected."];
    }
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode) {
        case NSStreamEventOpenCompleted:
        {
            break;
        }
        case NSStreamEventHasBytesAvailable: // 読み込み可能
        {
            stream = (NSInputStream *)stream;
            if (self.server.useSSL) {
                [stream setInsecureSSLProperty];
            }
            self.hasBytesAvailable = YES;
            [self readFromStream:(NSInputStream *)stream];
            NSString *s = [self readLine];
            while (0 < s.length) {
                [self writeProtocolLog:s];
                SICMessage *mes = [[SICMessage alloc] initWithString:s];
                [self execute:mes];
                s = [self readLine];
            }
            break;
        }
        case NSStreamEventHasSpaceAvailable: // 書き込み可能
        {
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            NSError *theError = [stream streamError];
            if ([theError code] == 0) {
                break;
            }
            [self errorWithMessage:
             [NSString stringWithFormat:
              @"Error %i: %@",
              [theError code],
              [theError localizedDescription]]];

            break;
        }
        case NSStreamEventEndEncountered:
        {
            [self disconnect];
            break;
        }
        case NSStreamEventNone:
        {
            break;
        }
    }
}

- (void) execute:(SICMessage *)message {
    NSString *cmd = message.command;
    
    if ([cmd isEqualToString:@"JOIN"]) {
        NSString *ch = message.params[0];
        [self.server.channelDataController addChannelWithName:ch];
        SICChannel *channel = [self.server.channelDataController getChannelWithName:ch];
        SICLog *log = [[SICLog alloc] initWithBody:@"Joined."];
        [channel addLog:log];
    } else if([cmd isEqualToString:@"PRIVMSG"] ||
              [cmd isEqualToString:@"NOTICE"]) {
        NSString *ch = message.params[0];
        NSString *mes = message.params[1];
        NSString *nick = message.sender.nick;

        SICChannel *channel = [self.server.channelDataController getChannelWithName:ch];
        if (channel) {
            SICLog *log = [[SICLog alloc] initWithSender:nick body:mes];
            log.notice = [cmd isEqualToString:@"NOTICE"];
            [channel addLog:log];
        }
    }
}

- (void) broadcast:(NSString *)message {
    NSMutableArray *channels = self.server.channelDataController.channelList;
    for (SICChannel *ch in channels) {
        [ch addLog:[[SICLog alloc] initWithBody:message]];
    }
}

- (void) writeProtocolLog:(NSString *)message {
    if (message.length <= 0) { return; }
    SICChannel *ch = [self.server.channelDataController getChannelWithName:@"Protocol Log"];
    [ch addLog:[[SICLog alloc] initWithBody:message]];
}

- (NSString *)readLine
{
    const char *bytes = [_buffer bytes];
    int len = [_buffer length];
    char *p = memchr(bytes, LF, len);
    if (!p) {
        return @"";
    }
    int n = p - bytes;
    
    if (n > 0) {
        char prev = *(p - 1);
        if (prev == CR) {
            --n;
        }
    }
    
    NSMutableData *data = [[NSMutableData alloc] initWithData:_buffer];
    [data setLength:n];
    
    ++p;
    if (p < bytes + len) {
        _buffer = [[NSMutableData alloc] initWithBytes:p length:bytes + len - p];
    } else {
        _buffer = [NSMutableData data];
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

- (void)readFromStream:(NSInputStream *)stream
{
    NSInteger bytesRead;
    uint8_t buf[32768];

    NSLog(@"Receiving");
    bytesRead = [stream read:buf maxLength:sizeof(buf)];
    if (bytesRead < 0) {
        [self errorWithMessage:@"Read Error"];
        NSLog(@"Read ERROR!");
        return;
    }
    NSLog(@"%d bytes received", bytesRead);
    [_buffer appendBytes:(const void *)buf length:bytesRead];
}

- (void)writeString:(NSString *)string
{
    static dispatch_queue_t q = nil;
    if (q == nil) {
        q = dispatch_queue_create("writeQueue", NULL);
    }
    dispatch_async(q, ^(void) {
        uint8_t *bytes;
        NSInteger bytesWrite;
        bytes = (uint8_t *)[string UTF8String];

        bytesWrite = [self.outStream write:bytes maxLength:strlen((const char*)bytes)];

        if (bytesWrite == -1) {
            [self errorWithMessage:[NSString stringWithFormat:@"Write Error: %@", string]];
        } else {
//            NSLog(@"%d bytes wrote", bytesWrite);
        }
    });
    return;
}

- (void)errorWithMessage:(NSString *)msg
{
    [self broadcast:msg];
    [self disconnect];
}

- (void)joinChannelWithName:(NSString *)name
{
    [self joinChannelWithName:name pass:nil];
}

- (void)joinChannelWithName:(NSString *)name pass:(NSString *)pass
{
    NSString *params;
    if (0 < pass.length) {
        params = [NSString stringWithFormat:@"%@ %@", name, pass];
    } else {
        params = name;
    }
    [self writeString:[SICClient createMessageWithCommand:@"JOIN"
                                                   params:params]];
}

- (void)partChannelWithName:(NSString *)name
{
    [self writeString:[SICClient createMessageWithCommand:@"PART" params:name]];
}

- (void)sendPrivMsg:(NSString *)msg toChannel:(NSString *)channel
{
    [self sendMessageWithCommand:@"PRIVMSG" msg:msg toChannel:channel];
}

- (void)sendNotice:(NSString *)msg toChannel:(NSString *)channel
{
    [self sendMessageWithCommand:@"NOTICE" msg:msg toChannel:channel];
}

- (void)sendMessageWithCommand:(NSString *)cmd msg:(NSString *)msg toChannel:(NSString *)channel
{
    [self writeString:
     [SICClient createMessageWithCommand:cmd
                                  params:[NSString stringWithFormat:@"%@ :%@", channel, msg]]];
}

- (void)connect
{
    if (self.connected) { return; }
    self.connected = YES;
    [self prepare];
    [self.inStream open];
    [self.outStream open];
    self.buffer = [NSMutableData new];
    [self broadcast:@"Connecting..."];
    if (0 < self.server.pass.length) {
        [self writeString:[SICClient createMessageWithCommand:@"PASS" params:self.server.pass]];
    }
    [self writeString:[SICClient createMessageWithCommand:@"USER" params:
                       [[NSString alloc] initWithFormat:@"%@ 0 * :%@", self.server.user, self.server.real]]];
    [self writeString:[SICClient createMessageWithCommand:@"NICK" params:self.server.nick]];
    for (SICChannel *ch in _server.channelDataController.channelList) {
        if (ch.special) { continue; } // 特殊なチャンネル(プロトコルログなど)
        [self joinChannelWithName:ch.name pass:ch.password];
    }
}

@end
