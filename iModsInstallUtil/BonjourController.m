//
//  BonjourController.m
//  TestingBonjour
//
//  Created by Yannis on 6/30/15.
//  Copyright (c) 2015 isklikas. All rights reserved.
//

#import "BonjourController.h"

@implementation BonjourController

- (void)startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    
    // Initialize Service Browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    
    // Configure Service Browser
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_apple-mobdev2._tcp." inDomain:@"local."];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services addObject:service];
    
    if(!moreComing) {
        // Sort Services
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [self checkServices];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    // Update Services
    [self.services removeObject:service];
    
    if(!moreComing) {
        [self checkServices];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
    NSLog(@"NOPE");
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSString *deviceName = [sender hostName];
    NSArray *addresses = [sender addresses];
    NSMutableArray *ipAddresses = [NSMutableArray new];
    for (NSData *address in addresses) {
        NSString *ip = [self getStringFromAddressData:address];
        [ipAddresses addObject:ip];
    }
    if ([ipAddresses indexOfObject:@"0.0.0.0"] != NSNotFound) {
        [ipAddresses removeObject:@"0.0.0.0"];
    }
    NSString *address = ipAddresses[0];
    NSDictionary *iOSDevice = @{@"Device_Name": deviceName, @"IP_Address":address};
    if ([self.delegate respondsToSelector:@selector(foundNearbyiOSDevice:)]) {
        [self.delegate foundNearbyiOSDevice:iOSDevice];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo {
    [self stopBrowsing];
}

- (NSString *)getStringFromAddressData:(NSData *)dataIn {
    struct sockaddr_in *socketAddress = nil;
    NSString *ipString = nil;
    socketAddress = (struct sockaddr_in *)[dataIn bytes];
    ipString = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
    return ipString;
}

- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        [self setServiceBrowser:nil];
    }
}

- (void)checkServices {
    for (NSNetService *service in self.services) {
        [service setDelegate:self];
        [service resolveWithTimeout:30];
    }
}


@end
