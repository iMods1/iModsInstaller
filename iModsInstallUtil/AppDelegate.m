//
//  AppDelegate.m
//  iModsInstallUtil
//
//  Created by Yannis on 2/2/15.
//  Copyright (c) 2015 isklikas. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[HTTPServer sharedHTTPServer] start];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[HTTPServer sharedHTTPServer] stop];
}

@end
