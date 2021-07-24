#include "public/SonaView.h"

@interface SonaView ()
@end

@implementation SonaView
- (instancetype) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	// Just defaults, but necessary values in case the user doesn't add them
	self.refreshRateInSeconds = 0.1f;
	self.pointSensitivity = 1.0f;
	self.pointAirpodsBoost = 1.0f;
	self.pointRadius = 1.0f;
	self.pointSpacing = 2.0f;
	self.pointWidth = 3.6f;
	self.pointNumber = 4;

	self.pointColor = [UIColor whiteColor];
	self.isMusicPlaying = NO;

	self.audioSource = [[SonaAudioSource alloc] init];
	self.audioSource.delegate = self;

	self.audioProcessor = [[SonaAudioProcessor alloc] init];
	self.audioProcessor.delegate = self;

	return self;
}

- (void) start {
	self.isMusicPlaying = YES;
}

- (void) stop {
	self.isMusicPlaying = NO;
}


- (void) hideAndShowParentFor2Sec {
	NSLog(@"[libsona] tappp");
	if(self.parent) {
		// Animate dissapear
		[UIView animateWithDuration:0.5
			animations:^{self.alpha = 0.0;}
			completion:^(BOOL finished){self.parent.hidden = NO;}
		];

		// Wait 2 seconds and then show again
		[NSTimer scheduledTimerWithTimeInterval:2.5 repeats:NO block:^(NSTimer *timer) {
			self.alpha = 1.0;
			if(self.isMusicPlaying) self.parent.hidden = YES;
		}];
	}
}

-(void) newAudioDataWasProcessed:(float *)data withLength:(int)length {
}

- (void) newAudioDataWasReceived:(float*)data withLength:(int)length {
}
@end