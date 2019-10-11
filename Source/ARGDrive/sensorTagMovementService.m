// sensorTagMovementService.m

#import "sensorTagMovementService.h"
#import "sensorFunctions.h"
#import "masterUUIDList.h"

#import "MadgwickAHRS.h"

@implementation sensorTagMovementService

+(BOOL) isCorrectService:(CBService *)service {
    if ([service.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_SERVICE]) {
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
            if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_CONFIG]) {
                self.config = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_DATA]) {
                self.data = c;
            }
            else if ([c.UUID.UUIDString isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_PERIOD]) {
                self.period = c;
            }
        }
        if (!(self.config && self.data && self.period)) {
            NSLog(@"Some characteristics are missing from this service, might not work correctly !");
        }
        
        self.tile.origin = CGPointMake(0, 5);
        self.tile.size = CGSizeMake(8, 2);
        self.tile.title.text = @"Motion";
        ((oneValueCell *)(self.tile)).value.numberOfLines = 12;
        ((oneValueCell *)(self.tile)).value.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

-(BOOL) configureService {
    [super configureService];
    if (self.period) {
        [self.btHandle writeValue:[sensorFunctions dataForPeriod:100] toCharacteristic:self.period];
    }
    return YES;
}

-(BOOL) dataUpdate:(CBCharacteristic *)c {
    if ([self.data isEqual:c]) {
        //NSLog(@"sensorTagMovementService: Recieved value : %@",c.value);
        oneValueCell *tile = (oneValueCell *)self.tile;
        tile.value.text = [NSString stringWithFormat:@"%@",[self calcValue:c.value]];
        return YES;
    }
    return NO;
}

-(NSString *) calcValue:(NSData *) value {
    char vals[value.length];
    [value getBytes:vals length:value.length];
    
    Point3D gyroPoint;
    gyroPoint.x = ((float)((int16_t)((vals[0] & 0xff) | (((int16_t)vals[1] << 8) & 0xff00)))/ (float) 32768) * 255 * 1;
    gyroPoint.y = ((float)((int16_t)((vals[2] & 0xff) | (((int16_t)vals[3] << 8) & 0xff00)))/ (float) 32768) * 255 * 1;
    gyroPoint.z = ((float)((int16_t)((vals[4] & 0xff) | (((int16_t)vals[5] << 8) & 0xff00)))/ (float) 32768) * 255 * 1;
    self.gyro = gyroPoint;
    
    Point3D accPoint;
    accPoint.x = (((float)((int16_t)((vals[6] & 0xff) | (((int16_t)vals[7] << 8) & 0xff00)))/ (float) 32768) * 8) * 1;
    accPoint.y = (((float)((int16_t)((vals[8] & 0xff) | (((int16_t)vals[9] << 8) & 0xff00))) / (float) 32768) * 8) * 1;
    accPoint.z = (((float)((int16_t)((vals[10] & 0xff) | (((int16_t)vals[11] << 8) & 0xff00)))/ (float) 32768) * 8) * 1;
    self.acc = accPoint;
    
    Point3D magPoint;
    magPoint.x = (((float)((int16_t)((vals[12] & 0xff) | (((int16_t)vals[13] << 8) & 0xff00))) / (float) 32768) * 4912);
    magPoint.y = (((float)((int16_t)((vals[14] & 0xff) | (((int16_t)vals[15] << 8) & 0xff00))) / (float) 32768) * 4912);
    magPoint.z = (((float)((int16_t)((vals[16] & 0xff) | (((int16_t)vals[17] << 8) & 0xff00))) / (float) 32768) * 4912);
    self.mag = magPoint;
    
    MadgwickAHRSupdate(gyroPoint.x, gyroPoint.y, gyroPoint.z,
                       //accPoint.x, accPoint.y, accPoint.z,
                       0.0f, 0.0f, 0.0f,
                       magPoint.x, magPoint.y, magPoint.z);
    
    //MadgwickAHRSupdateIMU(gyroPoint.x, gyroPoint.y, gyroPoint.z,
    //                      accPoint.x, accPoint.y, accPoint.z);
    
    float qw = q0, qx = q1, qy = q2, qz = q3;
    float yaw = atan2(2.0*(qy*qz + qw*qx), qw*qw - qx*qx - qy*qy + qz*qz);
    float pitch = asin(-2.0*(qx*qz - qw*qy));
    float roll = atan2(2.0*(qx*qy + qw*qz), qw*qw + qx*qx - qy*qy - qz*qz);
    
    //return [NSString stringWithFormat:
    //        @"ACC: X: %+6.1f, Y: %+6.1f, Z: %+6.1f\nMAG: X: %+6.1f, Y: %+6.1f, Z: %+6.1f\nGYR: X: %+6.1f, Y: %+6.1f, Z: %+6.1f",
    //    self.acc.x,self.acc.y,self.acc.z,self.mag.x,self.mag.y,self.mag.z,self.gyro.x,self.gyro.y,self.gyro.z];
    
    //return [NSString stringWithFormat:@"q0: %+6.1f, q1: %+6.1f, q2: %+6.1f, q3: %+6.1f", q0, q1, q2, q3];
    return [NSString stringWithFormat:@"Yaw: %+6.1f, Pitch: %+6.1f, Roll: %+6.1f", yaw, pitch, roll];
}

@end
