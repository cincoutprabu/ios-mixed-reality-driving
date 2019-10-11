// sensorTagKeyService.m

#import "sensorTagKeyService.h"
#import "sensorFunctions.h"
#import "masterUUIDList.h"
#import "ViewController.h"
#import "SBrickController.h"

@implementation sensorTagKeyService

+(BOOL) isCorrectService:(CBService *)service {
    if ([service.UUID.UUIDString isEqualToString:TI_SIMPLE_KEYS_SERVICE]) {
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
            if ([c.UUID.UUIDString isEqualToString:TI_SIMPLE_KEYS_KEY_PRESS_STATE]) {
                self.data = c;
            }
        }
        if (!(self.data)) {
            NSLog(@"Some characteristics are missing from this service, might not work correctly !");
        }
        
        self.tile.origin = CGPointMake(0, 7);
        self.tile.size = CGSizeMake(8, 2);
        self.tile.title.text = @"Panic Mode";
    }
    return self;
}

-(BOOL) configureService {
    if (self.data) {
        [self.btHandle setNotifyStateForCharacteristic:self.data enable:YES];
    }
    return YES;
}

-(BOOL) deconfigureService {
    if (self.data) {
        [self.btHandle setNotifyStateForCharacteristic:self.data enable:NO];
    }
    return YES;
}


-(BOOL) dataUpdate:(CBCharacteristic *)c {
    if ([self.data isEqual:c]) {
        NSLog(@"sensorTagKeyService: Recieved value : %@",c.value);
        oneValueCell *tile = (oneValueCell *)self.tile;
        tile.value.text = [NSString stringWithFormat:@"%@",[self calcValue:c.value]];
        return YES;
    }
    return NO;
}

-(NSString *) calcValue:(NSData *) value {
    uint8_t dat[value.length];
    [value getBytes:dat length:value.length];
    if (dat[0] & 0x1) self.key1 = YES;
    else self.key1 = NO;
    if (dat[0] & 0x2) self.key2 = YES;
    else self.key2 = NO;
    if (dat[0] & 0x4) self.reedRelay = YES;
    else self.reedRelay = NO;
    //return [NSString stringWithFormat:@"Key 1: %@, Key 2: %@, Reed Relay: %@",
    //        (self.key1) ? @"ON " : @"OFF",
    //        (self.key2) ? @"ON " : @"OFF",
    //        (self.reedRelay) ? @"ON " : @"OFF"];
    
    if (self.key1)
    {
        //ViewController *vc = (ViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        //[vc connectCarButtonTouched:nil];
        //NSLog(@"VC: %@, %@", vc, NSStringFromClass(vc.class));
        
        [[SBrickController sharedController] driveForward];
        
        //NSLog(@"Showing Panic Popup");
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ARGDrive" message:@"Panic" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
    }

    //return [NSString stringWithFormat:@"Panic: %@, %@", (self.key1) ? @"ON " : @"OFF", (self.key2) ? @"ON " : @"OFF"];
    //return [NSString stringWithFormat:@"Panic: %@", (self.key1) ? @"ON " : @"OFF"];
    return self.key1 ? @"Panic ON" : @"";
}

@end
