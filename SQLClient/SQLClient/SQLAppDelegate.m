//
//  SQLAppDelegate.m
//  SQLClient
//
//  Created by Martin Rybak on 10/15/13.
//  Copyright (c) 2013 Martin Rybak. All rights reserved.
//

#import "SQLAppDelegate.h"
#import "SQLViewController.h"

@implementation SQLAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	//Only show SQLViewController if not testing
	if (NSClassFromString(@"XCTest")) {
		self.window.rootViewController = [[UIViewController alloc] init];
	} else {
		self.window.rootViewController = [[SQLViewController alloc] init];
	}

	[self.window makeKeyAndVisible];
    return YES;
}

@end
