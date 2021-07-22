#import "public/SonaLineView.h"

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

@interface SonaLineView ()
@end

@implementation SonaLineView
-(void) start {

	if(!self.shapeLayer) {
		self.shapeLayer = [CAShapeLayer layer];
		self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
		self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
		// self.shapeLayer.lineWidth = self.pointWidth;
		self.shapeLayer.lineWidth = 1.5f;

		self.path = [UIBezierPath bezierPath];
		// self.shapeLayer.frame = self.layer.frame;

		[self.layer addSublayer:self.shapeLayer];
	}

	// Start audio connection
	self.isMusicPlaying = YES;
	[self.audioSource startConnection];
}

-(void) stop {
	self.isMusicPlaying = NO;
	[self.audioSource stopConnection];
}

-(void) newAudioDataWasReceived:(float *)buffer withLength:(int)length {

	int POINTS = 16;
	// int POINTS = 10;
	
	float height = 4;
	// float phase = 0;

	float centerY = self.frame.size.height / 2;	

	UIBezierPath *path = [UIBezierPath bezierPath];
	float step = self.frame.size.width / POINTS;

	[path moveToPoint:CGPointMake(0, centerY)];

	float points[16] = {0};
	for(int i = 0; i < POINTS; i++) {
		points[i] = buffer[i * (length/POINTS)];
	}

	for(int i = 1; i < POINTS; i++) {

		float x1 = i * step;
		float x0 = (i-1) * step;
		float y1 = height * points[i] + centerY;
		float y0 = height * points[i - 1] + centerY;


		CGPoint p1 = CGPointMake(x0, y0);
		CGPoint p2 = CGPointMake(x1, y1);
		CGPoint midPoint = midPointForPoints(p1, p2);

		[path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];

		// Fix this
		if (i < POINTS - 1) {
 			[path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
		} else {
			CGPoint endPoint = CGPointMake(self.frame.size.width, centerY);
			midPoint = midPointForPoints(p2, endPoint);
			[path addQuadCurveToPoint:endPoint controlPoint:controlPointForPoints(midPoint, endPoint)];
		}
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		self.shapeLayer.strokeColor = self.pointColor.CGColor;
		self.shapeLayer.path = path.CGPath;
	});
}
@end