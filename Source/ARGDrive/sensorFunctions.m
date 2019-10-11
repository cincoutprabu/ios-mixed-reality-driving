// sensorFunctions.m

#import "sensorFunctions.h"
#import "masterUUIDList.h"

@implementation sensorFunctions

+(NSData *) dataForPeriod:(NSInteger) period {
    if (period > PERIOD_MAX) period = PERIOD_MAX;
    if (period < PERIOD_MIN) period = PERIOD_MIN;
    uint8_t pData = (uint8_t)(period / 10);
    return [NSData dataWithBytes:&pData length:1];
}

+(NSData *) dataForEnable:(BOOL) enable forService:(NSString *)serviceUUID {
    if ([serviceUUID isEqualToString:TI_SENSORTAG_TWO_MOVEMENT_SERVICE]) {
    uint8_t data[2] = { 0xFF,0x00 };
    return [NSData dataWithBytes:&data length:2];
    }
    else return [sensorFunctions dataForEnable:enable];
}

+(NSData *) dataForEnable:(BOOL) enable {
    uint8_t data = enable ? 1 : 0;
    return [NSData dataWithBytes:&data length:1];
}

@end
