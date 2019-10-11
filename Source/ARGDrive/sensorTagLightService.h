// sensorTagLightService.h

#import "bleGenericService.h"
#import "bluetoothHandler.h"

///@brief The sensorTagLightService class handles the data from the optical light sensor on the SensorTag 2.0 and
///presents it on the GUI

@interface sensorTagLightService : bleGenericService

@property CGFloat lightLevel;
+(double) sfloatExp2ToDouble:(uint16_t) sfloat;

@end
