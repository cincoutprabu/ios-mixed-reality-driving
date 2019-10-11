// ViewController.m

#import "ViewController.h"
#import "siOleAlertView.h"

#import "sensorTagAmbientTemperatureService.h"
#import "sensorTagAirPressureService.h"
#import "sensorTagHumidityService.h"
#import "sensorTagMovementService.h"
#import "sensorTagLightService.h"
#import "sensorTagKeyService.h"
#import "deviceInformationService.h"

#define STEERING_WIDTH 240
#define STEERING_HEIGHT 240
#define HAND_WIDTH 60
#define HAND_HEIGHT 60

#define NODE_NAME_BASE @"ARGDriveBaseNode"
#define NODE_NAME_STEER @"ARGDriveSteerNode"

@interface ViewController ()
@end

@implementation ViewController

+ (ViewController*)sharedView
{
    static ViewController *mainView = nil;
    
    if (!mainView)
    {
        mainView = [[ViewController alloc] initWithNibName:@"MainView" bundle:nil];
    }
    
    return mainView;
}

/*
 UIView Methods
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.handler = [bluetoothHandler sharedInstance];
    self.handler.delegate = self;
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.view.bounds;
    self.gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f] CGColor], (id)[[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f] CGColor], nil];
    [self.view.layer insertSublayer:self.gradient atIndex:0];
    self.displayTiles = [[NSMutableArray alloc] init];
    
    [self populateAngles];
    [self setupNotifications];
    
    // Set button styles
    _initiateVoiceButton.layer.cornerRadius = 12.0f;
    [_initiateVoiceButton.imageView setContentMode:UIViewContentModeScaleAspectFit];

    _connectSteeringWheelButton.layer.cornerRadius = 12.0f;
    [_connectSteeringWheelButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    _connectCameraButton.layer.cornerRadius = 12.0f;
    [_connectCameraButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    _connectCarButton.layer.cornerRadius = 12.0f;
    [_connectCarButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void) viewWillLayoutSubviews {
    self.gradient.frame = self.view.bounds;
    for (displayTile *t in self.displayTiles) {
        [t setFrame:self.view.frame];
        t.title.text = t.title.text;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
  Control event handlers
*/

- (IBAction)connectSteeringWheelButtonTouched:(id)sender {
    /*
    // Connect to SensorTag
    [self.aV dismissMessage];
    [self.handler disconnectCurrentDevice];
    if (!self.deviceSelector) {
        self.deviceSelector = [[DeviceSelectTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        self.deviceSelector.devSelectDelegate = self;
    }
    [self showViewController:self.deviceSelector sender:nil];
    */
    
    isBaseNode = NO;
    isSteerNode = YES;
    nodeName = NODE_NAME_STEER;
    
    _connectSteeringWheelButton.alpha = 0.0;
    _initiateVoiceButton.alpha = 0.0;
    _connectCarButton.alpha = 0.0;
    _connectCameraButton.alpha = 0.0;
    _leftImage.alpha = 0.0;
    _rightImage.alpha = 0.0;
    
    [self addSteeringWheel];
    [[MCHandler sharedHandler] startAdvertising:nodeName];
}

- (IBAction)initiateVoiceButtonTouched:(id)sender {
    speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    speechRecognizer.delegate = self;
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
            {
                self->lastCommand = @"";
                [self beginOrEndSpeech];
                NSLog(@"Speech request authorized.");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->_initiateVoiceButton setImage:[UIImage imageNamed:@"Tick.png"] forState:UIControlStateNormal];
                    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self->_initiateVoiceButton.alpha = 0.0;
                        self->_connectSteeringWheelButton.alpha = 0.0;
                    } completion:nil];
                    
                    self->isBaseNode = YES;
                    self->isSteerNode = NO;
                    self->nodeName = NODE_NAME_BASE;
                    [[MCHandler sharedHandler] startListening:self->nodeName];
                });
                break;
            }
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"Speech request denied.");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"Speech request not determined.");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"Speech request restricted.");
                break;
            default:
                break;
        }
    }];
}

