@protocol SonaAudioManagerDelegate
@property(nonatomic) float refreshRateInSeconds;
@property(nonatomic) float pointAirpodsBoost;
- (void) newAudioDataWasProcessed:(float*)data withLength:(int)length;
@end