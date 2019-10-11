// sensorTagMovementService.h

#import "bleGenericService.h"
#import "bluetoothHandler.h"

///@brief The sensorTagMovementService class receives data from the MPU-9250 sensor on the SensorTag 2.0 and represents it on the GUI.

@interface sensorTagMovementService : bleGenericService

@property Point3D acc;
@property Point3D mag;
@property Point3D gyro;

@end
