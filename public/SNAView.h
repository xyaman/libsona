#ifndef SNAVIEW
#define SNAVIEW

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "SNAAudioSource.h"
#import "SNAAudioProcessor.h"


typedef NS_ENUM(NSInteger, SNAColoringStyle) {
	SNAColoringStyleFull, // Just one color
	SNAColoringStyleSolid, // 2 colors but clearly separated
	SNAColoringStyleGradient // Gradient between 2 colours
};


/// The SNAView class in Sona provides the most basic visualyzer view.
/// By it's own it does nothing.
@interface SNAView : UIView <SNAAudioSourceDelegate, SNAAudioProcessorDelegate>

@property(nonatomic, retain) SNAAudioSource *audioSource;
@property(nonatomic, retain) SNAAudioProcessor *audioProcessor;
@property(nonatomic, retain) UIView *parent;

// Style
@property(nonatomic) NSInteger coloringStyle;
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

- (void) renderPoints;
- (void) updateColors;

- (void) start;
- (void) stop;

// Utils
- (void) hideAndShowParentFor2Sec;
- (void) openCurrentPlayingApp;

- (void) resume;
- (void) pause;

@end
#endif