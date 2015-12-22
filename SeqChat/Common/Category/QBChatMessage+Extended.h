//
//  QBChatMessage+Extended.h
//  SeqChat
//
//  Created by Denis Baluev on 22/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBChatMessage (Extended)

- (NSString*) stringSenderID;

- (NSString*) stringRecipientID;

@end
