#import <UIKit/UIKit.h>

#import "SonaAudioSource.h"
#import "SonaAudioProcessor.h"

/// The SonaView class in Sona provides the most basic visualyzer view.
@interface SonaView : UIView <SonaAudioSourceDelegate, SonaAudioProcessorDelegate>

@property(nonatomic, retain) SonaAudioSource *audioSource;
@property(nonatomic, retain) SonaAudioProcessor *audioProcessor;
@property(nonatomic, retain) UIView *parent;

@property(nonatomic) float refreshRateInSeconds;
@property(nonatomic) float pointSensitivity;
@property(nonatomic) float pointAirpodsBoost;
@property(nonatomic) float pointRadius;
@property(nonatomic) float pointSpacing;
@property(nonatomic) float pointWidth;
@property(nonatomic) int pointNumber;
@property(nonatomic) UIColor *pointColor;

// Remove
@property(nonatomic) BOOL isMusicPlaying;

// Testing
- (void) setConstraints:(CGRect)frame;

- (void) start;
- (void) stop;

// - (void) resume;
// - (void) pause;
@end