//
//  SBrickController.m
//  AGRDrive
//
//  Created by Prabu Arumugam on 4/29/16.
//  Copyright © 2016 codeding. All rights reserved.
//

#import "SBrickController.h"

#define SBRICK_PERIPHERAL_NAME @"SBrick"

#define WATCHDOG_COMMAND 0x0D
#define BRAKE_COMMAND 0x00
#define DRIVE_COMMAND 0x01

#define ENGINE_PORT 0x03
#define STEERING_PORT 0x01

#define ENGINE_SPEED 220

@implementation SBrickController

+ (SBrickController*)sharedController
{
    static SBrickController *controller = nil;
    
    if (!controller)
    {
        controller = [SBrickController new];
        controller->sbrickRCServiceUUID = [CBUUID UUIDWithString:@"4DC591B0-857C-41DE-B5F1-15ABDA665B0C"]; //SBrick Remote Control Service UUID
        controller->sbrickRCCommandsUUID = [CBUUID UUIDWithString:@"02B8CBCC-0E25-4BDA-8790-A15F53E6010F"]; //SBrick Remote Control Commands Characteristic UUID
    }
    
    return controller;
}

/*
  Methods
*/

- (void)connect
{
    NSLog(@"SBrickController: connect");
    
    dispatch_queue_t centralQueue = dispatch_queue_create("com.codeding", DISPATCH_QUEUE_SERIAL);
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
}

