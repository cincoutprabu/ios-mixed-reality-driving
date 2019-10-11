// DeviceSelectTableViewController.h

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

///@brief The deviceSelectTableViewControllerDelegate class is a simple Bluetooth Smart device scanner that presents a list of devices
/// detected by iOS and lets the user select one of these.

@protocol deviceSelectTableViewControllerDelegate <NSObject>

-(void) newDeviceWasSelected:(NSUUID *)identifier;

@end

@interface DeviceSelectTableViewController : UITableViewController <CBCentralManagerDelegate>
@property id<deviceSelectTableViewControllerDelegate> devSelectDelegate;
@property CBCentralManager *m;
@property CBPeripheral *p;
@property NSMutableArray *discoveredDevices;
@property NSUUID *currentlySelectedDeviceIdentifier;

-(void) backButtonPressed;

@end
