#import "public/SonaWavesView.h"

#define MIN_HZ 20
#define MAX_HZ 20000

@interface SonaWavesView ()
@end

@implementation SonaWavesView
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

	int POINTS = 10;
	
	float height = 6;
	float phase = 0;

	float centerY = self.frame.size.height / 2;	

	UIBezierPath *path = [UIBezierPath bezierPath];
	float step = self.frame.size.width / POINTS;

	[path moveToPoint:CGPointMake(0, centerY)];

	float points[10] = {0};
	for(int i = 0; i < POINTS; i++) {
		points[i] = buffer[i * (length/POINTS)];
	}

	for(int i = 0; i < POINTS; i++) {
		float x = i * step;
		float y = height * sin(points[i] + phase) + centerY;
		[path addLineToPoint:CGPointMake(x, y)];
	}

	// [path closePath];
	dispatch_async(dispatch_get_main_queue(), ^{
		self.shapeLayer.path = path.CGPath;
	});
}

- (void) newAudioDataWasProcessed:(float *)frames withLength:(int)length {
}

@end