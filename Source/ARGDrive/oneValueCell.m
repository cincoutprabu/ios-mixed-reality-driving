// oneValueCell.m

#import "oneValueCell.h"

@implementation oneValueCell

-(instancetype) initWithOrigin:(CGPoint)origin andSize:(CGSize)size {
    self = [super initWithOrigin:origin andSize:size];
    if (self) {
        self.value = [[autoSizeLabel alloc] init];
        self.value.font = [UIFont systemFontOfSize:25.0f];
        self.value.textColor = [UIColor whiteColor];
        self.value.text = @"---";
        self.value.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.value];
        [self setFrame:self.frame];
    }
    return self;
}

-(void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat titleHeight = 30.0f;
    self.value.frame = CGRectMake(7, titleHeight + 5, self.frame.size.width - 14, self.frame.size.height - titleHeight - 10);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
