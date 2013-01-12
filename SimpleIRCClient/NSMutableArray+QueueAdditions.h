//
//  NSMutableArray+QueueAdditions.h
//  SimpleIRCClient
//
//  Created by 佐々木 悠人 on 2012/12/22.
//  Copyright (c) 2012年 yewton. All rights reserved.
//

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end