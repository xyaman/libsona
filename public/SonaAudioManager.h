#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <arpa/inet.h>

// Local
#import "SonaAudioManagerDelegate.h"

#define SA struct sockaddr
#define ASSPORT 44333
#define MAX_BUFFER_SIZE 16384
#define FFT_LENGTH 1024
#define FFT_AIRPODS_LENGTH 256


@interface SonaAudioManager : NSObject {
	// Socket related
	struct sockaddr_in _addr;
	BOOL _isConnected;

	// Audio relate
	struct vDSP_DFT_SetupStruct *_fftSetup;
	struct vDSP_DFT_SetupStruct *_fftAirpodsSetup; // Airpods Support

	struct DSPSplitComplex _complex;
	float *_realIn;
	float *_imagIn;
	float *_realOut;
	float *_imagOut;
	float *_magnitudes;
	float _scalingFactor;

}

@property (nonatomic, weak) id <SonaAudioManagerDelegate> delegate;

- (void) startConnection;
- (void) stopConnection;
- (int) processRawAudio:(float*)buffer withLength:(int)bufferLength;
- (int) processAirpodsAudio:(float*)buffer;
@end