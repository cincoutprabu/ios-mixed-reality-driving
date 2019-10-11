// sensorTagHumidityService.m

#import "sensorTagHumidityService.h"
#import "sensorFunctions.h"
#import "masterUUIDList.h"

@implementation sensorTagHumidityService

+(BOOL) isCorrectService:(CBService *)service {
    if ([service.UUID.UUIDString isEqualToString:TI_SENSORTAG_HUMIDTIY_SERVICE]) {
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
            if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_HUMIDTIY_CONFIG]) {
                self.config = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_HUMIDTIY_DATA]) {
                self.data = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_HUMIDTIY_PERIOD]) {
                self.period = c;
            }
        }
        if (!(self.config && self.data && self.period)) {
            NSLog(@"Some characteristics are missing from this service, might not work correctly !");
        }
        
        self.tile.origin = CGPointMake(0, 3);
        self.tile.size = CGSizeMake(4, 2);
        self.tile.title.text = @"Humidity";
    }
    return self;
}

-(BOOL) configureService {
    [super configureService];
    return YES;
}

-(BOOL) dataUpdate:(CBCharacteristic *)c {
    if ([self.data isEqual:c]) {
        //NSLog(@"sensorTagHumidityService: Recieved value : %@",c.value);
        oneValueCell *tile = (oneValueCell *)self.tile;
        tile.value.text = [NSString stringWithFormat:@"%@",[self calcValue:c.value]];
        return YES;
    }
    return NO;
}

- (NSString *) calcValue:(NSData *) value {
    char scratchVal[value.length];
    [value getBytes:&scratchVal length:value.length];
    UInt16 hum;
    hum = (scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00);
    self.humidity = (float)((float)hum/(float)65535) * 100.0f;
    return [NSString stringWithFormat:@"%0.1f%%",(float)self.humidity];
}

@end