- (IBAction)connectCarButtonTouched:(id)sender
{
    [[SBrickController sharedController] connect];
}

- (IBAction)connectCameraButtonTouched:(id)sender
{
    if (_powerUp == nil)
    {
        [self registerReceivers];
        [self startDiscovery];
    }
    else
    {
        [self disconnectDrone];
    }
}

/*
  SFSpeechRecognizerDelegate Methods
*/

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"Speech recognizer availability: %d", available);
}

/*
  DeviceSelectTableViewControllerDelegate Methods
*/

- (void) newDeviceWasSelected:(NSUUID *)identifier {
    self.connectSteeringWheelButton.hidden = YES;
    
    self.handler.connectToIdentifier = identifier;
    self.handler.shouldReconnect = YES;
    for (int ii = 0; ii < self.displayTiles.count; ii++) {
        displayTile *t = [self.displayTiles objectAtIndex:ii];
        [t removeFromSuperview];
    }
    self.displayTiles = [[NSMutableArray alloc] init];
    self.services = [[NSMutableArray alloc] init];
}

/*
  BluetoothHandlerDelegate Methods
*/

- (void)deviceReady:(BOOL)ready peripheral:(CBPeripheral *)peripheral {
    if (ready) {
        if (self.aV.superview) {
            [self.aV dismissMessage];
        }
        for (int ii = 0; ii < self.displayTiles.count; ii++) {
            displayTile *t = [self.displayTiles objectAtIndex:ii];
            [t removeFromSuperview];
        }
        self.services = [[NSMutableArray alloc] init];
        for (CBService *s in peripheral.services) {
            /*
             if ([sensorTagAmbientTemperatureService isCorrectService:s]) {
             sensorTagAmbientTemperatureService *serv = [[sensorTagAmbientTemperatureService alloc] initWithService:s];
             [self.services addObject:serv];
             [serv configureService];
             displayTile *t = [serv getViewForPresentation];
             [t setFrame:self.view.frame];
             t.title.text = t.title.text;
             [self.displayTiles addObject:t];
             [self.view addSubview:t];
             }
             if ([sensorTagHumidityService isCorrectService:s]) {
             sensorTagHumidityService *serv = [[sensorTagHumidityService alloc] initWithService:s];
             [self.services addObject:serv];
             [serv configureService];
             displayTile *t = [serv getViewForPresentation];
             [t setFrame:self.view.frame];
             t.title.text = t.title.text;
             [self.displayTiles addObject:t];
             [self.view addSubview:t];
             }
             if ([sensorTagAirPressureService isCorrectService:s]) {
             sensorTagAirPressureService *serv = [[sensorTagAirPressureService alloc] initWithService:s];
             [self.services addObject:serv];
             [serv configureService];
             displayTile *t = [serv getViewForPresentation];
             [t setFrame:self.view.frame];
             t.title.text = t.title.text;
             [self.displayTiles addObject:t];
             [self.view addSubview:t];
             }
             if ([sensorTagLightService isCorrectService:s]) {
             sensorTagLightService *serv = [[sensorTagLightService alloc] initWithService:s];
             [self.services addObject:serv];
             [serv configureService];
             displayTile *t = [serv getViewForPresentation];
             [t setFrame:self.view.frame];
             t.title.text = t.title.text;
             [self.displayTiles addObject:t];
             [self.view addSubview:t];
             }
             if ([sensorTagKeyService isCorrectService:s]) {
             sensorTagKeyService *serv = [[sensorTagKeyService alloc] initWithService:s];
             [self.services addObject:serv];
             [serv configureService];
             displayTile *t = [serv getViewForPresentation];
             [t setFrame:self.view.frame];
             t.title.text = t.title.text;
             [self.displayTiles addObject:t];
             [self.view addSubview:t];
             }
             */
            if ([sensorTagMovementService isCorrectService:s]) {
                sensorTagMovementService *serv = [[sensorTagMovementService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
                displayTile *t = [serv getViewForPresentation];
                [t setFrame:self.view.frame];
                t.title.text = t.title.text;
                [self.displayTiles addObject:t];
                [self.view addSubview:t];
            }
            /*
             if ([deviceInformationService isCorrectService:s]) {
             deviceInformationService *serv = [[deviceInformationService alloc] initWithService:s];
             [self.services addObject:serv];
             [serv configureService];
             displayTile *t = [serv getViewForPresentation];
             [t setFrame:self.view.frame];
             t.title.text = t.title.text;
             [self.displayTiles addObject:t];
             [self.view addSubview:t];
             }
             */
        }
    }
    else {
        [self blinkAlertMessage:@"Steering Disconnected!"];
    }
}

- (void)didReadCharacteristic:(CBCharacteristic *)characteristic {
    for (int ii = 0; ii < self.services.count; ii++) {
        bleGenericService *s = [self.services objectAtIndex:ii];
        [s dataUpdate:characteristic];
    }
}

- (void)didGetNotificaitonOnCharacteristic:(CBCharacteristic *)characteristic {
    for (int ii = 0; ii < self.services.count; ii++) {
        bleGenericService *s = [self.services objectAtIndex:ii];
        [s dataUpdate:characteristic];
    }
}

- (void)didWriteCharacteristic:(CBCharacteristic *)characteristic error:(NSError *) error {
    for (int ii = 0; ii < self.services.count; ii++) {
        bleGenericService *s = [self.services objectAtIndex:ii];
        [s wroteValue:characteristic error:error];
    }
}

/*
  PowerUpDelegate Methods
*/

- (void)powerUp:(PowerUp*)powerUp connectionDidChange:(eARCONTROLLER_DEVICE_STATE)state
{
    switch (state) {
        case ARCONTROLLER_DEVICE_STATE_RUNNING:
        {
            NSLog(@"PowerUp connected.");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_connectCameraButton setImage:[UIImage imageNamed:@"Tick.png"] forState:UIControlStateNormal];
                [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self->_connectCameraButton.alpha = 0.0;
                } completion:nil];
                
                self->_connectSteeringWheelButton.alpha = 0.0;
                self->_initiateVoiceButton.alpha = 0.0;
                self->_connectCarButton.alpha = 0.0;
            });
            break;
        }
        case ARCONTROLLER_DEVICE_STATE_STOPPED:
            dispatch_semaphore_signal(_stateSem);
            NSLog(@"PowerUp disconnected.");
            break;
        default:
            break;
    }
}

