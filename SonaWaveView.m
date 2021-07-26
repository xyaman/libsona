#import "public/SonaWaveView.h"

#define MIN_HZ 20
#define MAX_HZ 20000

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

@interface SonaWaveView ()
@end

@implementation SonaWaveView
-(id) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];

    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.strokeColor = self.pointColor.CGColor;
    self.shapeLayer.fillColor = self.pointSecondaryColor.CGColor;
    self.shapeLayer.lineWidth = 1.5f;
    [self.layer addSublayer:self.shapeLayer];

    return self;
}

-(void) start {
    [super start];

    // Start audio connection
    [self.audioSource startConnection];
}

-(void) stop {
    [super stop];
    [self.audioSource stopConnection];
}

-(void) newAudioDataWasReceived:(float *)buffer withLength:(int)length {

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
        self.shapeLayer.strokeColor = self.pointColor.CGColor;
        self.shapeLayer.fillColor = self.pointSecondaryColor ? self.pointSecondaryColor.CGColor : [UIColor clearColor].CGColor;
        self.shapeLayer.path = path.CGPath;
    });
}
@end