// siOleAlertView.m

#import "siOleAlertView.h"

@implementation siOleAlertView

-(instancetype) initInView:(UIView *)view {
    self = [super init];
    if (self) {
        self.alpha = 0.0f;
        self.layer.cornerRadius = 15.0f;
        self.clipsToBounds = YES;
        self.message = [[autoSizeLabel alloc]init];
        self.message.textColor = [UIColor whiteColor];
        self.message.textAlignment = NSTextAlignmentCenter;
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffect *vibranceEffect;
        vibranceEffect = [UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.efView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        UIVisualEffectView *vib = [[UIVisualEffectView alloc] initWithEffect:vibranceEffect];
        [self.efView addSubview:vib];
        self.efView.frame = view.frame;
        [self addSubview:self.efView];
        [self addSubview:self.message];
        [view addSubview:self];
        [self setFrame:view.frame];
    }
    return self;
}

-(void) setFrame:(CGRect)frame {
#define STD_SIZE_X 300
#define STD_SIZE_Y 200
    [super setFrame:CGRectMake((frame.size.width - STD_SIZE_X) / 2, (frame.size.height - STD_SIZE_Y) / 2, STD_SIZE_X, STD_SIZE_Y)];
    self.efView.frame = self.bounds;
    self.message.frame = CGRectMake(20, 20, self.bounds.size.width - 40, self.bounds.size.height - 40);
    self.message.textColor = [UIColor blackColor];
    self.message.text = self.message.text;
}

- (void) blinkMessage:(NSString *) message {
    self.message.text = message;
    
    [UIView animateWithDuration:0.4f delay:0.0f options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0f;
    }completion:nil];
    
    [UIView animateWithDuration:0.6f delay:0.4f options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationCurveEaseInOut animations:^{
        self.message.alpha = 0.0f;
    }completion:^(BOOL finished){
    }];
}

-(void) dismissMessage {
    [UIView animateWithDuration:0.1f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
