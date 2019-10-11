// displayTile.h

#import <UIKit/UIKit.h>

#define TILE_SIZE 50

@interface autoSizeLabel : UILabel

+(CGFloat) getSizeOfFontFromFrame:(CGRect) frame andString:(NSString *) string;

@end


@interface displayTile : UIView

@property CGPoint origin;
@property CGSize size;
@property CGFloat tileSize;
@property CGFloat tileXOffset;
@property autoSizeLabel *title;


-(instancetype) initWithOrigin:(CGPoint) origin andSize:(CGSize)size;


@end
