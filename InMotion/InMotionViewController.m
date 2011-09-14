//
//  InMotionViewController.m
//  InMotion
//
//  Created by Tony Karppinen on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InMotionViewController.h"

@implementation InMotionViewController

@synthesize accelerometerStatus, gpsStatus;
@synthesize accelX, accelY, accelZ, sum, max;

    double maximo = 0.0;

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration{

    
    double const kThreshold = 2.0;
    if (   fabsf(acceleration.x) > kThreshold
        || fabsf(acceleration.y) > kThreshold
        || fabsf(acceleration.z) > kThreshold) {
        NSLog(@"Hey, stop shaking me!");
    }
    

    NSString *stringAccelX = [NSString stringWithFormat:@"%f", fabsf(acceleration.x)];
    [accelX setText:stringAccelX];
    NSString *stringAccelY = [NSString stringWithFormat:@"%f", fabsf(acceleration.y)];
    [accelY setText:stringAccelY];
    NSString *stringAccelZ = [NSString stringWithFormat:@"%f", fabsf(acceleration.z)];
    [accelZ setText:stringAccelZ];
    
    double sumatorio= fabsf(acceleration.x)+fabsf(acceleration.y)+fabsf(acceleration.z);
    
    NSString *suma = [NSString stringWithFormat:@"%f",sumatorio ];
    [sum setText:suma];

    if(sumatorio>maximo)
        maximo=sumatorio;
    


}

- (void)startAccelerometer {
    NSLog(@"accelerometer started!");
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = self;
    accelerometer.updateInterval = 0.25;
}

- (void)stopAccelerometer {
    
    UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = nil;
    NSLog(@"accelerometer stopped!");
    
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
- (void)viewDidAppear:(BOOL)animated {

    
    [gpsStatus setOn:FALSE];
    [accelerometerStatus setOn:FALSE];
    [gpsStatus setEnabled:FALSE];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopAccelerometer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)statusAccelerometer:(id)sender{

    if([accelerometerStatus isOn]){
        NSLog(@"enabled!");
        [self startAccelerometer];
    }
    
    else{
        NSLog(@"disabled!");
        [self stopAccelerometer];
        [accelX setText:@"OFF"];
        [accelY setText:@"OFF"];
        [accelZ setText:@"OFF"];
        NSString *stringmax = [NSString stringWithFormat:@"%f",maximo ];
        [max setText:stringmax];

    }
    
    
}



@end
