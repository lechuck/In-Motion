//
//  CalibrationViewController.m
//  InMotion
//
//  Created by Matías Pacelli on 29/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import "CalibrationViewController.h"
#import <sqlite3.h>

#define CALIBRATION_SIZE 10

#define VECTOR_SIZE 16

@implementation CalibrationViewController

@synthesize statusCalibrationStopped, statusCalibrationWalking, statusCalibrationRunning, statusCalibrationBike, statusCalibrationCar, statusCalibrationBus;

@synthesize calibratedAvgStopped,calibratedAvgWalking,calibratedAvgRunning,calibratedAvgBike,calibratedAvgCar,calibratedAvgBus;

@synthesize btnStopped, btnWalking,btnRunning,btnBike,btnCar,btnBus, dropTable;


//@synthesize prueba;
sqlite3 *database2;
NSString *databasePath2;

NSString *transportationMode;



double v11[VECTOR_SIZE], v22[VECTOR_SIZE];
double calibrationVector[CALIBRATION_SIZE-1];

double avg11,avg22,summation2, stdDeviation, avgsummation2=0.0;


int counter2=0;
int current_vector2=1;
bool first_time2=true;
bool calibrations[6];
int globalcounter2=0;
//bool botonStopped=true;
//bool botonWalking=true;

-(void)setStopped:(NSNumber *) num{

    calibratedAvgStopped = num;
}

-(void)setWalking:(NSNumber *) num{
    
    calibratedAvgWalking = num;
}

-(void)setRunning:(NSNumber *) num{
    
    calibratedAvgRunning = num;
}

-(void)setBike:(NSNumber *) num{
    
    calibratedAvgBike = num;
}

-(void)setCar:(NSNumber *) num{
    
    calibratedAvgCar = num;
}


