//
//  InMotionViewController.h
//  InMotion
//
//  Created by Tony Karppinen on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "CalibrationViewController.h"
#import "CoreLocationController.h"


@interface InMotionViewController : UIViewController <UIAccelerometerDelegate>{

    IBOutlet UISwitch *accelerometerStatus;
    IBOutlet UILabel *status;
    IBOutlet UIButton *calibrate;
    IBOutlet UILabel *debugLabel;
    IBOutlet UILabel *debugLabelMeters;    
    IBOutlet UILabel *debugLabelCalled;    
}


@property (nonatomic, retain) IBOutlet UISwitch *accelerometerStatus;
@property (nonatomic, retain) IBOutlet UILabel *status;

// Location stuff
@property (nonatomic, retain) CoreLocationController *CLController;


// Debug stuff
@property (nonatomic, retain) IBOutlet UILabel *debugLabel;
@property (nonatomic, retain) IBOutlet UILabel *debugLabelMeters;
@property (nonatomic, retain) IBOutlet UILabel *debugLabelCalled;


- (bool)busStopNearby:(NSInteger) meters;
- (bool)busStopIn:(NSInteger) meters fromLocation:(CLLocation*)searchFromLocation;
- (void)updateReittiopasData:(NSArray *)stopsArray;
- (void)calculateBusProbability:(NSTimer *) theTimer;




- (IBAction)doCalibrate:(id)sender;
- (IBAction)statusAccelerometer:(id)sender;
-(void)writeBD;


@end
