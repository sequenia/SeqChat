//
//  AppDelegate.m
//  SeqChat
//
//  Created by Denis Baluev on 21/12/15.
//  Copyright © 2015 Sequenia. All rights reserved.
//

#import "AppDelegate.h"
#import "ThirdPartyConfigurator.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) ThirdPartyConfigurator* thirdPartyConfigurator;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.thirdPartyConfigurator = [[ThirdPartyConfigurator alloc] init];
    [self.thirdPartyConfigurator configurate];
    
    
    UIViewController* firstViewcontroller = [[LoginViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: firstViewcontroller];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self.thirdPartyConfigurator applicationDidEnterBackground: application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self.thirdPartyConfigurator applicationWillEnterForeground: application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self.thirdPartyConfigurator applicationWillTerminate: application];
}

@end