-(void)setBus:(NSNumber *) num{
    
    calibratedAvgBus = num;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)dropTable:(id)sender{

    char *errMsg;
    
    const char *sql_stmt;
    
    const char *dbpath = [databasePath2 UTF8String];
    if (sqlite3_open(dbpath, &database2) == SQLITE_OK)
    {

     sql_stmt = "DROP TABLE IF EXISTS calibration";
     
     if (sqlite3_exec(database2, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
     {
     NSLog(@"Failed to delete table");
     }
     else{
     NSLog(@"Success to delete table");
     }
    }
    
     



}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [btnWalking setTitle:@"Done!" forState:UIControlStateDisabled];  
    [btnStopped setTitle:@"Done!" forState:UIControlStateDisabled];  
    [btnRunning setTitle:@"Done!" forState:UIControlStateDisabled];  
    [btnBike setTitle:@"Done!" forState:UIControlStateDisabled];  
    [btnCar setTitle:@"Done!" forState:UIControlStateDisabled];  
    [btnBus setTitle:@"Done!" forState:UIControlStateDisabled];  

    
   // NSLog([NSString stringWithFormat:@"%f",fabsf([prueba floatValue])]);
    
    for (int i=0; i<6; i++) {
        calibrations[i]=FALSE;
    }
    
    if([calibratedAvgStopped floatValue]>0.0)
        [btnStopped setEnabled:FALSE];
    if([calibratedAvgWalking floatValue]>0.0)
        [btnWalking setEnabled:FALSE];
    if([calibratedAvgRunning floatValue]>0.0)
        [btnRunning setEnabled:FALSE];
    if([calibratedAvgBike floatValue]>0.0)
        [btnBike setEnabled:FALSE];
    if([calibratedAvgCar floatValue]>0.0)
        [btnCar setEnabled:FALSE];
    if([calibratedAvgBus floatValue]>0.0)
        [btnBus setEnabled:FALSE];
    
    
    
    // Do any additional setup after loading the view from its nib.
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database2 file
    databasePath2 = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"newBD.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    
    if ([filemgr fileExistsAtPath: databasePath2 ] != NO)
    {
        
		const char *dbpath = [databasePath2 UTF8String];
        if (sqlite3_open(dbpath, &database2) == SQLITE_OK)
        {
            char *errMsg;
            
            const char *sql_stmt;
      
            sql_stmt = "CREATE TABLE if not exists calibration(id INTEGER PRIMARY KEY, average TEXT, stdDeviation TEXT, event TEXT)";
            
            if (sqlite3_exec(database2, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            else{
                NSLog(@"Success to create table");
            }
            
            sqlite3_close(database2);
            
        } else {
            NSLog(@"Failed to open/create database2");
        }
    }
    else{
        NSLog(@"Failed to hola");
        
    }
    
    NSLog(@"%@", databasePath2);
    [filemgr release];


    
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
- (void)nuevaFuncion:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
}


- (IBAction)calibrateStopped:(id)sender{

    transportationMode = @"Stopped";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Calibration will now start!"
                          message:@"Press OK button and place your device in the place it most commonly will be carried. After 5 minutes the device will vibrate and the calibration will be over."
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
}

- (IBAction)calibrateWalking:(id)sender{
    
    transportationMode = @"Walking";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Calibration will now start!"
                          message:@"Press OK button and place your device in the place it most commonly will be carried. After 5 minutes the device will vibrate and the calibration will be over."
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
    
}

- (IBAction)calibrateRunning:(id)sender{
    
    transportationMode = @"Running";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Calibration will now start!"
                          message:@"Press OK button and place your device in the place it most commonly will be carried. After 5 minutes the device will vibrate and the calibration will be over."
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
    
}

- (IBAction)calibrateBike:(id)sender{
    
    transportationMode = @"Bike";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Calibration will now start!"
                          message:@"Press OK button and place your device in the place it most commonly will be carried. After 5 minutes the device will vibrate and the calibration will be over."
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
    
}

- (IBAction)calibrateCar:(id)sender{
    
    transportationMode = @"Car";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Calibration will now start!"
                          message:@"Press OK button and place your device in the place it most commonly will be carried. After 5 minutes the device will vibrate and the calibration will be over."
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
    
}

- (IBAction)calibrateBus:(id)sender{
    
    transportationMode = @"Bus";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Calibration will now start!"
                          message:@"Press OK button and place your device in the place it most commonly will be carried. After 5 minutes the device will vibrate and the calibration will be over."
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK", nil];
    [alert show];
    
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


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger) buttonIndex{
    
    if (buttonIndex == 1) {
        // Ok
        NSLog(@"start calibration for %@", transportationMode);
        
        [self startAccelerometer];

    } else {
        // Cancel
        NSLog(@"dont start calibration");
    }
}




- (void)writeBD{
    
    NSLog(@"WRITE 2 DB");
    
        
    //tiempo...
    //NSDate *dia = [NSDate date];
    NSDateFormatter *formater;
    NSString *tiempo;
    
    formater = [[NSDateFormatter alloc]init];
    [formater setDateFormat:@"HH:mm:ss"];
    tiempo = [formater stringFromDate:[NSDate date]];
    

    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database2 file
    databasePath2 = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"newBD.sqlite"]];

    
    
    

    sqlite3_stmt *statement;
    const char *dbpath = [databasePath2 UTF8String];
    
    if (sqlite3_open(dbpath, &database2) == SQLITE_OK){
    
        NSString *valor1 = [NSString stringWithFormat:@"%f", fabsf(avgsummation2)];
        NSString *valor2 = [NSString stringWithFormat:@"%f", fabsf(stdDeviation)];
        
        NSString *querySQL = [NSString stringWithFormat:@"insert into calibration (average, stdDeviation, event) values (\"%@\",\"%@\",\"%@\")", valor1, valor2, transportationMode];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_prepare_v2(database2, query_stmt, -1, &statement, NULL);
        
        
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Data added");
        }
        else{
            NSLog(@"Fail to add data");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database2);
        
        
    }
    
    
}



- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration{
    
    if(globalcounter2 >= CALIBRATION_SIZE){
        [self stopAccelerometer];
        
        for (int i=0; i<CALIBRATION_SIZE; i++) {
            avgsummation2+=calibrationVector[i];
        }
        
        avgsummation2/=CALIBRATION_SIZE;
        
        for (int i=0; i<CALIBRATION_SIZE; i++) {
            stdDeviation += pow((calibrationVector[i]-avgsummation2), 2);
        }
        
        stdDeviation/=CALIBRATION_SIZE;
        
        stdDeviation=sqrt(stdDeviation);
        
        [self writeBD];
        globalcounter2=0;
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        if([transportationMode isEqualToString:@"Stopped"]){
            [btnStopped setEnabled:FALSE];
           // [statusCalibrationStopped setText:@"Done!"];
        }
        if([transportationMode isEqualToString:@"Walking"]){
            [btnWalking setEnabled:FALSE];
           // [statusCalibrationWalking setText:@"Done!"];
        }
        if([transportationMode isEqualToString:@"Running"]){
            [btnRunning setEnabled:FALSE];
           // [statusCalibrationRunning setText:@"Done!"];
        }
        if([transportationMode isEqualToString:@"Bike"]){
            [btnBike setEnabled:FALSE];
           // [statusCalibrationBike setText:@"Done!"];
        }
        if([transportationMode isEqualToString:@"Car"]){
            [btnCar setEnabled:FALSE];
           // [statusCalibrationCar setText:@"Done!"];
        }
        if([transportationMode isEqualToString:@"Bus"]){
            [btnBus setEnabled:FALSE];
           // [statusCalibrationBus setText:@"Done!"];
        }
        

    }
    
    
    NSLog(@"accelerometer fired!");
    
    if(first_time2){
        
        v11[counter2]=sqrt(pow(acceleration.x, 2)+pow(acceleration.y, 2)+pow(acceleration.z, 2));
        counter2++;
        
        if(counter2==VECTOR_SIZE){
            first_time2=false;
            counter2=0;
            current_vector2=2;
            
            summation2 = 0.0;
            for (int i=0; i<VECTOR_SIZE; i++) {
                summation2 += v11[i];
            }
            avg11 = summation2/VECTOR_SIZE;
            
            
        }
    }else{
        
        if(current_vector2==1){
            v11[counter2]=sqrt(pow(acceleration.x, 2)+pow(acceleration.y, 2)+pow(acceleration.z, 2));
            counter2++;
            
            if(counter2==VECTOR_SIZE){
                counter2=0;
                current_vector2=2;
                
                summation2 = 0.0;
                for (int i=0; i<VECTOR_SIZE; i++) {
                    summation2 += v11[i];
                }
                avg11 = summation2/VECTOR_SIZE;
                
                NSLog(@"writing");
                //self.writeBD;
                
                calibrationVector[globalcounter2]=(avg11+avg22)/2.0;
                globalcounter2++;

            }
        }
        else{
            
            v22[counter2]=sqrt(pow(acceleration.x, 2)+pow(acceleration.y, 2)+pow(acceleration.z, 2));
            counter2++;
            
            if(counter2==VECTOR_SIZE){
                counter2=0;
                current_vector2=1;
                
                summation2 = 0.0;
                for (int i=0; i<VECTOR_SIZE; i++) {
                    summation2 += v22[i];
                }
                avg22 = summation2/VECTOR_SIZE;
                
                NSLog(@"writing");
                //self.writeBD;
                calibrationVector[globalcounter2]=(avg11+avg22)/2.0;
                globalcounter2++;

            }
            
        }
        
        
        
        
        
        //if (condicion para caminar == true)
        //evento=caminar;
        
        
        
        
    }
    
    
    
    
}




@end
