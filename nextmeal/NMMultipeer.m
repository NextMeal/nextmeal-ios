//
//  NMMultipeer.m
//  nextmeal
//
//  Created by Anson Liu on 3/22/17.
//  Copyright © 2017 Anson Liu. All rights reserved.
//

#import "NMMultipeer.h"

#import "Constants.h"
#import "Menu.h"

@import MultipeerConnectivity;

@interface NMMultipeer () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>

@property MCPeerID *peerID;
@property MCNearbyServiceAdvertiser *advertiser;
@property MCNearbyServiceBrowser *browser;
@property Menu *sharedMenu;
@property NSDate *menuUpdateDate;

@end

@implementation NMMultipeer

#pragma mark - PeerID creation

- (void)createPeerID {
    _peerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(nonnull NSError *)error {
    NSLog(@"Advertiser failed to start with error. %@", error.localizedDescription);
}
    
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    
}

#pragma mark - MCNearbyServiceBrowserDelegate methods

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"Browser failed to start with error. %@", error.localizedDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    NSLog(@"Found peer %@", peerID.displayName);
    _menuUpdateDate
    
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Lost peer %@", peerID.displayName);
}

#pragma mark - Advertising methods

- (void)startAdvertisingWithMenu:(Menu *)menu andDate:(NSDate *)date {
    [self stopAdvertising];
    
    if (!_peerID)
        [self createPeerID];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID discoveryInfo:@{@"menuUpdateDate":date} serviceType:kNMServiceType];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
}
- (void)stopAdvertising {
    if (_advertiser)
        [_advertiser stopAdvertisingPeer];
}

#pragma mark - Browsing methods

- (void)startBrowsing {
    [self stopBrowsing];
    
    if (!_peerID)
        [self createPeerID];
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_peerID serviceType:kNMServiceType];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
}

- (void)stopBrowsing {
    if (_browser)
        [_browser stopBrowsingForPeers];
}

#pragma Advertising+Browsing control methods

- (void)startAdvertisingAndBrowsingWithMenu:(Menu *)menu andDate:(NSDate *)date {
    if ([menu allWeeksValid] && date) {
        [self startAdvertisingWithMenu:menu andDate:date];
        [self startBrowsing];
        NSLog(@"Peer services started.");
    } else {
        NSLog(@"Did not start peer services due to invalid menu or null date.");
    }
}

- (void)stopAdvertisingAndBrowsing {
    [self stopAdvertising];
    [self stopBrowsing];
    NSLog(@"Peer services stopped.");
}

@end
