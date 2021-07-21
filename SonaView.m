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
}

- (void) stop {
}

- (void) setConstraints:(CGRect)frame {
	if(!self.superview) return;

	[self.leftAnchor constraintEqualToAnchor:self.superview.leftAnchor constant:frame.origin.x].active = YES; // Left
	[self.topAnchor constraintEqualToAnchor:self.superview.topAnchor].active = YES; // Top
	[self.widthAnchor constraintEqualToConstant:frame.size.width].active = YES; // Width
	[self.heightAnchor constraintEqualToConstant:frame.size.height].active = YES; // Height
}

// - (void) resume {
// }

// - (void) pause {
// }

-(void) newAudioDataWasProcessed:(float *)data withLength:(int)length {
}

- (void) newAudioDataWasReceived:(float*)data withLength:(int)length {
}
@end