#import "MicBlowViewController.h"

@implementation MicBlowViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
		
	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
		
	NSError *error;
		
	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
		
	if (recorder) {
		[recorder prepareToRecord];
		recorder.meteringEnabled = YES;
		[recorder record];
		levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
	} else
		NSLog([error description]);	
}


- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];

	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;	
	
	if (lowPassResults < 0.95)
		NSLog(@"Mic blow detected");
}


- (void)dealloc {
	[levelTimer release];
	[recorder release];
    [super dealloc];
}

@end
