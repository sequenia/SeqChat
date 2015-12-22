//
//  QBChatMessage+Extended.m
//  SeqChat
//
//  Created by Denis Baluev on 22/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "QBChatMessage+Extended.h"

@implementation QBChatMessage (Extended)

- (NSString*) stringSenderID {
    return [self intToSting: self.senderID];
}

- (NSString*) stringRecipientID {
    return [self intToSting: self.recipientID];
}

- (NSString*) intToSting: (NSInteger) number {
    return [NSString stringWithFormat:@"%ld", number];
}

@end
