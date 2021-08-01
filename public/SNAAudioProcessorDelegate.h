@protocol SNAAudioProcessorDelegate
@property(nonatomic) float pointAirpodsBoost;
- (void) newAudioDataWasProcessed:(float*)data withLength:(int)length;
@end