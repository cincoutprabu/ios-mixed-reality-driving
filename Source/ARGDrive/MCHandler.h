//
//  MCHandler.h
//  ARGDrive
//
//  Created by Prabu Arumugam on 5/10/16.
//  Copyright © 2016 codeding. All rights reserved.
//

@import Foundation;
@import MultipeerConnectivity;
@import AVFoundation;

@interface MCHandler : NSObject <MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate>
{
    BOOL connected;
    NSMutableArray *connectedPeers;
    
    MCPeerID *currentPeerID;
    MCSession *_session;
    //MCBrowserViewController *browser;
    //MCAdvertiserAssistant *advertiser;
    MCNearbyServiceBrowser *_browser;
    MCNearbyServiceAdvertiser *_advertiser;
    
    dispatch_queue_t sampleQueue;
}

+ (MCHandler*)sharedHandler;

/*
  Methods
*/

- (BOOL)isConnected;
- (void)startListening:(NSString*)nodeName;
- (void)startAdvertising:(NSString*)nodeName;
- (void)sendSteerData:(double)pitch;

@end
