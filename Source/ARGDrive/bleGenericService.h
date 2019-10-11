// bleGenericService.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "bluetoothHandler.h"
#import "oneValueCell.h"

typedef struct Point3D_ {
    CGFloat x,y,z;
} Point3D;

///@brief The bleGenericService class is the top level class for a bluetooth service.
/// It contains the basic functionality for enabling and disabling SensorTag services.\n\n
/// All the SensorTag 2 service abide to the following logic when it comes to characteristics:
/// - \b Config \b characteristic
///   - Turns the related sensor on/off and configures modes
/// - \b Period \b characteristic
///   - Sets the period in which the sensor value is refreshed and notified to host
/// - \b Data \b characteristic
///   - All data from sensor is transferred through the data characteristic
///
/// Configuration of a sensor is normally done in this way :
/// -# Write 0x01 (ON) to config characteristic
/// -# Write period 0x64 (100 * 10ms = 1000ms) register with desired period (1s for most sensors)
/// -# Enable notifications on data characteristic
///
/// Deconfiguration of a sensor is normally done in this way :
/// -# Enable notifications on data characteristic
/// -# Write 0x01 (ON) to config characteristic

@interface bleGenericService : NSObject

///The service
@property CBService *service;
///The configuration characteristic for this service
@property CBCharacteristic *config;
///The data characteristic for this service
@property CBCharacteristic *data;
///The period characteristic for this service
@property CBCharacteristic *period;
///The shared instance bluetooth handler
@property bluetoothHandler *btHandle;
///The display tile containing the GUI for this service
@property displayTile *tile;

///Check if the service is correct for this class
+(BOOL) isCorrectService:(CBService *)service;


///Initialize with a fully scanned CBService
-(instancetype) initWithService:(CBService *)service;

///Return display tile for this service to GUI
-(displayTile *) getViewForPresentation;

///Called by main program when a data update is received from BLE
-(BOOL) dataUpdate:(CBCharacteristic *)c;

///Called when service is discovered to configure the characteristic
-(BOOL) configureService;

///Called when service is to deconfigure the characteristic
-(BOOL) deconfigureService;
///Called when a value was written to the device
-(void) wroteValue:(CBCharacteristic *)c error:(NSError *)error;

@end
