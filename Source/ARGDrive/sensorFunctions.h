// sensorFunctions.h

#import <Foundation/Foundation.h>

#define PERIOD_MIN 100
#define PERIOD_MAX 2550

///@brief The sensorFunctions class is a utility class that helps out with configuration data and period data calculations

@interface sensorFunctions : NSObject

///Generate data for period register on the services
+(NSData *) dataForPeriod:(NSInteger) period;
///Generate data for enable / disable service
+(NSData *) dataForEnable:(BOOL) enable;
///Generate data for enable / disable service for special services
+(NSData *) dataForEnable:(BOOL) enable forService:(NSString *)serviceUUID;

@end
