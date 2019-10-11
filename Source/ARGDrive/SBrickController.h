//
//  SBrickController.h
//  AGRDrive
//
//  Created by Prabu Arumugam on 4/29/16.
//  Copyright © 2016 codeding. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

@interface SBrickController : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *centralManager;
    CBPeripheral *sbrickPeripheral;
    CBCharacteristic *sbrickRCCharacteristic;

    CBUUID *sbrickRCServiceUUID;
    CBUUID *sbrickRCCommandsUUID;
    
    BOOL isControlsReversed;
}

+ (SBrickController*)sharedController;

/*
  Methods
*/

- (void)connect;
- (void)startBTScanning;
- (void)disconnect;
- (BOOL)isConnected;
- (void)resetWatchdog;
- (void)driveForward;
- (void)driveBackward;
- (void)stopEngine;
- (void)turnLeft:(int)angle;
- (void)turnRight:(int)angle;
- (void)resetSteering;

@end
