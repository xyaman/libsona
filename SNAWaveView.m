#import "public/SNAWaveView.h"

#define MIN_HZ 20
#define MAX_HZ 20000

// Get the mid point of 2 points
static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);

    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;

    return controlPoint;
}

@interface SNAWaveView ()
@property(nonatomic, retain) NSMutableArray *colors;
@property(nonatomic, retain) CAGradientLayer *gradient;
@end

@implementation SNAWaveView
-(id) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];

    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.strokeColor = self.pointColor.CGColor;
    self.shapeLayer.fillColor = self.pointSecondaryColor.CGColor;
    self.shapeLayer.lineWidth = 1.5f;
    [self.layer addSublayer:self.shapeLayer];

    return self;
}

- (void) updateColors {

    if(!self.pointColor) self.pointColor = [UIColor whiteColor];

    // Define colours depending of colouring style
    if(self.coloringStyle == SNAColoringStyleFull) {

        self.shapeLayer.strokeColor = self.pointSecondaryColor ? self.pointSecondaryColor.CGColor : self.pointColor.CGColor;
        self.shapeLayer.fillColor = self.shapeLayer.strokeColor;

    } else if(self.coloringStyle == SNAColoringStyleSolid) {

        self.shapeLayer.strokeColor = self.pointColor.CGColor;
        self.shapeLayer.fillColor = self.pointSecondaryColor ? self.pointSecondaryColor.CGColor : self.pointColor.CGColor;
   
    } else if(self.coloringStyle == SNAColoringStyleGradient) {

        if(!self.gradient) {
            self.gradient = [CAGradientLayer layer];
            self.gradient.startPoint = CGPointMake(0.5, 1.0);
            self.gradient.endPoint = CGPointMake(0.5, 0.0);
            self.gradient.mask = self.shapeLayer;
            [self.layer addSublayer:self.gradient];

            self.gradient.frame = self.layer.bounds;
            self.shapeLayer.frame = self.gradient.bounds;

            self.colors = [NSMutableArray arrayWithCapacity:2];
            self.colors[0] = (id)self.pointColor.CGColor;
            self.colors[1] = self.colors[0];
        }

        self.colors[0] = (id)self.pointColor.CGColor;
        self.colors[1] = self.pointSecondaryColor ? (id)self.pointSecondaryColor.CGColor : (id)self.pointColor.CGColor;
        self.shapeLayer.fillColor = [UIColor whiteColor].CGColor;

        self.gradient.colors = self.colors;
        self.gradient.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.6]];
    }

    
}

- (void) start {
    [super start];
}

- (void) stop {
    [super stop];
}

- (void) newAudioDataWasReceived:(float *)buffer withLength:(int)length {

    if(length == 0) return [self.audioSource restartConnection];;

    float centerY = (self.frame.size.height / 2) + self.yOffset; 

    // Create path
    UIBezierPath *path = [UIBezierPath bezierPath];

    // Get point x width
    float step = self.frame.size.width / self.pointNumber;

    [path moveToPoint:CGPointMake(0, centerY)];

    float points[64] = {0};
    int compressionRate = length / self.pointNumber;
    for(int i = 0; i < self.pointNumber; i++) {
        points[i] = buffer[i * compressionRate];
    }

    for(int i = 1; i < self.pointNumber; i++) {
        float x1 = (i * step) + self.xOffset;
        float x0 = ((i - 1) * step) + self.xOffset;
        float y1 = self.pointSensitivity * points[i] + centerY;
        float y0 = self.pointSensitivity * points[i - 1] + centerY;

        y1 = y1 > self.frame.size.height ? self.frame.size.height : y1;
        y0 = y0 > self.frame.size.height ? self.frame.size.height : y0;


        CGPoint p1 = CGPointMake(x0, y0);
        CGPoint p2 = CGPointMake(x1, y1);
        CGPoint midPoint = midPointForPoints(p1, p2);

        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
    }


    if(!self.onlyLine) {
        [path addLineToPoint:CGPointMake(self.frame.size.width, centerY)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(self.xOffset, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(self.xOffset, centerY)];
    }


    dispatch_async(dispatch_get_main_queue(), ^{
        self.shapeLayer.path = path.CGPath;
    });
}
@end