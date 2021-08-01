#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "SNAAudioSource.h"
#import "SNAAudioProcessor.h"

/// The SNAView class in Sona provides the most basic visualyzer view.
/// By it's own it does nothing.
@interface SNAView : UIView <SNAAudioSourceDelegate, SNAAudioProcessorDelegate>

@property(nonatomic, retain) SNAAudioSource *audioSource;
@property(nonatomic, retain) SNAAudioProcessor *audioProcessor;
@property(nonatomic, retain) UIView *parent;

@property(nonatomic) float refreshRateInSeconds;
@property(nonatomic) float pointSensitivity;
@property(nonatomic) float pointAirpodsBoost;
@property(nonatomic) float pointRadius;
@property(nonatomic) float pointSpacing;
@property(nonatomic) float pointWidth;
@property(nonatomic) int pointNumber;
@property(nonatomic) UIColor *pointColor;
@property(nonatomic) UIColor *pointSecondaryColor;

// Positioning
@property(nonatomic) float xOffset;
@property(nonatomic) float yOffset;

@property(nonatomic) BOOL isMusicPlaying;

- (void) start;
- (void) stop;

// Utils
- (void) hideAndShowParentFor2Sec;
- (void) openCurrentPlayingApp;

- (void) resume;
- (void) pause;

@end


