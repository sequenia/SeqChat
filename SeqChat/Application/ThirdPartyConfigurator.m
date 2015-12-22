//
//  ThirdPartyConfigurator.m
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "ThirdPartyConfigurator.h"
#import <Quickblox/Quickblox.h>

@class UIApplication;

NSUInteger const QuickBloxAppID     = 32635;
NSString* const QuickBloxAuthKey    = @"jSQJMQJSZWa2zsy";
NSString* const QuickBloxAuthSecret = @"6FHJUBN3pnB99SE";
NSString* const QuickBloxAccountKey = @"LxzLvuapqjstj7o7F6XE";

@implementation ThirdPartyConfigurator

- (void) configurate {
    [self configurateQuickBlox];
}

- (void) configurateQuickBlox {
    [QBSettings setApplicationID: QuickBloxAppID];
    [QBSettings setAuthKey: QuickBloxAuthKey];
    [QBSettings setAuthSecret: QuickBloxAuthSecret];
    [QBSettings setAccountKey: QuickBloxAccountKey];
    
    [QBSettings setAutoReconnectEnabled:YES];
    [QBLogger setCurrentLevel: QBLogLevelDebug];
}

#pragma mark - Application Events

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[QBChat instance] disconnectWithCompletionBlock: nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    QBUUser* user = [[QBChat instance] currentUser];
    if (user) {
        [[QBChat instance] connectWithUser: user completion:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[QBChat instance] disconnectWithCompletionBlock: nil];
}

@end
