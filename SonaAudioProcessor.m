#include "public/SonaAudioProcessor.h"

@interface SonaAudioProcessor ()
@end

@implementation SonaAudioProcessor

- (instancetype) init {
	self = [super init];

	// Audio processing related	
	_fftSetup = vDSP_DFT_zop_CreateSetup(NULL, FFT_LENGTH, vDSP_DFT_FORWARD);
	_fftAirpodsSetup = vDSP_DFT_zop_CreateSetup(NULL, FFT_AIRPODS_LENGTH, vDSP_DFT_FORWARD);

	_realIn = (float *)calloc(FFT_LENGTH, sizeof(float));
	_imagIn = (float *)calloc(FFT_LENGTH, sizeof(float));
	_realOut = (float *)calloc(FFT_LENGTH, sizeof(float));
	_imagOut = (float *)calloc(FFT_LENGTH, sizeof(float));

	_magnitudes = (float *)calloc(FFT_LENGTH/2, sizeof(float));
	_scalingFactor = 5.0f / 1024.0f;

	_complex.realp = _realOut;
	_complex.imagp = _imagOut;	


	return self;
}

- (void) dealloc {
	vDSP_DFT_DestroySetup(_fftSetup);
	vDSP_DFT_DestroySetup(_fftAirpodsSetup);

	free(_realIn);
	free(_imagIn);
	free(_realOut);
	free(_imagOut);
	free(_magnitudes);
}

- (void) fromRawToFFT:(float *)frames withLength:(int)length {
	// First, we compress the audio, only if bigger than our fft length
	// No effect if compression rate is 1
	int compressionRate = length / FFT_LENGTH;

	// Copy the buffer to our allocated array
	for(int i = 0; i < FFT_LENGTH; i++) {
		_realIn[i] = frames[i * compressionRate];
	}

	// Execute our Discrete Fourier Transformation to get the audio frequency	
	vDSP_DFT_Execute(_fftSetup, _realIn, _imagIn, _realOut, _imagOut);

	// Calculate the absolute value of the complex number
	// Remember: complex.realp = _realOut, complex.imagp = _imagOut
	// Here we get data / 2;
	vDSP_zvabs(&_complex, 1, _magnitudes, 1, FFT_LENGTH / 2);

	// Now we normalize the magnitudes a little	
	vDSP_vsmul(_magnitudes, 1, &_scalingFactor, _magnitudes, 1, FFT_LENGTH / 2);		

	[self.delegate newAudioDataWasProcessed:_magnitudes withLength:FFT_LENGTH / 2];
}

- (void) fromRawToFFTAirpods:(float *)frames withLength:(int)length {

	float newScalingFactor = _scalingFactor * self.delegate.pointAirpodsBoost;

	// Copy the buffer to our allocated array
	for(int i = 0; i < FFT_AIRPODS_LENGTH; i++) {
		_realIn[i] = frames[i];
	}

	// Execute our Discrete Fourier Transformation to get the audio frequency	
	vDSP_DFT_Execute(_fftAirpodsSetup, _realIn, _imagIn, _realOut, _imagOut);

	// Calculate the absolute value of the complex number
	// Remember: complex.realp = _realOut, complex.imagp = _imagOut
	// Here we get data / 2;
	vDSP_zvabs(&_complex, 1, _magnitudes, 1, FFT_AIRPODS_LENGTH / 2);

	// Now we normalize the magnitudes a little	
	vDSP_vsmul(_magnitudes, 1, &newScalingFactor, _magnitudes, 1, FFT_AIRPODS_LENGTH / 2);

	[self.delegate newAudioDataWasProcessed:_magnitudes withLength:FFT_AIRPODS_LENGTH / 2];
}
@end