- (void)powerUp:(PowerUp*)powerUp batteryDidChange:(int)batteryPercentage
{
    NSLog(@"PowerUp battery changed to: %d%%", batteryPercentage);
}

- (void)powerUp:(PowerUp*)powerUp flyingStateDidChange:(eARCOMMANDS_POWERUP_PILOTINGSTATE_FLYINGSTATECHANGED_STATE)state
{
    switch (state) {
        case ARCOMMANDS_POWERUP_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_LANDED:
            NSLog(@"PowerUp landed.");
            break;
        case ARCOMMANDS_POWERUP_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_FLYING:
        //case ARCOMMANDS_POWERUP_PILOTINGSTATE_FLYINGSTATECHANGED_STATE_HOVERING:
            NSLog(@"PowerUp flying.");
            break;
        default:
            NSLog(@"PowerUp state default.");
            break;
    }
}

- (BOOL)powerUp:(PowerUp *)powerUp configureDecoder:(ARCONTROLLER_Stream_Codec_t)codec
{
    return YES;
}

- (BOOL)powerUp:(PowerUp *)powerUp didReceiveFrame:(ARCONTROLLER_Frame_t *)frame
{
    NSData *imgData = [NSData dataWithBytes:frame->data length:frame->used];
    UIImage *image = [UIImage imageWithData:imgData];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        _leftImage.image = image;
        _rightImage.image = image;
    });

    return YES;
}

