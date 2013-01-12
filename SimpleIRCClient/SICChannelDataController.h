//
//  SICChannelDataController.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/15.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SICChannel;
@class SICServer;

@protocol ChannelDataControllerDelegate;

@interface SICChannelDataController : NSObject

@property (nonatomic, copy) NSMutableArray *channelList;
@property (weak, nonatomic) id <ChannelDataControllerDelegate> delegate;

- (NSUInteger)countOfList;
- (SICChannel *)objectInListAtIndex:(NSUInteger)theIndex;
- (void)addChannelWithName:(NSString *)inputName;
- (void)removeChannelAtIndex:(NSUInteger)index;
- (SICChannel *)getChannelWithName:(NSString *)name;

@end

@protocol ChannelDataControllerDelegate <NSObject>
- (void)afterAddingChannel:(SICChannel *)ch;
@end
