// ViewController.h

#import <UIKit/UIKit.h>
#import "DeviceSelectTableViewController.h"
#import "bleGenericService.h"
#import "siOleAlertView.h"
#import "PowerUp.h"
#import "SBrickController.h"
#import "MCHandler.h"
@import Speech;
@import CoreMotion;

@interface ViewController : UIViewController <bluetoothHandlerDelegate,deviceSelectTableViewControllerDelegate,PowerUpDelegate,SFSpeechRecognizerDelegate>
{
    SFSpeechRecognizer *speechRecognizer;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
    NSString *lastCommand;
    
    UIView *steeringContainerView;
    UIImageView *steeringImageView;
    UIImageView *leftHandImageView;
    UIImageView *rightHandImageView;
    
    NSString *nodeName;
    BOOL isBaseNode;
    BOOL isSteerNode;
    
    CMMotionManager *motionManager;
    CADisplayLink *displayLink;
    
    //Vehicle & Driving Related
    NSArray *allPercents;
    NSArray *allPowers;
    NSArray *usedPercents;
    NSArray *usedPowers;
    
    int angleCount;
    double unitAngle;
    NSMutableArray *angles;
}

@property NSString *EmpName;
@property DeviceSelectTableViewController *deviceSelector;

@property (nonatomic, strong) ARService *service;
@property (nonatomic, strong) PowerUp *powerUp;
@property (nonatomic) dispatch_semaphore_t stateSem;

@property NSMutableArray *services;
@property NSMutableArray *displayTiles;
@property bluetoothHandler *handler;
@property CAGradientLayer *gradient;
@property siOleAlertView *aV;

@property (weak, nonatomic) IBOutlet UIButton *initiateVoiceButton;
@property (weak, nonatomic) IBOutlet UIButton *connectSteeringWheelButton;
@property (weak, nonatomic) IBOutlet UIButton *connectCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *connectCarButton;
@property (nonatomic, strong) IBOutlet UIImageView *leftImage;
@property (nonatomic, strong) IBOutlet UIImageView *rightImage;

+ (ViewController*)sharedView;

- (IBAction)initiateVoiceButtonTouched:(id)sender;
- (IBAction)connectSteeringWheelButtonTouched:(id)sender;
- (IBAction)connectCameraButtonTouched:(id)sender;
- (IBAction)connectCarButtonTouched:(id)sender;

- (void)turnSteeringOnDisplay:(double)pitch;

@end
