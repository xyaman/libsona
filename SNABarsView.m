#import "public/SNABarsView.h"

#define MIN_HZ 20
#define MAX_HZ 20000

@interface SNABarsView ()
@property(nonatomic, retain) NSMutableArray *colors;
@end

@implementation SNABarsView

- (instancetype) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];

    self.colors = [NSMutableArray arrayWithCapacity:4];
    self.colors[0] = (id)self.pointColor.CGColor;
    self.colors[1] = self.colors[0];
    self.coloringStyle = SNAColoringStyleSolid;

    return self;
}

- (void) renderPoints {

    // Remove old layers
    for(int i = self.layer.sublayers.count - 1; i >=0; i--) {
        CAGradientLayer *bar = self.layer.sublayers[i];
        [bar removeFromSuperlayer];
    }


    // Calculate offset to center bars
    float leftOffset = (self.frame.size.width - (self.pointSpacing + self.pointWidth) * self.pointNumber - self.pointSpacing) / 2;
    leftOffset += self.xOffset;

    for(int i = 0; i < self.pointNumber; i++) {
        CAGradientLayer *bar = [CAGradientLayer layer];

        bar.frame = CGRectMake(leftOffset + i * (self.pointWidth + self.pointSpacing), self.frame.size.height, self.pointWidth, 0);
        bar.startPoint = CGPointMake(0.5, 1.0);
        bar.endPoint = CGPointMake(0.5, 0.0);
        bar.colors = self.colors;

        bar.cornerRadius = self.pointRadius;
        [self.layer addSublayer:bar];
    }
}

- (void) updateColors {

    // Define colours depending of colouring style
    if(self.coloringStyle == SNAColoringStyleFull) {

        self.colors[0] = self.pointSecondaryColor ? (id)self.pointSecondaryColor.CGColor : (id)self.pointColor.CGColor;
        self.colors[1] = self.colors[0];

        for(int i = 0; i < self.layer.sublayers.count; i++) {
            CAGradientLayer *bar = self.layer.sublayers[i];
            bar.colors = self.colors;
            
        }

    } else if(self.coloringStyle == SNAColoringStyleSolid) {
        self.colors[0] = (id)self.pointColor.CGColor;
        self.colors[1] = self.colors[0];

        self.colors[2] = self.pointSecondaryColor ? (id)self.pointSecondaryColor.CGColor : (id)self.pointColor.CGColor;
        self.colors[3] = self.colors[2];

        for(int i = 0; i < self.layer.sublayers.count; i++) {
            CAGradientLayer *bar = self.layer.sublayers[i];
            bar.colors = self.colors;
            bar.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.6], [NSNumber numberWithFloat:0.6], [NSNumber numberWithFloat:1.0]];
        }
   
    } else if(self.coloringStyle == SNAColoringStyleGradient) {

        self.colors[0] = (id)self.pointColor.CGColor;
        self.colors[1] = self.pointSecondaryColor ? (id)self.pointSecondaryColor.CGColor : (id)self.pointColor.CGColor;

        for(int i = 0; i < self.layer.sublayers.count; i++) {
            CAGradientLayer *bar = self.layer.sublayers[i];
            bar.colors = self.colors;
            bar.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.6]];
        }

    }   
}

- (void) start {
    [super start];
    [self renderPoints];

    // Start audio connection
    [self.audioSource startConnection];
}

- (void) stop {
    [super stop];
    [self.audioSource stopConnection];
}


-(void) resume {
    if (!self.isMusicPlaying) return;

    [self.audioSource startConnection];
}

-(void) pause {
    if (!self.isMusicPlaying) return;

    [self.audioSource stopConnection];
}

-(void) newAudioDataWasReceived:(float *)buffer withLength:(int)length {
    
    // We want fft
    [self.audioProcessor fromRawToFFT:buffer withLength:length];
}

- (void) newAudioDataWasProcessed:(float *)frames withLength:(int)length {

    if(self.layer.sublayers.count != self.pointNumber || self.pointNumber == 0) return;

    // We want bar frequency visualizer

    // I don't know too much about audio visualization, but I will use a kind of octave bands.
    // with max capacity 10.
    float octaves[10] = {0};
    float offset = 10 / self.pointNumber;
    float freq = 0;
    float binWidth = MAX_HZ / length;

    int band = 0;
    float bandEnd = MIN_HZ * pow(2, 1);

    for(int i = 0; i < length; i++) {
        freq = i > 0 ? i * binWidth : MIN_HZ;

        octaves[band] += frames[i];

        if(freq > offset * bandEnd) {
            band += 1;
            bandEnd = MIN_HZ * pow(2, band + 1);
        }
    }


    // Render new bars
    for(int i = 0; i < self.pointNumber; i++) {
        CALayer *bar = self.layer.sublayers[i];
        float heightMultiplier = octaves[i] * self.pointSensitivity > 0.95 ? 0.95 : octaves[i] * self.pointSensitivity;

        dispatch_async(dispatch_get_main_queue(), ^{
            // bar.colors =  [NSArray arrayWithObjects:(__bridge id)primaryColor, (__bridge id)secondaryColor, nil];
            // bar.colors =  [NSArray arrayWithObjects:(__bridge id)primaryColor, (__bridge id)primaryColor, (__bridge id)secondaryColor, (__bridge id)secondaryColor, nil];
            // bar.colors = self.colors;
            bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, -fabs(heightMultiplier * self.frame.size.height));
        });
    }   
}

@end