- (void)startBTScanning
{
    NSLog(@"SBrickController: startBTScanning");
    
    //[centralManager scanForPeripheralsWithServices:@[sbrickRCServiceUUID] options:nil];
    [centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)disconnect
{
    NSLog(@"SBrickController: disconnect");
    
    if (sbrickPeripheral != nil)
    {
        [centralManager cancelPeripheralConnection:sbrickPeripheral];
    }
}

- (BOOL)isConnected
{
    return !(sbrickPeripheral == nil || sbrickRCCharacteristic == nil);
}

- (void)resetWatchdog
{
    const unsigned char bytes[] = {WATCHDOG_COMMAND, 0};
    [self sendCommand:@"RESET_WATCHDOG" commandBytes:bytes byteCount:2];
}

- (void)driveForward
{
    const unsigned char bytes[] = {DRIVE_COMMAND, ENGINE_PORT, self->isControlsReversed ? 1 : 0, ENGINE_SPEED};
    [self sendCommand:@"DRIVE_FORWARD" commandBytes:bytes byteCount:4];
}

- (void)driveBackward
{
    const unsigned char bytes[] = {DRIVE_COMMAND, ENGINE_PORT, self->isControlsReversed ? 0 : 1, ENGINE_SPEED};
    [self sendCommand:@"DRIVE_BACKWARD" commandBytes:bytes byteCount:4];
}

- (void)stopEngine
{
    //const unsigned char bytes[] = {BRAKE_COMMAND, ENGINE_PORT};
    //[self sendCommand:@"STOP_ENGINE" commandBytes:bytes byteCount:2];
    
    const unsigned char bytes[] = {DRIVE_COMMAND, ENGINE_PORT, 0, 0};
    [self sendCommand:@"STOP_ENGINE" commandBytes:bytes byteCount:4];
}

- (void)turnLeft:(int)angle
{
    const unsigned char bytes[] = {DRIVE_COMMAND, STEERING_PORT, self->isControlsReversed ? 1 : 0, angle};
    [self sendCommand:@"TURN_LEFT" commandBytes:bytes byteCount:4];
}

- (void)turnRight:(int)angle
{
    const unsigned char bytes[] = {DRIVE_COMMAND, STEERING_PORT, self->isControlsReversed ? 0 : 1, angle};
    [self sendCommand:@"TURN_RIGHT" commandBytes:bytes byteCount:4];
}

- (void)resetSteering
{
    const unsigned char bytes[] = {BRAKE_COMMAND, STEERING_PORT};
    [self sendCommand:@"RESET_STEERING" commandBytes:bytes byteCount:2];
}

/*
  Internal Methods
*/

- (NSString*)centralManagerStateToString:(CBCentralManagerState)state
{
    switch (state)
    {
        case CBCentralManagerStateUnknown: return @"Unknown";
        case CBCentralManagerStateResetting: return @"Resetting";
        case CBCentralManagerStateUnsupported: return @"Unsupported";
        case CBCentralManagerStateUnauthorized: return @"Unauthorized";
        case CBCentralManagerStatePoweredOff: return @"PoweredOff";
        case CBCentralManagerStatePoweredOn: return @"PoweredOn";
        default: return @"";
    }
}

- (void)sendCommand:(NSString*)text commandBytes:(const unsigned char *)commandBytes byteCount:(int)byteCount
{
    if ([self isConnected])
    {
        NSLog(@"SBrickController: Sending command %@: %d bytes", text, byteCount);
        
        NSData *data = [NSData dataWithBytes:commandBytes length:byteCount];
        [sbrickPeripheral writeValue:data forCharacteristic:sbrickRCCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
    else
    {
        NSLog(@"SBrickController: Cannot send command when disconnected.");
    }
}

/*
  CBCentralManagerDelegate Events
*/

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.name == nil || [peripheral.name isEqualToString:@""])
    {
        return;
    }

    NSLog(@"SBrickController: didDiscoverPeripheral: %@", peripheral.name);
    
    if ([peripheral.name isEqualToString:SBRICK_PERIPHERAL_NAME])
    {
        [centralManager stopScan];
        
        if (sbrickPeripheral == nil)
        {
            NSLog(@"SBrickController: Connecting to SBrick..");
            
            NSData *manufacturerData = advertisementData[@"kCBAdvDataManufacturerData"];
            NSMutableString *manufacturerDataText = [NSMutableString new];
            const char *bytes = manufacturerData.bytes;
            for (int i = 0; i < manufacturerData.length; i++)
            {
                [manufacturerDataText appendFormat:@"%02hhx", (unsigned char)bytes[i]];
            }
            NSLog(@"SBrickController: ManufacturerText: %@", manufacturerDataText);
            
            if ([manufacturerDataText hasPrefix:@"98010600000"]) // Reverse the controls for MOC farm truck
            {
                self->isControlsReversed = YES;
            }
            
            sbrickPeripheral = peripheral;
            [centralManager connectPeripheral:sbrickPeripheral options:nil];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"SBrickController: didConnectPeripheral: %@", peripheral.name);
    
    if (sbrickPeripheral != nil)
    {
        NSLog(@"SBrickController: Discovering SBrick services..");
        
        peripheral.delegate = self;
        [peripheral discoverServices:@[sbrickRCServiceUUID]];
        //[peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"SBrickController: didDisconnectPeripheral: %@", peripheral.name);
    
    if ([peripheral.name isEqualToString:SBRICK_PERIPHERAL_NAME])
    {
        sbrickPeripheral = nil;
        sbrickRCCharacteristic =  nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VehicleDisconnected" object:self];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"SBrickController: centralManagerDidUpdateState: %@", [self centralManagerStateToString:central.state]);
    
    switch (central.state)
    {
        case CBCentralManagerStateUnknown:
            break;
        case CBCentralManagerStateResetting:
            break;
        case CBCentralManagerStateUnsupported:
            break;
        case CBCentralManagerStateUnauthorized:
            break;
        case CBCentralManagerStatePoweredOff:
            break;
        case CBCentralManagerStatePoweredOn:
            [self startBTScanning];
            break;
        default:
            break;
    }
}

/*
  CBPeripheralDelegate Methods
*/

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"SBrickController: didDiscoverServices: %@", peripheral.name);
    
    for (CBService *service in peripheral.services)
    {
        NSLog(@"SBrickController: Found service: %@", service.UUID);
        
        if ([service.UUID.UUIDString isEqualToString:sbrickRCServiceUUID.UUIDString])
        {
            [peripheral discoverCharacteristics:@[sbrickRCCommandsUUID] forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"SBrickController: didDiscoverCharacteristicsForService: %@", peripheral.name);
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"SBrickController: Found characteristic: %@", characteristic.UUID);
        
        if ([characteristic.UUID.UUIDString isEqualToString:sbrickRCCommandsUUID.UUIDString])
        {
            sbrickRCCharacteristic = characteristic;
            [sbrickPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VehicleConnected" object:self];
            
            [self resetWatchdog];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"SBrickController: didUpdateNotificationStateForCharacteristic: %@, Error: %@", characteristic.UUID.UUIDString, error);
}

@end
