// bluetoothHandler.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

///@brief The bluetoothHandlerDelegate is a protocol for communicating bluetooth events to the main viewcontroller

@protocol bluetoothHandlerDelegate <NSObject>
///Device has become ready, or not ready (connected and scanned / disconnected)
-(void) deviceReady:(BOOL)ready peripheral:(CBPeripheral *)peripheral;
///Characteristic was read
-(void) didReadCharacteristic:(CBCharacteristic *)characteristic;
///Received notification on characteristic
-(void) didGetNotificaitonOnCharacteristic:(CBCharacteristic *)characteristic;
///Wrote characteristic
-(void) didWriteCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

@end

///@brief Main CoreBluetooth interface of application

@interface bluetoothHandler : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

///CoreBluetooth Main handle
@property CBCentralManager *m;
///CoreBluetooth Peripheral in use
@property CBPeripheral *p;
///List containing all devices detected
@property NSMutableArray *deviceList;
///Should device reconnect if connection drops
@property BOOL shouldReconnect;
///UUID of the device to keep connection to
@property (nonatomic) NSUUID *connectToIdentifier;
///This bluetoothHandlers delegate
@property id<bluetoothHandlerDelegate> delegate;

///Initialize singleton
+(id)sharedInstance;
///Normal initializer
-(instancetype) init;
///Disconnect from the current device immediately
-(void) disconnectCurrentDevice;
///Write value to characteristic on currently connected device
-(void) writeValue:(NSData *)value toCharacteristic:(CBCharacteristic *)characteristic;
///Read value from characteristic on currently connected device
-(void) readValueFromCharacteristic:(CBCharacteristic *)characteristic;
///Turn on/off notification state of a characteristic
-(void) setNotifyStateForCharacteristic:(CBCharacteristic *)characteristic enable:(BOOL)enable;

@end