- (void)powerUp:(PowerUp *)powerUp didFoundMatchingMedias:(NSUInteger)nbMedias {
}

- (void)powerUp:(PowerUp *)powerUp media:(NSString *)mediaName downloadDidProgress:(int)progress {
}

- (void)powerUp:(PowerUp *)powerUp mediaDownloadDidFinish:(NSString *)mediaName {
}

/*
 Notifications Helper Methods
 */

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"VehicleConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"VehicleDisconnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"PeerConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"PeerDisconnected" object:nil];
}

- (void)receiveNotification:(NSNotification*)notification
{
    NSLog(@"Notification received: %@, Obj: %@", notification.name, notification.object);
    
    if ([[notification name] isEqualToString:@"VehicleConnected"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_connectCarButton setImage:[UIImage imageNamed:@"Tick.png"] forState:UIControlStateNormal];
            [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self->_connectCarButton.alpha = 0.0;
            } completion:nil];
        });
    }
    else if ([[notification name] isEqualToString:@"VehicleDisconnected"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self blinkAlertMessage:@"Vehicle Disconnected!"];
        });
    }
    else if ([[notification name] isEqualToString:@"PeerConnected"])
    {
        if ([self->nodeName isEqualToString:NODE_NAME_BASE] && [notification.object isEqualToString:NODE_NAME_STEER])
        {
            [self performSelectorOnMainThread:@selector(onSteeringConnected) withObject:nil waitUntilDone:NO];
        }
        else if ([self->nodeName isEqualToString:NODE_NAME_STEER] && [notification.object isEqualToString:NODE_NAME_BASE])
        {
            NSLog(@"MainView: Setting up steering wheel orientation capture..");
            [self performSelectorOnMainThread:@selector(setupMotionCapture) withObject:nil waitUntilDone:NO];
        }
    }
    else if ([[notification name] isEqualToString:@"PeerDisconnected"])
    {
        if ([self->nodeName isEqualToString:NODE_NAME_BASE] && [notification.object isEqualToString:NODE_NAME_STEER])
        {
            [self performSelectorOnMainThread:@selector(onSteeringDisconnected) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)onSteeringConnected
{
    [self populateAngles];
}

- (void)onSteeringDisconnected
{
}

/*
 Motion Capture Methods
 */

NSDate *lastSteerTime;

- (void)setupMotionCapture
{
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 0.02;  //50 Hz
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if ([motionManager isDeviceMotionAvailable])
    {
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
        lastSteerTime = [NSDate date];
    }
}

- (void)motionRefresh:(id)sender
{
    NSTimeInterval diff = [lastSteerTime timeIntervalSinceNow] * -1.0f;
    if (diff >= 0.2f) //Process rotation every few milliseconds
    {
        double pitch = motionManager.deviceMotion.attitude.pitch;
        [self turnSteeringOnDisplay:pitch];
        //NSLog(@"MainView: Device pitch: %lf", pitch);
        
        if ([[MCHandler sharedHandler] isConnected])
        {
            [[MCHandler sharedHandler] sendSteerData:pitch];
        }
        
        lastSteerTime = [NSDate date];
    }
}

- (void)turnSteeringOnDisplay:(double)pitch
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->steeringContainerView.transform = CGAffineTransformMakeRotation(pitch);
        
        if ([[SBrickController sharedController] isConnected])
        {
            [self populateAngles];
            int steerPower = [self getSteeringPower:fabs(pitch)];
            if (pitch >= 0)
            {
                [[SBrickController sharedController] turnRight:steerPower];
            }
            else
            {
                [[SBrickController sharedController] turnLeft:steerPower];
            }
        }
        
        //NSLog(@"Steering rotation: %lf", pitch);
    });
}

/*
 Driving Methods
 */

