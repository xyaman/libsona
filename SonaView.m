#include "public/SonaView.h"

// Used for playing app
@interface SBApplication : NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier;                                                                                     //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)nowPlayingApplication;
@end

@interface UIApplication ()
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

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
	self.hidden = NO;
	if(self.parent) self.parent.hidden = YES;
}

- (void) resume {
	if(self.isMusicPlaying) [self start];
}

- (void) stop {
	self.isMusicPlaying = NO;
	self.hidden = YES;
	if(self.parent) self.parent.hidden = NO;
}

- (void) pause {
	[self stop];
	self.isMusicPlaying = YES;
}


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

-(void) newAudioDataWasProcessed:(float *)data withLength:(int)length {
}

- (void) newAudioDataWasReceived:(float*)data withLength:(int)length {
}
@end