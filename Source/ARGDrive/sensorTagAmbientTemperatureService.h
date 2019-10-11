// sensorTagAmbientTemperatureService.h

#import "bleGenericService.h"
#import "bluetoothHandler.h"

///@brief The sensorTagAmbientTemperatureService class receives data from the TMP007 sensor on the SensorTag 2.0 and represents it on the GUI.

@interface sensorTagAmbientTemperatureService : bleGenericService

@property CGFloat objectTemperature;
@property CGFloat ambientTemperature;

@end
