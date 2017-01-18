//
//  AppDelegate.m
//  HealthStoreTestDemo
//
//  Created by BillBo on 17/1/18.
//  Copyright © 2017年 BillBo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
   
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
   
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification object:nil];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
    
}


@end
