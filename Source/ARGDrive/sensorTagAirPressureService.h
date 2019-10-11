// sensorTagAirPressureService.h

#import "bleGenericService.h"
#import "bluetoothHandler.h"

///@brief The sensorTagAirPressureService class receives data from the BMP280 sensor on the SensorTag 2.0 and represents it on the GUI.

@interface sensorTagAirPressureService : bleGenericService

@property CGFloat airPressure;
@property CGFloat ambientTemperature;

@end
