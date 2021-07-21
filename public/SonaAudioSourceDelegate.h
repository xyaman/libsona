@protocol SonaAudioSourceDelegate
@property(nonatomic) float refreshRateInSeconds;
- (void) newAudioDataWasReceived:(float*)data withLength:(int)length;
@end