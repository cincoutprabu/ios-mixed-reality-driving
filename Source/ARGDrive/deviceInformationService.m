// deviceInformationService.m

#import "deviceInformationService.h"
#import "sensorFunctions.h"
#import "masterUUIDList.h"
#import "math.h"

@implementation deviceInformationService

+(BOOL) isCorrectService:(CBService *)service {
    if ([service.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_SERVICE]) {
        return YES;
    }
    return NO;
}


-(instancetype) initWithService:(CBService *)service {
    self = [super initWithService:service];
    if (self) {
        self.btHandle = [bluetoothHandler sharedInstance];
        self.service = service;
        
        self.tile.origin = CGPointMake(0, 9);
        self.tile.size = CGSizeMake(8, 4);
        self.tile.title.text = @"Device Information Service";
        ((oneValueCell *) self.tile).value.numberOfLines = 10;
        ((oneValueCell *) self.tile).value.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

-(BOOL) configureService {
    for (CBCharacteristic *c in self.service.characteristics) {
        //Real all characteristics in the Device Information Service
        [self.btHandle readValueFromCharacteristic:c];
    }
    return YES;
}
-(BOOL) deconfigureService {
    return YES;
}

-(BOOL) dataUpdate:(CBCharacteristic *)c {
    uint8_t val[c.value.length];
    [c.value getBytes:val length:c.value.length];
    if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_SYSTEM_ID]) {
        self.deviceSystemID = [NSString stringWithFormat:@"%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx",val[0],val[1],val[2],val[3],val[4],val[5],val[6],val[7]];
        [self calcValue:nil];
    }
    else if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_MODEL_NR]) {
        self.deviceModelNumber = [[NSString alloc]initWithBytes:val length:c.value.length encoding:NSUTF8StringEncoding];
        [self calcValue:nil];
    }
    else if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_SERIAL_NR]) {
        self.deviceSerialNumber = [[NSString alloc] initWithBytes:val length:c.value.length encoding:NSUTF8StringEncoding];
        [self calcValue:nil];
    }
    else if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_FIRMWARE_REV]) {
        self.deviceFirmwareRevision = [[NSString alloc] initWithBytes:val length:c.value.length encoding:NSUTF8StringEncoding];
        [self calcValue:nil];
    }
    else if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_HARDWARE_REV]) {
        self.deviceHardwareRevision = [[NSString alloc] initWithBytes:val length:c.value.length encoding:NSUTF8StringEncoding];
        [self calcValue:nil];
    }
    else if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_SOFTWARE_REV]) {
        self.deviceSoftwareRevision = [[NSString alloc] initWithBytes:val length:c.value.length encoding:NSUTF8StringEncoding];
        [self calcValue:nil];
    }
    else if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_IEEE_11073]) {
        self.deviceIEEE11073Reg = @"N.A.";
        [self calcValue:nil];
    }
    else if ([c.UUID.UUIDString isEqualToString:BT_SIG_DEVICE_INFO_PNP_ID]) {
        self.devicePNPId = [NSString stringWithFormat:@"VIDSrc:%02hhx VID:%04x\n               PID:%04x Prod Ver: %04x",val[0],(val[1] | ((uint16_t)val[2] << 8)),
                            (val[3] | ((uint16_t)val[4] << 8)),
                            (val[5] | ((uint16_t)val[6] << 8))];
        [self calcValue:nil];
    }
    return YES;
}

-(NSString *) calcValue:(NSData *) value {
    NSString *val = [NSString stringWithFormat:
                     @"System ID    : %@\n"
                      "Model NR     : %@\n"
                      "Serial NR    : %@\n"
                      "Firmware rev : %@\n"
                      "Hardware rev : %@\n"
                      "Software rev : %@\n"
                      "PnP ID       : %@\n"
                      ,self.deviceSystemID,self.deviceModelNumber,self.deviceSerialNumber,self.deviceFirmwareRevision,self.deviceHardwareRevision,self.deviceSoftwareRevision,self.devicePNPId];
    ((oneValueCell *)self.tile).value.text = val;
    
    return val;
}


@end
