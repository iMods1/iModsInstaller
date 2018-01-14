//
//  BonjourController.h
//  TestingBonjour
//
//  Created by Yannis on 6/30/15.
//  Copyright (c) 2015 isklikas. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <unistd.h>
#import <sys/socket.h>
#import <netinet/in.h>
#include <arpa/inet.h>

@class BonjourController;

@protocol BonjourDelegate

@optional - (void)foundNearbyiOSDevice:(NSDictionary *)device;

@end

@interface BonjourController : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic, assign) id delegate;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

- (void)startBrowsing;

@end
