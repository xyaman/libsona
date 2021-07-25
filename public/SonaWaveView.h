#import "SonaView.h"

@interface SonaWaveView : SonaView
@property(nonatomic, retain) CAShapeLayer *shapeLayer;
@property(nonatomic) float waveYOffset;
@property(nonatomic) BOOL onlyLine;
@end