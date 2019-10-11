// sensorTagKeyService.h

#import "bleGenericService.h"
#import "bluetoothHandler.h"


///@brief The sensorTagKeyService class handles the SensorTag Simple Keys service, it shows the current key data on the gui

@interface sensorTagKeyService : bleGenericService

@property BOOL key1;
@property BOOL key2;
@property BOOL reedRelay;

@end
