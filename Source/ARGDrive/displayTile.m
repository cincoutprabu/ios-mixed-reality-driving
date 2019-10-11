// displayTile.m

#import "displayTile.h"

@implementation autoSizeLabel

-(void) setText:(NSString *)text {
    self.font = [UIFont fontWithName:@"Menlo" size:[autoSizeLabel getSizeOfFontFromFrame:self.frame andString:text]];
    [super setText:text];
}

+(CGFloat) getSizeOfFontFromFrame:(CGRect) frame andString:(NSString *) string {
    CGFloat maxFontSize = 40;
    //if ([string rangeOfString:@"Accel"].location != NSNotFound)
    //{
    //    return 18.0f;
    //}
    UILabel *fakeLabel = [[UILabel alloc] init];
    fakeLabel.text = string;
    //Width
    while ([fakeLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Menlo" size:maxFontSize]}].width > frame.size.width)
    {
        maxFontSize -= 5;
    }
    //Height
    while ([fakeLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Menlo" size:maxFontSize]}].height > frame.size.height)
    {
        maxFontSize -= 5;
    }
    return maxFontSize;
}

@end


@implementation displayTile

-(instancetype) initWithOrigin:(CGPoint) origin andSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.origin = origin;
        self.size = size;
        self.layer.cornerRadius = 10.0f;
        self.layer.masksToBounds = YES;
        self.title = [[autoSizeLabel alloc] init];
        self.title.text = @"Title";
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [UIColor whiteColor];
        [self addSubview:self.title];
        [self setFrame:CGRectMake(0, 0, 0, 0)];
    }
    return self;
}

-(void) setFrame:(CGRect)frame {
    self.tileSize = (frame.size.width) / 8;
    if ((self.tileSize * 13) > frame.size.height) self.tileSize = (frame.size.height - 40) / 13;
    self.tileXOffset = (frame.size.width - (self.tileSize * 8)) / 2;
    //NSLog(@"TileSize :%0.1f",self.tileSize);
    
    // Set value height
    CGFloat h = self.size.height * self.tileSize - 6.0f;
    //if ([self.title.text rangeOfString:@"Motion"].location != NSNotFound)
    //{
    //    h = 240;
    //}
    [super setFrame:CGRectMake((self.origin.x * self.tileSize + 3.0f) + self.tileXOffset, self.origin.y * self.tileSize + 3.0f, self.size.width * self.tileSize - 6.0f, h)];
    
    // Set title height
    h = 30 - 4;
    //if ([self.title.text rangeOfString:@"Motion"].location != NSNotFound)
    //{
    //    h = 26;
    //}
    self.title.frame = CGRectMake(8, 2, (self.size.width * self.tileSize) - 6.0 - 8, h);
}

-(void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat titleHeight = 30.0f / (self.size.height * self.tileSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0,titleHeight,titleHeight, 1.0 };
    
    NSArray *colors = @[(__bridge id) [UIColor redColor].CGColor, (__bridge id) [UIColor blackColor].CGColor, (__bridge id) [UIColor grayColor].CGColor , (__bridge id) [UIColor grayColor].CGColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
