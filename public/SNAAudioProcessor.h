#import <Accelerate/Accelerate.h>
#import "SNAAudioProcessorDelegate.h"


#define FFT_LENGTH 1024
#define FFT_AIRPODS_LENGTH 256

@interface SNAAudioProcessor : NSObject {
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

@property (nonatomic, weak) id <SNAAudioProcessorDelegate> delegate;

- (void) fromRawToFFT:(float *)frames withLength:(int)length;
@end