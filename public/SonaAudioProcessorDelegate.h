@protocol SonaAudioProcessorDelegate
@property(nonatomic) float pointAirpodsBoost;
- (void) newAudioDataWasProcessed:(float*)data withLength:(int)length;
@end