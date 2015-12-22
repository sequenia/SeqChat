//
//  ThirdPartyConfigurator.h
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIApplication;

@interface ThirdPartyConfigurator : NSObject

- (void) configurate;

#pragma mark - Application Events

- (void)applicationDidEnterBackground:(UIApplication *)application;

- (void)applicationWillEnterForeground:(UIApplication *)application;

- (void)applicationWillTerminate:(UIApplication *)application;

@end
