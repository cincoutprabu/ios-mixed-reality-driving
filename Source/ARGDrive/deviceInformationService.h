// deviceInformationService.h

#import "bleGenericService.h"
#import "bluetoothHandler.h"

///@brief The deviceInformationService class handles the Bluetooth SIG Device information service
/// It presents the device informaiton on the GUI

@interface deviceInformationService : bleGenericService

@property NSString *deviceManifacturer;
@property NSString *deviceModelNumber;
@property NSString *deviceSerialNumber;
@property NSString *deviceHardwareRevision;
@property NSString *deviceFirmwareRevision;
@property NSString *deviceSoftwareRevision;
@property NSString *deviceSystemID;
@property NSString *deviceIEEE11073Reg;
@property NSString *devicePNPId;

@end
