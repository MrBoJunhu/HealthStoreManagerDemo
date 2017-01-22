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

    [self configurationApp];
    
    return YES;
}

- (void)configurationApp {
 
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    // 设置导航栏字体颜色和tabbar字体颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{
       NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f]
       }];

    
    [[UITabBar appearance] setTintColor:[UIColor redColor]];

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
