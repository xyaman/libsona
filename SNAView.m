#include "public/SNAView.h"

// Used for playing app
@interface SBApplication : NSObject
@property (nonatomic, readonly) NSString * bundleIdentifier;                                                                                     //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
@end

@interface UIApplication ()
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

@interface SNAView ()
@end

@implementation SNAView
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
	self.pointSecondaryColor = nil;
	self.isMusicPlaying = NO;

	self.audioSource = [[SNAAudioSource alloc] init];
	self.audioSource.delegate = self;

	self.audioProcessor = [[SNAAudioProcessor alloc] init];
	self.audioProcessor.delegate = self;

	return self;
}

- (void) start {
    [self.audioSource startConnection];
	self.isMusicPlaying = YES;
	self.hidden = NO;
	if(self.parent) self.parent.hidden = YES;
}

- (void) resume {
	if(self.isMusicPlaying) [self start];
}

- (void) stop {
	[self.audioSource stopConnection];
	self.isMusicPlaying = NO;
	self.hidden = YES;
	if(self.parent) self.parent.hidden = NO;
}

- (void) pause {
	if(self.isMusicPlaying) {
		[self stop];
		self.isMusicPlaying = YES;
	} else {
		[self stop];
	}
}

- (void) renderPoints {}
- (void) updateColors {}

- (void) hideAndShowParentFor2Sec {
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

- (void) openCurrentPlayingApp {
	SBApplication *nowPlayingApp = [[objc_getClass("SBMediaController") sharedInstance] nowPlayingApplication];
	if(nowPlayingApp) {
		[[UIApplication sharedApplication] launchApplicationWithIdentifier:nowPlayingApp.bundleIdentifier suspended:NO];
	}
}

// Audio delegate methods
- (void) newAudioDataWasProcessed:(float *)data withLength:(int)length {}
- (void) newAudioDataWasReceived:(float*)data withLength:(int)length {}
@end