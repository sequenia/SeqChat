//
//  ViewController.h
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessages.h>
#import <Quickblox/Quickblox.h>

@interface ChatViewController : JSQMessagesViewController

@property (strong, nonatomic) QBUUser* user;

- (instancetype) initWithUser: (QBUUser*) user;

@end

