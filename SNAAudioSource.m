#import "public/SNAAudioSource.h"

@interface SNAAudioSource ()
@end

@implementation SNAAudioSource

- (instancetype) init {
	self = [super init];

	// Socket initialization related
	_isConnected = NO;	
	
	// Host addr	
	_addr.sin_family = AF_INET;
	_addr.sin_port = htons(ASSPORT);
	_addr.sin_addr.s_addr = inet_addr("127.0.0.1");

	// new
	_buffer = (float *)malloc(MAX_BUFFER_SIZE);

	return self;
}

// In an implementation of dealloc, do not invoke the superclass’s 
// implementation. You should try to avoid managing the lifetime of 
// limited resources such as file descriptors using dealloc.
-(void) dealloc {
	free(_buffer);
}

- (void) startConnection {
	if(_isConnected) return;
	_isConnected = YES;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{	
	
	int sockfd = -1;

	while(_isConnected) {

		// Create socket
		sockfd = socket(AF_INET, SOCK_STREAM, 0);
		if (sockfd == -1) {
			NSLog(@"[libsona] Can't create socket");
			usleep(500000); // Half second
			continue;
		}

		// Connect client to host
		int ok = connect(sockfd, (SA*)&_addr, sizeof(_addr));
		if(ok < 0) {
			NSLog(@"[libsona] Socket can't connect to host");
			usleep(500000); // Half second
			continue;
		}

		// Now we are connected
		NSLog(@"[libsona] Socket is not connected");


    	// Buffer related
		int hello = 1;
    	float dummyData[4]; // Sometimes socket receives a float
    	UInt32 bufferSize = 0;
    	int bufferLength = 0; // bufferSize / sizeof(float)
    	// float buffer[MAX_BUFFER_SIZE];


    	while(_isConnected) {
    		// Send initial message.
			int wlen = write(sockfd, &hello, sizeof(hello));
			if(wlen < 0) { // We've lost the connection
				close(sockfd);
				break; 
			}

			// Response -> data bufferSize with size of UInt32.
			int rlen = read(sockfd, &bufferSize, sizeof(bufferSize));
			if(rlen < 0) { // We've lost the connection
				close(sockfd);
				break; 
			}

			// This shouldn't happens but sometimes happens
			if(bufferSize > MAX_BUFFER_SIZE || bufferSize < sizeof(float)) {
				close(sockfd);
				break;
			}


			// When no data is available, the host sends ONE float.
			if(bufferSize == sizeof(float)) {
				rlen = read(sockfd, dummyData, bufferSize);
				if (rlen < 0) {
					close(sockfd);
					break;
				}
				continue;
			}

			

			// If we are still here, it means now we have REAL data audio :)
			rlen = read(sockfd, _buffer, bufferSize);

			if(rlen < 0) {
				close(sockfd);
				break;
			}

			bufferLength = bufferSize / sizeof(float);

			// Now we process the audio data

			// we need length, because when using Airpods, the length is 256
			// int length = [self processRawAudio:_buffer withLength:bufferLength];	

			// Now we send to our delegate :D
			[self.delegate newAudioDataWasReceived:_buffer withLength:bufferLength];

			// Zzz
			usleep(self.delegate.refreshRateInSeconds * 1000000);

	    	}
		}

		// Close the socket
		close(sockfd);
	});
}

-(void) stopConnection {
	_isConnected = NO;
}
@end