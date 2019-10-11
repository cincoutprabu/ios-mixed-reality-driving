//
//  MCHandler.m
//  ARDrive
//
//  Created by Prabu Arumugam on 5/10/16.
//  Copyright © 2016 codeding. All rights reserved.
//

#import "MCHandler.h"
#import "ViewController.h"

#define VRDRIVE_SERVICETYPE @"CodedingARDrive"

@implementation MCHandler

+ (MCHandler*)sharedHandler
{
    static MCHandler *handler = nil;
    
    if (!handler)
    {
        handler = [MCHandler new];
        handler->connected = NO;
        handler->connectedPeers = [NSMutableArray new];
    }
    
    return handler;
}

/*
  Methods
*/

- (BOOL)isConnected
{
    return connected;
}

- (void)startListening:(NSString*)nodeName
{
    connected = NO;
    currentPeerID = [[MCPeerID alloc] initWithDisplayName:nodeName];
    
    _session = [[MCSession alloc] initWithPeer:currentPeerID];
    _session.delegate = self;
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:currentPeerID serviceType:VRDRIVE_SERVICETYPE];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    
    NSLog(@"MCHandler: Listening for ARGDrive nodes started..");
}

- (void)startAdvertising:(NSString*)nodeName
{
    connected = NO;
    currentPeerID = [[MCPeerID alloc] initWithDisplayName:nodeName];
    
    _session = [[MCSession alloc] initWithPeer:currentPeerID];
    _session.delegate = self;
    
    _advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:currentPeerID discoveryInfo:nil serviceType:VRDRIVE_SERVICETYPE];
    _advertiser.delegate = self;
    [_advertiser startAdvertisingPeer];
    
    NSLog(@"MCHandler: Advertising as %@ started..", nodeName);
}

- (void)sendSteerData:(double)pitch
{
    NSString *dataText = [NSString stringWithFormat:@"%lf", pitch];
    NSData *data = [dataText dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    [_session sendData:data toPeers:connectedPeers withMode:MCSessionSendDataReliable error:&error];
    
    //NSLog(@"MCHandler: Steering data sent with error: %@", error);
}

/*
  Internal Methods
*/

- (NSString*)sessionStateToString:(MCSessionState)state
{
    switch (state)
    {
        case MCSessionStateNotConnected: return @"NotConnected";
        case MCSessionStateConnecting: return @"Connecting";
        case MCSessionStateConnected: return @"Connected";
        default: return @"";
    }
}

/*
  MCSessionDelegate Methods
*/

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"MCHandler: MCSession=>didChangeState: %@ => %@", [self sessionStateToString:state], peerID.displayName);
    
    switch (state)
    {
        case MCSessionStateNotConnected:
            connected = NO;
            [connectedPeers removeObject:peerID];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PeerDisconnected" object:peerID.displayName];
            break;
            
        case MCSessionStateConnecting:
            connected = NO;
            break;
            
        case MCSessionStateConnected:
            connected = YES;
            [connectedPeers addObject:peerID];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PeerConnected" object:peerID.displayName];
            break;
            
        default:
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    //NSLog(@"MCHandler: MCSession=>didReceiveData: %ld bytes from %@", data.length, peerID.displayName);
    
    if ([peerID.displayName isEqualToString:@"ARGDriveSteerNode"])
    {
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [[ViewController sharedView] turnSteeringOnDisplay:[text doubleValue]];
    }
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    NSLog(@"MCHandler: MCSession=>didReceiveCertificate from %@", peerID.displayName);
    
    certificateHandler(YES);
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
}

/*
  MCNearbyServiceBrowserDelegate Methods
*/

- (void) browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"MCHandler: MCNearbyServiceBrowser=>foundPeer: %@", peerID.displayName);
    [browser invitePeer:peerID toSession:_session withContext:nil timeout:0];
}

- (void) browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"MCHandler: MCNearbyServiceBrowser=>lostPeer: %@", peerID.displayName);
}

- (void) browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"MCHandler: MCNearbyServiceBrowser=>didNotStartBrowsingForPeers: %@", error);
}

/*
  MCNearbyServiceAdvertiserDelegate Methods
*/

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler
{
    NSLog(@"MCHandler: MCNearbyServiceAdvertiser=>didReceiveInvitationFromPeer: %@", peerID.displayName);
    
    if (invitationHandler)
    {
        invitationHandler(YES, _session);
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"MCHandler: MCNearbyServiceAdvertiser=>didNotStartAdvertisingPeer: %@", error);
}

@end
