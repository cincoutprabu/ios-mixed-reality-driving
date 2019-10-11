// sensorTagHumidityService.h

#import "bleGenericService.h"
#import "bluetoothHandler.h"

///@brief The sensorTagHumidityService class receives data from the HDC1000 sensor on the SensorTag 2.0 and represents it on the GUI.

@interface sensorTagHumidityService : bleGenericService

@property CGFloat humidity;
@property CGFloat ambientTemperature;

@end
