// sensorTagAirPressureService.m

#import "sensorTagAirPressureService.h"
#import "sensorFunctions.h"
#import "masterUUIDList.h"

@implementation sensorTagAirPressureService

+(BOOL) isCorrectService:(CBService *)service {
    if ([service.UUID.UUIDString isEqualToString:TI_SENSORTAG_BAROMETER_SERVICE]) {
        return YES;
    }
    return NO;
}


-(instancetype) initWithService:(CBService *)service {
    self = [super initWithService:service];
    if (self) {
        self.btHandle = [bluetoothHandler sharedInstance];
        self.service = service;
        
        for (CBCharacteristic *c in service.characteristics) {
            if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_BAROMETER_CONFIG]) {
                self.config = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_BAROMETER_DATA]) {
                self.data = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_BAROMETER_PERIOD]) {
                self.period = c;
            }
        }
        if (!(self.config && self.data && self.period)) {
            NSLog(@"Some characteristics are missing from this service, might not work correctly !");
        }
        
        self.tile.origin = CGPointMake(4, 1);
        self.tile.size = CGSizeMake(4, 2);
        self.tile.title.text = @"Pressure";
    }
    return self;
}



-(BOOL) dataUpdate:(CBCharacteristic *)c {
    if ([self.data isEqual:c]) {
        //NSLog(@"sensorTagAirPressureService: Recieved value : %@",c.value);
        oneValueCell *tile = (oneValueCell *)self.tile;
        tile.value.text = [NSString stringWithFormat:@"%@",[self calcValue:c.value]];
        return YES;
    }
    return NO;
}

-(NSString *) calcValue:(NSData *) value {
    if (value.length < 4) return @"";
    char scratchVal[value.length];
    [value getBytes:&scratchVal length:value.length];
    uint32_t pres = (scratchVal[3] & 0xff) | ((scratchVal[4] << 8) & 0xff00) | ((scratchVal[5] << 16) & 0xff0000);
    self.airPressure =  (float)pres / 100.0f;
    return [NSString stringWithFormat:@"%0.1f mBar",(float)self.airPressure];
}

@end
