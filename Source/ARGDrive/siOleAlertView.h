// siOleAlertView.h

#import <UIKit/UIKit.h>
#import "displayTile.h"

///@brief The siOleAlertView class shows a custom full screen alert.

@interface siOleAlertView : UIView

@property autoSizeLabel *message;
@property UIVisualEffectView *efView;

- (instancetype) initInView:(UIView *)view;
- (void) blinkMessage:(NSString *) message;
- (void) dismissMessage;

@end
