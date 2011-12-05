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

}


@property (nonatomic, retain) IBOutlet UISwitch *accelerometerStatus;
@property (nonatomic, retain) IBOutlet UILabel *status;

// Location stuff
@property (nonatomic, retain) CoreLocationController *CLController;
- (bool)busStopNearby:(NSInteger) meters;
- (void)updateReittiopasData:(NSArray *)stopsArray;

- (IBAction)doCalibrate:(id)sender;

- (IBAction)statusAccelerometer:(id)sender;

-(void)writeBD;


@end