- (double)getSteeringPower:(double)pitch
{
    int steerPower = 0.0;
    for (int i = 0; i < angleCount; i += 1)
    {
        double angle = unitAngle * (i + 1);
        if (pitch < angle)
        {
            steerPower = [usedPowers[i] intValue];
            break;
        }
    }
    
    //NSLog(@"MainView: SteerPower: %d for pitch %lf", steerPower, pitch);
    return steerPower;
}

- (void)populateAngles
{
    allPercents = [NSArray arrayWithObjects:@0.264, @0.379, @0.494, @0.632, @0.747, @0.874, @1.00, nil];
    allPowers =   [NSArray arrayWithObjects:@67,    @96,    @126,   @161,   @190,   @223,   @255,  nil];
    
    usedPercents = [NSArray arrayWithObjects:@0.264, @0.494, @0.747, @1.00, nil];
    usedPowers =   [NSArray arrayWithObjects:@67,    @126,   @190,   @255,  nil];
    
    angleCount = 4;
    unitAngle = M_PI_2 / angleCount;
    
    angles = [NSMutableArray new];
    for (int i = 0; i < angleCount; i += 1)
    {
        [angles addObject:[NSNumber numberWithDouble:(unitAngle * (i + 1))]];
    }
    
    //NSLog(@"MainView: Unit Angle: %lf for %d angles", unitAngle, angleCount);
    //NSLog(@"MainView: Percents: %@, Powers: %@, Angles: %@", usedPercents, usedPowers, angles);
}

/*
 Helper Methods
 */

- (void)blinkAlertMessage:(NSString*)message {
    if (self.aV) [self.aV dismissMessage];
    self.aV = [[siOleAlertView alloc] initInView:self.view];
    [self.aV blinkMessage:message];
}

- (void)beginOrEndSpeech {
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionRequest endAudio];
    } else {
        [self startListeningForSpeech];
    }
}

- (void)startListeningForSpeech
{
    audioEngine = [[AVAudioEngine alloc] init];
    
    // Make sure there's not a recognition task already running
    if (recognitionTask) {
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    // Start AVAudioSession
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    // Starts a recognition process, in the block it logs the input or stops the audio
    // process if there's an error.
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = audioEngine.inputNode;
    recognitionRequest.shouldReportPartialResults = YES;
    recognitionTask = [speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Get last spoken word as command
            __block NSString *command = nil;
            NSString *spokenText = result.bestTranscription.formattedString;
            [spokenText enumerateSubstringsInRange:NSMakeRange(0, spokenText.length) options:NSStringEnumerationByWords | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange subrange, NSRange enclosingRange, BOOL *stop) {
                command = [substring lowercaseString];
                *stop = YES;
            }];
            
            // Process the command
            if (![self->lastCommand isEqualToString:command])
            {
                NSLog(@"Voice Command: %@", command);
                [self onVoiceCommand:command];
                self->lastCommand = command;
            }
            isFinal = !result.isFinal;
        }
        if (error) {
            [self->audioEngine stop];
            [inputNode removeTapOnBus:0];
            self->recognitionRequest = nil;
            self->recognitionTask = nil;
        }
    }];
    
    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self->recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    // Starts the audio engine, i.e. it starts listening.
    [audioEngine prepare];
    [audioEngine startAndReturnError:&error];
    NSLog(@"Listening for speech input started.");
}

- (void)onVoiceCommand:(NSString*)command
{
    if (![[SBrickController sharedController] isConnected])
    {
        NSLog(@"Cannot run command '%@' as car is not connected.", command);
        return;
    }
    
    if ([command isEqualToString:@"go"])
    {
        [[SBrickController sharedController] driveForward];
    }
    else if ([command isEqualToString:@"back"])
    {
        [[SBrickController sharedController] driveBackward];
    }
    else if ([command isEqualToString:@"stop"])
    {
        [[SBrickController sharedController] stopEngine];
    }
}

