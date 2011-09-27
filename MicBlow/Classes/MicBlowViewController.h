#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface MicBlowViewController : UIViewController {
	AVAudioRecorder *recorder;
	NSTimer *levelTimer;
	double lowPassResults;
}

- (void)levelTimerCallback:(NSTimer *)timer;

@end

