// DeviceSelectTableViewController.m

#import "DeviceSelectTableViewController.h"

@interface DeviceSelectTableViewController ()

@end

@implementation DeviceSelectTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"F0005555-0451-4000-B000-000000000000"];
    NSDictionary *standard = [NSDictionary dictionaryWithObjectsAndKeys:uuid.UUIDString,@"selectedDevice", nil];
    [d registerDefaults:standard];
    [d synchronize];
    self.currentlySelectedDeviceIdentifier = [[NSUUID alloc] initWithUUIDString:[d objectForKey:@"selectedDevice"]];
    NSLog(@"Loaded selectedDevice : %@",self.currentlySelectedDeviceIdentifier.UUIDString);

    self.title = @"Please select BLE device";
}

-(void) viewWillAppear:(BOOL)animated {
    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.discoveredDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%ld.%ld",(long)indexPath.row,(long)indexPath.section]];
    CBPeripheral *p = [self.discoveredDevices objectAtIndex:indexPath.row];
    
    cell.textLabel.text = p.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%ld dBm)", p.identifier.UUIDString, (long)p.RSSI];
    if ([p.identifier isEqual:self.currentlySelectedDeviceIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *p = [self.discoveredDevices objectAtIndex:indexPath.row];
    self.currentlySelectedDeviceIdentifier = p.identifier;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setObject:self.currentlySelectedDeviceIdentifier.UUIDString forKey:@"selectedDevice"];
    [d synchronize];
    [self.devSelectDelegate newDeviceWasSelected:self.currentlySelectedDeviceIdentifier];
    
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat: @"Discovered devices : %lu",(unsigned long)self.discoveredDevices.count];
}

-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        [central scanForPeripheralsWithServices:nil options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil]];
    }
}

-(void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([peripheral.name rangeOfString:@"SensorTag 2.0"].location == NSNotFound) return;
    
    if (!self.discoveredDevices) {
        self.discoveredDevices = [[NSMutableArray alloc]init];
    }
    
    for (CBPeripheral *p in self.discoveredDevices) {
        if ([p.identifier isEqual:peripheral.identifier]) return;
    }
    [self.discoveredDevices addObject:peripheral];
    [self.tableView reloadData];
}

-(void) backButtonPressed {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
