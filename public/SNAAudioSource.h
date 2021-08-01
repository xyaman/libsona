#import <UIKit/UIKit.h>
#import <arpa/inet.h>

// Local
#import "SNAAudioSourceDelegate.h"

#define SA struct sockaddr
#define ASSPORT 44333
#define MAX_BUFFER_SIZE 16384



@interface SNAAudioSource : NSObject {
	// Socket related
	struct sockaddr_in _addr;
	BOOL _isConnected;

	// new
	float *_buffer;

}

@property (nonatomic, weak) id <SNAAudioSourceDelegate> delegate;

- (void) startConnection;
- (void) stopConnection;
@end