- (void)addSteeringWheel
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect steeringRect = CGRectMake(0, 0, STEERING_WIDTH, STEERING_HEIGHT);
    steeringRect.origin.x = (screenRect.size.width - STEERING_WIDTH) / 2.0;
    steeringRect.origin.y = (screenRect.size.height - STEERING_HEIGHT) / 2.0;
    
    steeringContainerView = [[UIView alloc] initWithFrame:screenRect];
    steeringContainerView.alpha = 0.8;
    
    UIImage *steeringImage = [UIImage imageNamed:@"Steering.png"];
    steeringImageView = [[UIImageView alloc] initWithImage:steeringImage];
    steeringImageView.frame = steeringRect;
    [steeringContainerView addSubview:steeringImageView];
    
    UIImage *leftHandImage = [UIImage imageNamed:@"GrabLeft.png"];
    leftHandImageView = [[UIImageView alloc] initWithImage:leftHandImage];
    leftHandImageView.frame = CGRectMake(steeringRect.origin.x - 8, steeringRect.origin.y + 120, HAND_WIDTH, HAND_HEIGHT);
    leftHandImageView.alpha = 0.8;
    [steeringContainerView addSubview:leftHandImageView];
    
    UIImage *rightHandImage = [UIImage imageNamed:@"GrabRight.png"];
    rightHandImageView = [[UIImageView alloc] initWithImage:rightHandImage];
    rightHandImageView.frame = CGRectMake(steeringRect.origin.x + STEERING_WIDTH - 52, steeringRect.origin.y + 120, HAND_WIDTH, HAND_HEIGHT);
    rightHandImageView.alpha = 0.8;
    [steeringContainerView addSubview:rightHandImageView];
    
    [self.view addSubview:steeringContainerView];
    [self.view bringSubviewToFront:steeringContainerView];
    
    NSLog(@"MainView: Screen: %@, Steering: %@", NSStringFromCGRect(screenRect), NSStringFromCGRect(steeringImageView.frame));
}

- (void)registerReceivers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(discoveryDidUpdateServices:) name:kARDiscoveryNotificationServicesDevicesListUpdated object:nil];
}

- (void)startDiscovery
{
    [[ARDiscovery sharedInstance] start];
}

- (void)discoveryDidUpdateServices:(NSNotification *)notification
{
    NSArray *deviceList = [[notification userInfo] objectForKey:kARDiscoveryServicesList];
    
    for (ARService* service in deviceList)
    {
        NSLog(@"Drone Service: %@", service.name);
        
        if ([service.name rangeOfString:@"PowerUp-268664"].location != NSNotFound)
        {
            [self unregisterReceivers];
            [self stopDiscovery];
            
            _stateSem = dispatch_semaphore_create(0);
            _service = service;
            
            _powerUp = [[PowerUp alloc] initWithService:_service];
            [_powerUp setDelegate:self];
            [_powerUp connect];
            
            break;
        }
    }
}

// this should be called in background
- (ARDISCOVERY_Device_t *)createDiscoveryDeviceWithService:(ARService*)service
{
    ARDISCOVERY_Device_t *device = NULL;
    eARDISCOVERY_ERROR errorDiscovery = ARDISCOVERY_OK;
    
    device = [service createDevice:&errorDiscovery];
    
    if (errorDiscovery != ARDISCOVERY_OK)
        NSLog(@"Discovery error :%s", ARDISCOVERY_Error_ToString(errorDiscovery));
    
    return device;
}

- (void)unregisterReceivers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kARDiscoveryNotificationServicesDevicesListUpdated object:nil];
}

- (void)stopDiscovery
{
    [[ARDiscovery sharedInstance] stop];
}

- (void)disconnectDrone
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->_powerUp disconnect];
        dispatch_semaphore_wait(self->_stateSem, DISPATCH_TIME_FOREVER); // Wait for the disconnection to appear
        self->_powerUp = nil;
    });
}

@end
