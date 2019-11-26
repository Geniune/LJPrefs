//
//  AppDelegate.m
//  PrivacyApp
//
//  Created by Apple on 2019/11/25.
//  Copyright © 2019 Geniune. All rights reserved.
//

#import "AppDelegate.h"
#import "AuthorizationViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    AuthorizationViewController *VC = [[AuthorizationViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
