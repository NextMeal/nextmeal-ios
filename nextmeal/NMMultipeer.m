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

@property MCPeerID *localPeerID;
@property MCNearbyServiceAdvertiser *advertiser;
@property MCNearbyServiceBrowser *browser;

@property Menu *localMenu;
@property NSDate *localMenuUpdateDate;

@property NSMutableDictionary<MCPeerID *, NSDate *> *activePeerUpdateDates;

@property MCSession *savedSession;

@end

@implementation NMMultipeer

#pragma mark - PeerID creation

- (void)createPeerID {
    _localPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].identifierForVendor.UUIDString];
}

#pragma mark - Session management methods

- (BOOL)isSeederInSessionWithPeer:(MCPeerID *)remotePeerID {
    if ([_activePeerUpdateDates objectForKey:remotePeerID] == _localMenuUpdateDate)
        return YES;
    else
        return NO;
}

- (void)addPeerToDict:(MCPeerID *)remotePeerID updateDate:(NSDate *)date {
    if (!_activePeerUpdateDates)
        _activePeerUpdateDates = [[NSMutableDictionary alloc] init];
    
    [_activePeerUpdateDates setObject:date forKey:remotePeerID];
}

- (void)removePeerFromDict:(MCPeerID *)remotePeerID {
    [_activePeerUpdateDates removeObjectForKey:remotePeerID];
}

#pragma mark - MCSessionDelegate methods

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"Received data of length %lu from peer %@", (unsigned long)data.length, peerID.displayName);
    
    //If received menu is valid and delegate is set, call delegate with updated menu.
    Menu *receivedMenu = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([receivedMenu allWeeksValid] && _delegate) {
        NSLog(@"Received menu is valid. Alerting delegate.");
        [_delegate getMenuOnlineResultWithMenu:receivedMenu withURLResponse:nil withError:nil];
    }
    
    [session disconnect];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSString *sessionStateName;
    
    switch (state) {
        case MCSessionStateNotConnected:
            sessionStateName = @"MCSessionStateNotConnected";
            [self removePeerFromDict:peerID];
            break;
            
        case MCSessionStateConnecting:
            sessionStateName = @"MCSessionStateConnecting";
            break;
            
        case MCSessionStateConnected:
            sessionStateName = @"MCSessionStateConnected";
            if ([self isSeederInSessionWithPeer:peerID]) {
                NSError *error;
                [session sendData:[NSKeyedArchiver archivedDataWithRootObject:_localMenu] toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
                if (error)
                    NSLog(@"Send data to peer %@ had error. %@", peerID.displayName, error.localizedDescription);
                
                //Disconnect when transfer done
                [session disconnect];
            }
            break;
            
        default:
            break;
    }
    
    NSLog(@"Session with %@ changed state to %@", peerID.displayName, sessionStateName);
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler {
    certificateHandler(YES);
    
}

#pragma mark - MCNearbyServiceAdvertiserDelegate methods

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(nonnull NSError *)error {
    NSLog(@"Advertiser failed to start with error. %@", error.localizedDescription);
}
    
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nullable))invitationHandler {
    
    //Add peer to dict of connected peers
    //Use local menu update date as the value so we can determine we are the seeder for the menu later.
    [self addPeerToDict:peerID updateDate:_localMenuUpdateDate];
    
    MCSession *sharingSession = [[MCSession alloc] initWithPeer:_localPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
    sharingSession.delegate = self;
    _savedSession = sharingSession;
    invitationHandler(YES, sharingSession);
}

#pragma mark - MCNearbyServiceBrowserDelegate methods

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"Browser failed to start with error. %@", error.localizedDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    NSLog(@"Found peer %@ with info %@", peerID.displayName, info);
    
    NSLog(@"Time interval since remote peer date is %f", [_localMenuUpdateDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:[[info objectForKey:kNMDiscoveryInfoMenuUpdateDate] doubleValue]]]);
    
    /*
    //If we are already connected to this peer, do not invite them to a session.
    if ([[_activePeerUpdateDates allKeys] containsObject:peerID]) {
        NSLog(@"We are already in a session with %@. Not inviting to a session.", peerID.displayName);
        return;
    }
     */
    
    //If local menu date or data is nil and remote peer's discovery date is over X seconds ahead of us, invite them to a session.
    NSDate *remotePeerUpdateDate = [NSDate dateWithTimeIntervalSince1970:[[info objectForKey:kNMDiscoveryInfoMenuUpdateDate] doubleValue]];
    if (!_localMenuUpdateDate || !_localMenu || [_localMenuUpdateDate timeIntervalSinceDate:remotePeerUpdateDate] < -10) {
        NSLog(@"Inviting peer %@ to session.", peerID.displayName);
        
        //Add peer to dictionary of connected peers
        [self addPeerToDict:peerID updateDate:remotePeerUpdateDate];
        
        //Create session and invite peer
        MCSession *sharingSession = [[MCSession alloc] initWithPeer:_localPeerID securityIdentity:nil encryptionPreference:MCEncryptionNone];
        sharingSession.delegate = self;
        [browser invitePeer:peerID toSession:sharingSession withContext:nil timeout:30];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"Lost peer %@", peerID.displayName);
}

#pragma mark - Advertising methods

- (void)startAdvertisingWithMenu:(Menu *)menu andDate:(NSDate *)date {
    _localMenu = menu;
    _localMenuUpdateDate = date;
    
    [self stopAdvertising];
    
    if (!_localPeerID)
        [self createPeerID];
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_localPeerID discoveryInfo:@{kNMDiscoveryInfoMenuUpdateDate:[NSString stringWithFormat:@"%f",date.timeIntervalSince1970]} serviceType:kNMServiceType];
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
    
    if (!_localPeerID)
        [self createPeerID];
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID serviceType:kNMServiceType];
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
        NSLog(@"Peer advertising services started.");
    } else {
        NSLog(@"Did not start advertising peer services due to invalid menu or null date.");
    }
    [self startBrowsing];
}

- (void)stopAdvertisingAndBrowsing {
    [self stopAdvertising];
    [self stopBrowsing];
    NSLog(@"Peer services stopped.");
}

@end
