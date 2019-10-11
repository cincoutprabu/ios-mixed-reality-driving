// bluetoothHandler.m

#import "bluetoothHandler.h"

@implementation bluetoothHandler {
    NSUUID *_connectToIdentifier;
}

/// Make singleton
/// @return Current singleton instance
+ (id)sharedInstance {
    static bluetoothHandler *sharedBT = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBT = [[self alloc] init];
    });
    return sharedBT;
}

/// Normal initializer
/// @returns a new instance of the bluetoothHandler class
-(instancetype) init {
    self = [super init];
    if (self) {
        self.m = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.p = nil;
        self.shouldReconnect = NO;
        self.connectToIdentifier = nil;
    }
    return self;
}

-(NSUUID *)connectToIdentifier {
    return _connectToIdentifier;
}

/// Set ConnectToIdentifier, disconnects from current device and connects to the new if UUID different.
/// @param UUID to connect to
-(void) setConnectToIdentifier:(NSUUID *) uuid {
    if (uuid == nil) {
        if (self.p) {
            if ((self.p.state == CBPeripheralStateConnected) || (self.p.state == CBPeripheralStateConnecting)) {
                self.shouldReconnect = NO;
                [self.m cancelPeripheralConnection:self.p];
            }
            _connectToIdentifier = uuid;
        }
        return;
    }
    if ([uuid isEqual:self.connectToIdentifier]) {
        return;
    }
    else {
        _connectToIdentifier = uuid;
        //Check list if we have it in our device list already
        for (int ii = 0; ii < self.deviceList.count; ii++) {
            CBPeripheral *perip = [self.deviceList objectAtIndex:ii];
            if ([perip.identifier isEqual:uuid]) {
                [self.m connectPeripheral:perip options:nil];
            }
        }
    }
}

-(void) disconnectCurrentDevice {
    if (self.p) {
        if ((self.p.state == CBPeripheralStateConnected) || (self.p.state == CBPeripheralStateConnecting)) {
            self.shouldReconnect = NO;
            [self.m cancelPeripheralConnection:self.p];
            [self.delegate deviceReady:NO peripheral:self.p];
        }
    }
}


///@param value - Value to write
///@param characteristic - Characteristic to write to.
-(void) writeValue:(NSData *)value toCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic) {
        if (self.p) {
            [self.p writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            //NSLog(@"bluetoothHandler: Writing %@, with data %@",characteristic.UUID.UUIDString,value);
        }
        else {
            NSLog(@"bluetoothHandler: Cannot write when peripheral == nil");
        }
    }
    else {
        NSLog(@"bluetoothHandler: Cannot write to characterstic == nil");
    }
}

///@param characteristic - Characteristic to read from.
-(void) readValueFromCharacteristic:(CBCharacteristic *)characteristic {
    if (characteristic) {
        if (self.p) {
            [self.p readValueForCharacteristic:characteristic];
            //NSLog(@"bluetoothHandler: Reading %@",characteristic.UUID.UUIDString);
        }
        else {
            NSLog(@"bluetoothHandler: Cannot read when peripheral == nil");
        }
    }
    else {
        NSLog(@"bluetoothHandler: Cannot read from characteristic == nil");
    }
}

///@param characteristic - Characteristic to control.
///@param enable - true - enable notify, false - disable notify.
-(void) setNotifyStateForCharacteristic:(CBCharacteristic *)characteristic enable:(BOOL)enable {
    if (characteristic) {
        if (self.p) {
            [self.p setNotifyValue:enable forCharacteristic:characteristic];
            //NSLog(@"bluetoothHandler: Setting notify value on %@ to %ld",characteristic.UUID.UUIDString,(long)enable);
        }
        else {
            NSLog(@"bluetoothHandler: Cannot set notify when peripheral == nil");
        }
    }
    else {
        NSLog(@"bluetoothHandler: Cannot set notify from characteristic == nil");
    }
}

#pragma mark --CBCentralManagerDelegate methods below

/// This delegate method is called every time an update to the state of the
/// bluetooth controller changes.
-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        //Powered on means ready for use
        //Start scanning for all devices
        [self.m scanForPeripheralsWithServices:nil options:nil];
    }
}

/// This delegate method is called when the iOS device detects a new
/// peripheral it has not seen before (only once since we have not sent
/// any flags to the scanForPeripheralsWithServices options parameter)
-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    //NSLog(@"bluetoothHandler: Found peripheral with UUID : %@ and Name : %@ (%ld dBm)",peripheral.identifier,peripheral.name,(long)[RSSI integerValue]);
    if ([peripheral.name rangeOfString:@"SensorTag 2.0"].location == NSNotFound) return;
        
    if (!self.deviceList) {
        self.deviceList = [[NSMutableArray alloc] init];
    }
    if (![self.deviceList containsObject:peripheral]) {
        [self.deviceList addObject:peripheral];
    }
    if ([peripheral.identifier isEqual:self.connectToIdentifier]) {
        [self.m connectPeripheral:peripheral options:nil];
    }

}

///This delegate method is called when iOS has established connection with a
/// peripheral after the connectToPeripheral call, here we start scanning of
/// services automatically
-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"bluetoothHandler: Connected to peripheral with UUID : %@",peripheral.identifier);
    //Store peripheral
    self.p = peripheral;
    //Set delegate to us
    self.p.delegate = self;
    //Discover all services on device
    [self.p discoverServices:nil];
}

///This delegate method is callen when iOS disconnects from a peripheral
///after the cancelPeripheralConnection is called, or supervision timeout
///has been reached. Important to know here is that this method is called
///before the device actually is disconnected, and it may take up to 10
///seconds before device is actually disconnected
-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"bluetoothHandler: Disconnected from peripheral with UUID : %@",peripheral.identifier);
    [self.delegate deviceReady:NO peripheral:self.p];
    self.p = nil;
    self.p.delegate = nil;
    if (self.shouldReconnect) [self.m connectPeripheral:peripheral options:nil];
}

#pragma mark --CBPeripheralDelegate methods below

///This delegate method is called when iOS has discovered services on a peripheral. Services are an array on the peripheral class
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //Scan all characteristics in all services on device
    for (CBService *s in self.p.services) {
        [self.p discoverCharacteristics:nil forService:s];
        NSLog(@"bluetoothHandler: Discovered service with UUID : %@",s.UUID.UUIDString);
    }
}
///This delegate method is called when iOS has discovered characteristics on a service. Characteristics are an array on the peripheral service class
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"bluetoothHandler: Discovered characteristics with UUID %@ under service with UUID : %@",c.UUID.UUIDString,service.UUID.UUIDString);
    }
    //Check if we are finished scanning all services
    if ([service isEqual: [self.p.services objectAtIndex:self.p.services.count -1]]) {
        NSLog(@"bluetoothHandler: Device is ready for use");
        [self.delegate deviceReady:YES peripheral:self.p];
    }
}
///This delegate method handles all notifications that come from the
///peripheral
-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        [self.delegate didGetNotificaitonOnCharacteristic:characteristic];
    }
    else {
        NSLog(@"bluetoothHandler: error in didUpdateValueForCharacteristic : %@",error.description);
    }
}

-(void) peripheral:(nonnull CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    [self.delegate didWriteCharacteristic:characteristic error:error];
}

@end
