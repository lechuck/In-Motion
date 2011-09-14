//
//  InMotionViewController.h
//  InMotion
//
//  Created by Tony Karppinen on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InMotionViewController : UIViewController <UIAccelerometerDelegate>{

    IBOutlet UISwitch *accelerometerStatus;
    IBOutlet UISwitch *gpsStatus;

    IBOutlet UILabel *accelX;
    IBOutlet UILabel *accelY;
    IBOutlet UILabel *accelZ;
    
    IBOutlet UILabel *sum;
    IBOutlet UILabel *max;
    

}


@property (nonatomic, retain) IBOutlet UISwitch *accelerometerStatus;
@property (nonatomic, retain) IBOutlet UISwitch *gpsStatus;

@property (nonatomic, retain) IBOutlet UILabel *accelX;
@property (nonatomic, retain) IBOutlet UILabel *accelY;
@property (nonatomic, retain) IBOutlet UILabel *accelZ;
@property (nonatomic, retain) IBOutlet UILabel *sum;
@property (nonatomic, retain) IBOutlet UILabel *max;


- (IBAction)statusAccelerometer:(id)sender;


@end
