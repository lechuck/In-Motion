//
//  CalibrationViewController.h
//  InMotion
//
//  Created by Matías Pacelli on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalibrationViewController : UIViewController <UIAccelerometerDelegate>{

    IBOutlet UILabel *statusCalibrationStopped;
    IBOutlet UILabel *statusCalibrationWalking;
    IBOutlet UILabel *statusCalibrationRunning;
    IBOutlet UILabel *statusCalibrationBike;
    IBOutlet UILabel *statusCalibrationCar;
    IBOutlet UILabel *statusCalibrationBus;
    
    IBOutlet UIButton *btnStopped;
    IBOutlet UIButton *btnWalking;
    IBOutlet UIButton *btnRunning;
    IBOutlet UIButton *btnBike;
    IBOutlet UIButton *btnCar;
    IBOutlet UIButton *btnBus;
    
    IBOutlet UIButton *dropTable;

    

    double calibratedAvgs[6], calibratedDeviations[6];
    
    NSNumber *calibratedAvgStopped;
    NSNumber *calibratedAvgWalking;
    NSNumber *calibratedAvgRunning;
    NSNumber *calibratedAvgBike;
    NSNumber *calibratedAvgCar;
    NSNumber *calibratedAvgBus;


}

@property(nonatomic, retain) IBOutlet UILabel *statusCalibrationStopped;
@property(nonatomic, retain) IBOutlet UILabel *statusCalibrationWalking;
@property(nonatomic, retain) IBOutlet UILabel *statusCalibrationRunning;
@property(nonatomic, retain) IBOutlet UILabel *statusCalibrationBike;
@property(nonatomic, retain) IBOutlet UILabel *statusCalibrationCar;
@property(nonatomic, retain) IBOutlet UILabel *statusCalibrationBus;


@property(nonatomic, retain) NSNumber *calibratedAvgStopped;
@property(nonatomic, retain) NSNumber *calibratedAvgWalking;
@property(nonatomic, retain) NSNumber *calibratedAvgRunning;
@property(nonatomic, retain) NSNumber *calibratedAvgBike;
@property(nonatomic, retain) NSNumber *calibratedAvgCar;
@property(nonatomic, retain) NSNumber *calibratedAvgBus;

@property(nonatomic, retain) UIButton *btnStopped;
@property(nonatomic, retain) UIButton *btnWalking;
@property(nonatomic, retain) UIButton *btnRunning;
@property(nonatomic, retain) UIButton *btnBike;
@property(nonatomic, retain) UIButton *btnCar;
@property(nonatomic, retain) UIButton *btnBus;
@property(nonatomic, retain) UIButton *dropTable;


- (IBAction)calibrateStopped:(id)sender;
- (IBAction)calibrateWalking:(id)sender;
- (IBAction)calibrateRunning:(id)sender;
- (IBAction)calibrateBike:(id)sender;
- (IBAction)calibrateCar:(id)sender;
- (IBAction)calibrateBus:(id)sender;

- (IBAction)dropTable:(id)sender;


//-(NSNumber *)setStopped;

@end
