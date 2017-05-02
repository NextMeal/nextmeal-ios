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

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import MultipeerConnectivity;

@interface NMMultipeer () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>

@property MCPeerID *localPeerID;
@property MCNearbyServiceAdvertiser *advertiser;
@property MCNearbyServiceBrowser *browser;

@property Menu *localMenu;
@property NSDate *localMenuUpdateDate;

@property NSMutableDictionary<NSString *, NSDate *> *activePeerUpdateDates;
@property NSMutableDictionary<NSString *, MCSession *> *activePeerSessions;

@property BOOL updatingDelegate;

@property NSMutableArray<NSString *> *ephemeralDeviceIdBlacklist;

@end

@implementation NMMultipeer

#pragma mark - Blacklist methods

- (NSArray<NSString *> *)getDeviceIdBlacklist {
    /*
     //Permanent blacklist stored in user preferences
    NSArray<NSString *> *deviceIdBlacklist = [[NSUserDefaults standardUserDefaults] objectForKey:kNMMultipeerDeviceIdBlacklistKey];
    if (deviceIdBlacklist && [deviceIdBlacklist isKindOfClass:[NSArray class]])
        return deviceIdBlacklist;
    else {
        deviceIdBlacklist = [NSArray<NSString *> new];
        [[NSUserDefaults standardUserDefaults] setObject:deviceIdBlacklist forKey:kNMMultipeerDeviceIdBlacklistKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return deviceIdBlacklist;
    }
     */
    
    //Ephemeral blacklist for app session
    if (!_ephemeralDeviceIdBlacklist)
        _ephemeralDeviceIdBlacklist = [NSMutableArray<NSString *> new];
    
    return _ephemeralDeviceIdBlacklist;
}

- (void)saveDeviceIdBlacklist:(NSArray<NSString *> *)blacklist {
    /*
     //Permanent blacklist stored in user preferences
    [[NSUserDefaults standardUserDefaults] setObject:blacklist forKey:kNMMultipeerDeviceIdBlacklistKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
     */
    
    //Ephemeral blacklist for app session
    //Do nothing, blacklist only lasts for app session
}

#pragma mark - Seed/Leach count update methods

- (void)incrementP2PSeedCount {
    NSInteger savedCount = [[NSUserDefaults standardUserDefaults] integerForKey:kP2PSeedTotal];
    [[NSUserDefaults standardUserDefaults] setInteger:savedCount+1 forKey:kP2PSeedTotal];
    
    //Fabric Answers activity logging for P2P
    [Answers logCustomEventWithName:@"P2PTransfer"
                   customAttributes:@{
                                      @"transferType" : @"seed"}];
}

- (void)incrementP2PLeachCount {
    NSInteger savedCount = [[NSUserDefaults standardUserDefaults] integerForKey:kP2PLeechTotal];
    [[NSUserDefaults standardUserDefaults] setInteger:savedCount+1 forKey:kP2PLeechTotal];
    
    //Fabric Answers activity logging for P2P
    [Answers logCustomEventWithName:@"P2PTransfer"
                   customAttributes:@{
                                      @"transferType" : @"leech"}];
}

#pragma mark - PeerID creation

- (void)createPeerID {
    _localPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].identifierForVendor.UUIDString];
}

#pragma mark - Session management methods

- (BOOL)isSeederInSessionWithPeer:(NSString *)remotePeerUUID {
    if ([_activePeerUpdateDates objectForKey:remotePeerUUID] == _localMenuUpdateDate)
        return YES;
    else
        return NO;
}

- (void)addPeerToDateDict:(NSString *)remotePeerUUID updateDate:(NSDate *)date {
    if (!_activePeerUpdateDates)
        _activePeerUpdateDates = [[NSMutableDictionary alloc] init];
    
    [_activePeerUpdateDates setObject:date forKey:remotePeerUUID];
}

- (void)removePeerFromDateDict:(NSString *)remotePeerUUID {
    if (!_activePeerUpdateDates)
        [_activePeerUpdateDates removeObjectForKey:remotePeerUUID];
}

- (void)addPeerToSessionDict:(NSString *)remotePeerUUID session:(MCSession *)session {
    if (!_activePeerSessions)
        _activePeerSessions = [[NSMutableDictionary alloc] init];
    
    [_activePeerSessions setObject:session forKey:remotePeerUUID];
}

- (void)removePeerFromSessionDict:(NSString *)remotePeerUUID {
    if (!_activePeerSessions)
        [_activePeerSessions removeObjectForKey:remotePeerUUID];
}

#pragma mark - MCSessionDelegate methods

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"Received data of length %lu from peer %@", (unsigned long)data.length, peerID.displayName);

    //If received menu is valid and delegate is set, call delegate with updated menu.
    Menu *receivedMenu = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([receivedMenu allWeeksValid] && _delegate) {
        //The delegate will call startAndUpdateLocalPeerManager to update the local menu and date.
        NSLog(@"Received menu is valid. Alerting delegate.");
        //Call delegate on main thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _updatingDelegate = YES;
            [session disconnect];
            
            [_delegate getMenuOnlineResultWithMenu:receivedMenu withUpdateDate:[_activePeerUpdateDates objectForKey:peerID.displayName] withURLResponse:nil withError:nil];
            //[session disconnect]; //Session will be autodisconnected when delegate restarts the advertiser and browser. Do not disconnect manually or else the MCSession delegate will set to start browsing again. Don't browse until the delegate has updated the menu and date data.
            _updatingDelegate = NO;
            [self removePeerFromDateDict:peerID.displayName];
        });
        [self incrementP2PLeachCount];
    } else if (![receivedMenu allWeeksValid]) { //If the menu is invalid, blacklist this device id from future connections.
        NSLog(@"Peer %@ provided an invalid menu. Adding peer to device id blacklist for future connections.", peerID.displayName);
        NSMutableArray<NSString *> *blacklist = [NSMutableArray arrayWithArray:[self getDeviceIdBlacklist]];
        [blacklist addObject:peerID.displayName];
        [self saveDeviceIdBlacklist:blacklist];
        
        //Fabric Answers activity logging for P2P
        [Answers logCustomEventWithName:@"P2PBlacklist"
                       customAttributes:@{
                                          @"blacklistedDeviceUUID" : peerID.displayName}];
    }
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
            [self removePeerFromDateDict:peerID.displayName];
            
            //Start looking for menus again if the session was disconnected (now MCSessionStateNotConnected) and we are not updating the delegate as a result of successful menu transfer.
            if (!_updatingDelegate)
                [self startBrowsing];
            break;
            
        case MCSessionStateConnecting:
            sessionStateName = @"MCSessionStateConnecting";
            
            //Stop browsing to avoid getting two menus at once.
            [self stopBrowsing];
            break;
            
        case MCSessionStateConnected:
            sessionStateName = @"MCSessionStateConnected";
            if ([self isSeederInSessionWithPeer:peerID.displayName]) {
                NSError *error;
                [session sendData:[NSKeyedArchiver archivedDataWithRootObject:_localMenu] toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
                if (error)
                    NSLog(@"Send data to peer %@ had error. %@", peerID.displayName, error.localizedDescription);
                else {
                    NSLog(@"Data sent to peer %@", peerID.displayName);
                    [self incrementP2PSeedCount];
                }
                
                //Do not disconnect here, because the session may not have sent the data yet. Wait for ack from leecher and then disconnect.
                /*
                //Disconnect when transfer done
                //[session disconnect];
                 */
            } else {
                NSLog(@"Not the seeder, waiting for data from peer.");
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
    
    NSLog(@"received invite from peer %@", peerID.displayName);
    
    //Add peer to dict of connected peers
    //Use local menu update date as the value so we can determine we are the seeder for the menu later.
    [self addPeerToDateDict:peerID.displayName updateDate:_localMenuUpdateDate];
    
    MCSession *sharingSession = [[MCSession alloc] initWithPeer:_localPeerID securityIdentity:nil encryptionPreference:MCEncryptionOptional];
    sharingSession.delegate = self;
    [self addPeerToSessionDict:peerID.displayName session:sharingSession];
    invitationHandler(YES, sharingSession);
}

#pragma mark - MCNearbyServiceBrowserDelegate methods

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"Browser failed to start with error. %@", error.localizedDescription);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    NSLog(@"Found peer %@ with info %@", peerID.displayName, info);
    
    if ([[self getDeviceIdBlacklist] containsObject:peerID.displayName]) {
        NSLog(@"Peer %@ is on the device blacklist for providing an invalid menu. Not inviting.", peerID.displayName);
        return;
    }
    
    
    //This shouldn't be needed? If we are connected to a peer, the same peer shouldn't show up again.
    /*
    //If we are already connected to this peer, do not invite them to a session.
    if ([[_activePeerUpdateDates allKeys] containsObject:peerID]) {
        NSLog(@"We are already in a session with %@. Not inviting to a session.", peerID.displayName);
        return;
    }
     */
    
    //If local menu date or data is nil and remote peer's discovery date is over X seconds ahead of us, invite them to a session.
    NSDate *remotePeerUpdateDate = [NSDate dateWithTimeIntervalSince1970:[[info objectForKey:kNMDiscoveryInfoMenuUpdateDate] doubleValue]];
    NSLog(@"Time interval since remote peer date is %f", [_localMenuUpdateDate timeIntervalSinceDate:remotePeerUpdateDate]);
    if (!_localMenuUpdateDate || !_localMenu || [_localMenuUpdateDate timeIntervalSinceDate:remotePeerUpdateDate] < kNMOutOfDateTimeInterval) {
        NSLog(@"Inviting peer %@ to session.", peerID.displayName);
        
        //Add peer to dictionary of connected peers
        [self addPeerToDateDict:peerID.displayName updateDate:remotePeerUpdateDate];
        
        //Create session and invite peer
        MCSession *sharingSession = [[MCSession alloc] initWithPeer:_localPeerID securityIdentity:nil encryptionPreference:MCEncryptionOptional];
        sharingSession.delegate = self;
        [self addPeerToSessionDict:peerID.displayName session:sharingSession];
        [browser invitePeer:peerID toSession:sharingSession withContext:nil timeout:30];
        
        //Fabric Answers activity logging for P2P
        [Answers logCustomEventWithName:@"P2PTransfer"
                       customAttributes:@{
                                          @"transferType" : @"inviteNewerPeer"}];
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
