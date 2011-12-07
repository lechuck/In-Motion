//
//  InMotionViewController.m
//  InMotion
//
//  Created by Tony Karppinen on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InMotionViewController.h"
#import <sqlite3.h>
#import <math.h>
#import <Foundation/NSJSONSerialization.h>

#define VECTOR_SIZE 16

@implementation InMotionViewController

@synthesize accelerometerStatus;
@synthesize status;

// Debug, remember to remove from code
@synthesize debugLabel;
@synthesize debugLabelMeters;
@synthesize debugLabelCalled;



// Location
@synthesize CLController;
double              avgspeed;
NSMutableArray      *avgSpeedArray;
NSMutableArray      *busStopsArray;
float               myAverageSpeed = 0;
NSString            *currentType;
CLLocation          *oldLocation;
CLLocation          *currentLocation;
double              distance;
int const           kMySpeedInterval = 20;      // Get the speed in every kMySpeedInterval seconds
int const           kSpeedMaxAvgTime = 3 * 60;  // Use no more data than from last 3min for speed average
int const           kDistancingMax = 3;         // Use no more data than from last 3min for speed average
float const         kModeUpdateInterval = 10.0; // Mode is updated every kModeUpdateInterval seconds
float const         kIDLEMinThreshold = 0;
float const         kIDLEMaxThreshold = 1.99;
float const         kWalkingMinThreshold = 2;
float const         kWalkingMaxThreshold = 9;
float const         kRunningMinThreshold = 7;
float const         kRunningMaxThreshold = 16;
float const         kCyclingMinThreshold = 12;
float const         kCyclingMaxThreshold = 35;
float const         kBusMinThreshold = 12; // get data
float const         kBusMaxThreshold = 60;
float const         kCarMinThreshold = 20;
float const         kCarMaxThreshold = 130;
NSDate              *lastUpdatedAt;
NSArray             *stopKeys;
NSTimer             *testTimer;

sqlite3 *database;

NSDateFormatter *formatter;
NSString        *dateString;
NSString *databasePath;
NSInteger *resultado;
double maximo = 0.0;
NSString *evento = @"stop";

double v1[VECTOR_SIZE], v2[VECTOR_SIZE];
double avg1,avg2,summation;

int counter=0;
int current_vector=1;
bool first_time=true;

double calibratedAvgs[6], calibratedDeviations[6];
/*
 0 -> stopped
 1 -> walking
 2 -> running
 3 -> bike
 4 -> car
 5 -> bus
 */

double limitWalkStop=1.05;
double limitWalkRun=1.3;

- (IBAction)btnWalking:(id)sender{
    evento=@"walking";
}
- (IBAction)btnRunning:(id)sender{
    evento=@"running";}

- (IBAction)btnStop:(id)sender{
    evento=@"stop";
    
}
- (IBAction)btnJoggin:(id)sender{
    evento=@"jogging";
}
- (IBAction)carTrip:(id)sender{
    evento=@"car";
}
- (IBAction)busTrip:(id)sender{
    evento=@"bus";
}


- (void)writeBD{
    
    NSLog(@"WRITE 2 DB");
   
    //preparamos datos para insertar en BB.DD
    //media...
    double calcAvg=(avg1+avg2)/2.0;
    NSString *avg = [NSString stringWithFormat:@"%f", fabsf(calcAvg)];
    
    //tiempo...
    //NSDate *dia = [NSDate date];
    NSDateFormatter *formater;
    NSString *tiempo;
    
    formater = [[NSDateFormatter alloc]init];
    [formater setDateFormat:@"HH:mm:ss"];
    tiempo = [formater stringFromDate:[NSDate date]];
    
    //conectamos a BB.DD
    
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK){
        
        if(calcAvg>limitWalkRun){
            [status setText:@"running"];
            evento=@"runnning";
        
        }
        else if(calcAvg<=limitWalkRun && calcAvg > limitWalkStop){
            [status setText:@"walking"];
            evento=@"walking";
        }   
        /* MIX WITH TONY WORK
        else if(calcAvg<=1.05 && speed() > 10k/h){
            [status setText:@"bus"];
            evento=@"bus";
        }
         */
        else{
            [status setText:@"stopped"];
            evento=@"stopped";
        }
        
        NSString *querySQL = [NSString stringWithFormat:@"insert into bus (average, time, event) values (\"%@\",\"%@\",\"%@\")", avg, tiempo, evento];
        
        const char *query_stmt = [querySQL UTF8String];
        
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);        
        
        if (sqlite3_step(statement) == SQLITE_DONE){
            NSLog(@"Data added");
        }
        else{
            NSLog(@"Fail to add data");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);                
    }
}


- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration{

    NSLog(@"accelerometer fired!");
    
    if(first_time){
        
        v1[counter]=sqrt(pow(acceleration.x, 2)+pow(acceleration.y, 2)+pow(acceleration.z, 2));
        counter++;
        
        if(counter==VECTOR_SIZE){
            first_time=false;
            counter=0;
            current_vector=2;
            
            summation = 0.0;
            for (int i=0; i<VECTOR_SIZE; i++) {
                summation += v1[i];
            }
            avg1 = summation/VECTOR_SIZE;
        }
    }
    else {
        if(current_vector==1){
            v1[counter]=sqrt(pow(acceleration.x, 2)+pow(acceleration.y, 2)+pow(acceleration.z, 2));
            counter++;
            
            if(counter==VECTOR_SIZE){
                counter=0;
                current_vector=2;
                
                summation = 0.0;
                for (int i=0; i<VECTOR_SIZE; i++) {
                    summation += v1[i];
                }
                avg1 = summation/VECTOR_SIZE;
                
                NSLog(@"writing");
                self.writeBD;
            
            }
        }
        else{
            v2[counter]=sqrt(pow(acceleration.x, 2)+pow(acceleration.y, 2)+pow(acceleration.z, 2));
            counter++;
            
            if(counter==VECTOR_SIZE){
                counter=0;
                current_vector=1;
                
                summation = 0.0;
                for (int i=0; i<VECTOR_SIZE; i++) {
                    summation += v2[i];
                }
                avg2 = summation/VECTOR_SIZE;
                
                NSLog(@"writing");
                self.writeBD;            
            }
        }

    }
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    for (int i=0; i<6; i++) {
        calibratedAvgs[i]=0.0;
        calibratedDeviations[i]=0.0;
    }
    
    // DEBUG TEST! Remove!
    NSString *coordz = [NSString stringWithString:@"2545860,6675272"];
    NSLog(@"lat: %@", [[coordz componentsSeparatedByString:@","] objectAtIndex:1]);
    NSLog(@"lng: %@", [[coordz componentsSeparatedByString:@","] objectAtIndex:0]);    
    
    // Location controller
	CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
    CLController.locMgr.desiredAccuracy = kCLLocationAccuracyBest;
	[CLController.locMgr startUpdatingLocation];


    avgspeed = -1; // Non-initialized value, just to show if it's not changed.
    avgSpeedArray = [[NSMutableArray alloc] init];
    stopKeys = [[NSArray arrayWithObjects:@"stopcode", @"distance", @"distancing", @"lat", @"lng", nil] retain];
    
    
    // TODO: Move test code somewhere where it makes sense
    NSURL *webServiceURL;
     webServiceURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/?request=stops_area&epsg_in=4326&epsg_out=4326&center_coordinate=24.87630350190869,60.1626670395878&user=inmotion&pass=in002726&diameter=400"];
    NSError *error = nil;
 	NSData *data = [NSData dataWithContentsOfURL:webServiceURL];
    
    // TODO: Better error handling, what happens if there is no dataconnection available?
    if (data != NULL) {
        NSArray *stops = [NSJSONSerialization 
                          JSONObjectWithData:data 
                          options:NSJSONReadingMutableLeaves 
                          error:&error];
        
        [self updateReittiopasData:stops];        
    }
    
    [self busStopNearby:100];
    
    testTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                            target:self 
                                            selector:@selector(testTimerFired:) 
                                            userInfo:nil 
                                            repeats:YES];    
    
}

-(void)testTimerFired:(NSTimer *) theTimer
{    
    NSLog(@"timerFired @ %@", [theTimer fireDate]);
    if ([self busStopNearby:30]) {
        [debugLabel setText:@"nearby!"];
    }
    else {
        [debugLabel setText:@"not nearby :/"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");
    
    [accelerometerStatus setOn:FALSE];
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"newBD.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] != NO)
    {
        NSLog(@"Hola!");

		const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;            
            const char *sql_stmt;
            
            sql_stmt = "CREATE TABLE if not exists bus(id INTEGER PRIMARY KEY, average TEXT, time TEXT, event TEXT)";
                   
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            else{
                NSLog(@"Success to create table");
            }
            
            // create a table for the coordinates             
            sql_stmt = "CREATE TABLE if not exists coordinates(id INTEGER PRIMARY KEY, lat TEXT, lng TEXT, spd TEXT, time TEXT, vacc TEXT, hacc TEXT, type TEXT, myspeed TEXT, myavgspeed TEXT)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table 'coordites'");
            }                        
            
            sqlite3_stmt *statement;
            sql_stmt =[NSString stringWithFormat:@"SELECT average, stdDeviation FROM calibration WHERE event = \"%@\"", @"Stopped"];
            const char *query_stmt = [sql_stmt UTF8String];
        
            if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    calibratedAvgs[0]=sqlite3_column_double(statement, 0);
                    calibratedDeviations[0]=sqlite3_column_double(statement, 1);
                }
            }
            
            sql_stmt =[NSString stringWithFormat:@"SELECT average, stdDeviation FROM calibration WHERE event = \"%@\"", @"Walking"];
            query_stmt = [sql_stmt UTF8String];
            
            if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    calibratedAvgs[1] = sqlite3_column_double(statement, 0); 
                    calibratedDeviations[1] = sqlite3_column_double(statement, 1);
                }
            }
            
            sql_stmt =[NSString stringWithFormat:@"SELECT average, stdDeviation FROM calibration WHERE event = \"%@\"", @"Running"];
            query_stmt = [sql_stmt UTF8String];
            
            if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    calibratedAvgs[2] = sqlite3_column_double(statement, 0); 
                    calibratedDeviations[2] = sqlite3_column_double(statement, 1);
                }
            }
            
            sql_stmt =[NSString stringWithFormat:@"SELECT average, stdDeviation FROM calibration WHERE event = \"%@\"", @"Bike"];
            query_stmt = [sql_stmt UTF8String];
            
            if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    calibratedAvgs[3] = sqlite3_column_double(statement, 0); 
                    calibratedDeviations[3] = sqlite3_column_double(statement, 1);
                }
            }
            
            sql_stmt =[NSString stringWithFormat:@"SELECT average, stdDeviation FROM calibration WHERE event = \"%@\"", @"Car"];
            query_stmt = [sql_stmt UTF8String];
            
            if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    calibratedAvgs[4] = sqlite3_column_double(statement, 0); 
                    calibratedDeviations[4] = sqlite3_column_double(statement, 1);
                }
            }
            
            sql_stmt =[NSString stringWithFormat:@"SELECT average, stdDeviation FROM calibration WHERE event = \"%@\"", @"Bus"];
            query_stmt = [sql_stmt UTF8String];
            
            if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
                while(sqlite3_step(statement) == SQLITE_ROW) {
                    calibratedAvgs[5] = sqlite3_column_double(statement, 0); 
                    calibratedDeviations[5] = sqlite3_column_double(statement, 1);
                }
            }

            sqlite3_close(database);
            
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
    else{
        NSLog(@"Failed to hola");

    }
    
    NSString *resultado = [NSString stringWithFormat:@"%f", fabsf(calibratedAvgs[0])];
    NSLog(@"%@", resultado);
    [filemgr release];
    //----------------LIMITS------------------------
    //----------------WALKSTOP----------------------
    if(calibratedAvgs[0]==0 && calibratedAvgs[1]==0);
    else if(calibratedAvgs[0]!=0 && calibratedAvgs[1]==0)
        limitWalkStop=(calibratedAvgs[0]+2*calibratedDeviations[0]+1.05)/2;
    else if (calibratedAvgs[0]==0 && calibratedAvgs[1]!=0)
        limitWalkStop=(calibratedAvgs[1]-2*calibratedDeviations[1]+1.05)/2;
    else limitWalkStop=(calibratedAvgs[1]-calibratedDeviations[1]+calibratedAvgs[0]+2*calibratedDeviations[0])/2;
    //----------------WALKRUN-----------------------
    if(calibratedAvgs[2]==0 && calibratedAvgs[1]==0);
    else if(calibratedAvgs[2]!=0 && calibratedAvgs[1]==0)
        limitWalkRun=(calibratedAvgs[2]-2*calibratedDeviations[2]+1.4)/2;
    else if (calibratedAvgs[2]==0 && calibratedAvgs[1]!=0)
        limitWalkRun=(calibratedAvgs[1]+2*calibratedDeviations[1]+1.4)/2;
    else limitWalkRun=(calibratedAvgs[1]+2*calibratedDeviations[1]+calibratedAvgs[2]-2*calibratedDeviations[2])/2;
    
    NSLog(@"%f", fabs(limitWalkStop));
    NSLog(@"%f", fabs(limitWalkRun));
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopAccelerometer];
}

- (void)viewDidUnload
{
    [stopKeys release];
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
    }
}
    

- (void)updateReittiopasData:(NSArray *)stopsArray {
    // Debug
    NSDate *now = [NSDate date];
    [debugLabelCalled setText:[NSString stringWithFormat:@"updated: %@", [now description] ]];
    
    // If no busStopsArray array, create it 
    if (busStopsArray == NULL) {
        busStopsArray = [[NSMutableArray alloc] init];
        NSLog(@"busStopArray created.");
    }
    
    int index = -1;
    
    // Add each new stop to array and update the old stops. Remove unneeded stops.
    for (id bstop in stopsArray) {
        
        // debug again
        NSLog(@"Looking for code....");
        NSLog([bstop objectForKey:@"code"]);

        // index of the stop if it's already in the busStopArray        
        index = [busStopsArray indexOfObjectPassingTest:
                 ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                     return ([ [[obj objectForKey:@"stopcode"] description] isEqualToString:[bstop objectForKey:@"code"] ]);
                }];
        
        if (index == NSNotFound) {
            // Busstop was not found in busStopArray, adding it
            
            // Add the values of a busstop to objs. Used to create the dictionary 
            NSMutableArray *objs = [NSMutableArray arrayWithObjects:[bstop objectForKey:@"code"],   // stop code
                             [bstop objectForKey:@"dist"],                                          // distance
                             [NSNumber numberWithInt:0],                                            // distancing                    
                             [[[bstop objectForKey:@"coords"] componentsSeparatedByString:@","] objectAtIndex:1], // lat
                             [[[bstop objectForKey:@"coords"] componentsSeparatedByString:@","] objectAtIndex:0], // lng                            
                             nil];
            
            [busStopsArray addObject:[NSMutableDictionary dictionaryWithObjects:objs forKeys:stopKeys]];
            
        }
        else {
            // Busstop found, update the info
            NSInteger distanceToStop = [[[busStopsArray objectAtIndex:index] valueForKey:@"distance"] intValue];
            NSInteger distancing = [[[busStopsArray objectAtIndex:index] valueForKey:@"distancing"] intValue];
            
            if ([[bstop valueForKey:@"distance"] intValue] > distanceToStop) {
                // Distance to the busstop is growing, remove if happens more than kDistancingMax times
                distancing++;
                if (distancing > kDistancingMax) {
                    [busStopsArray removeObjectAtIndex:index];
                }
                else {
                    [[busStopsArray objectAtIndex:index] 
                     setValue: [NSNumber numberWithInt:distancing]
                     forKey:@"distancing"];                    
                }                
            }
            else {
                // Reset the distancing value
                [[busStopsArray objectAtIndex:index] setValue: [NSNumber numberWithInt:0] forKey:@"distancing"];                
            }
            
            // Update the distance
            [[busStopsArray objectAtIndex:index] setValue:[bstop valueForKey:@"dist"] forKey:@"distance"];
        };
    
    }
    
    
    NSLog(@"FROM ARRAY: %@", [[stopsArray objectAtIndex:0] objectForKey:@"city"]);
    
    
    // Iterate it
    for (id aStop in busStopsArray) {
        NSLog(@"code: %@ distance: %@ distancing: %@", 
              [aStop objectForKey:@"stopcode"], 
              [aStop objectForKey:@"distance"], 
              [aStop objectForKey:@"distancing"]);
    }
    
    lastUpdatedAt = [[NSDate alloc] init];
    
}

// Returns true if a busstop is in 'meters' bounding box. Safe to call often, calls Reittiopas API only when neccessary. 
- (bool)busStopNearby:(NSInteger) meters {
    NSLog(@"busStopNearbyCalled...");
    
    // Check wheter the busStopArray data has gone stale
    if (myAverageSpeed == 0) {
        myAverageSpeed = 0.1;
    }
    NSTimeInterval sinceLastUpdate = -1* [lastUpdatedAt timeIntervalSinceNow];
    double avgSpeedInMetersPerSecond = (myAverageSpeed * 1000) / 3600;
    double updateInterval = avgSpeedInMetersPerSecond * sinceLastUpdate;
        
    // Update the data if needed
    //if ((updateInterval * 1.1) > meters) { 
    if (true) { 
        NSURL *webServiceURL;
        NSString *urlString = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=stops_area&epsg_in=4326&epsg_out=4326&center_coordinate=%f,%f&user=inmotion&pass=in002726&diameter=400", 
                               [currentLocation coordinate].longitude,
                               [currentLocation coordinate].latitude,
                               meters];
        NSLog(urlString);
        webServiceURL = [NSURL URLWithString:urlString];
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:webServiceURL];
        NSMutableArray *stops;
        
        if (data != NULL) {
            stops = [NSJSONSerialization 
                     JSONObjectWithData:data 
                     options:NSJSONReadingMutableLeaves 
                     error:&error];
            
            [self updateReittiopasData:stops];        
        }            
    }

    // Debug smallest
    double closest = 8888888;
    
    // Check the distances to all the busstops in busStopsArray
    for (id aStop in busStopsArray) {        
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:
                                    [[aStop objectForKey:@"lat"] doubleValue]
                                    longitude:[[aStop objectForKey:@"lng"] doubleValue]];
        // Debug
        NSLog([NSString stringWithFormat:@"lat: %f AND lng: %f", 
               [[aStop objectForKey:@"lat"] doubleValue],
               [[aStop objectForKey:@"lng"] doubleValue]]);
        
        if (closest > [currentLocation distanceFromLocation:stopLocation]) {
            closest = [currentLocation distanceFromLocation:stopLocation];
        }
        
        if ([currentLocation distanceFromLocation:stopLocation] < meters) {
            return true; 
        }
        
        [stopLocation release];
    }
    
    [debugLabelMeters setText:[NSString stringWithFormat:@"%f meters.", closest]];
    
    return false;        

};

- (float)getAverageSpeed {
    return myAverageSpeed;
};

- (float)getSpeed {
    return avgspeed;
};




- (void)locationUpdate:(CLLocation *)location {
    currentLocation = [location copy];
    NSString* spd = [[NSNumber numberWithFloat:([location speed])] stringValue];
    NSString* lat = [[NSNumber numberWithDouble:([location coordinate].latitude)] stringValue];
    NSString* lng = [[NSNumber numberWithDouble:([location coordinate].longitude)] stringValue];
    NSString* vacc = [[NSNumber numberWithDouble:([location verticalAccuracy])] stringValue];
    NSString* hacc = [[NSNumber numberWithDouble:([location horizontalAccuracy])] stringValue];    
    
    NSString* tms = [[location timestamp] description];
    
    NSString* logMsg = [NSString stringWithFormat:@"speed: %@ lat: %@ lng: %@ at %@", spd, lat, lng, tms];
    NSLog(@"%@", logMsg);
            
    if (oldLocation==NULL) {
        oldLocation = [location copy];
    }
    else if (kMySpeedInterval < [[location timestamp] timeIntervalSinceDate:[oldLocation timestamp]]) {        
        distance = [location distanceFromLocation:oldLocation];
        
        // Speed in km/h
        avgspeed = (distance / 1000) / (([[location timestamp] timeIntervalSinceDate:[oldLocation timestamp]] / 60) / 60);
        
        // Set current location as the old location
        oldLocation = [location copy];
        
        // Add speed to array
        if ([avgSpeedArray count] > (kSpeedMaxAvgTime/kMySpeedInterval)) {
            [avgSpeedArray removeObjectAtIndex:0]; // Remove the oldest when time is up
        }
        [avgSpeedArray addObject:[NSNumber numberWithFloat:avgspeed]];
        
    }            
    
    myAverageSpeed = 0;
    
    for (id avgSpeedInKMH in avgSpeedArray) {
        myAverageSpeed = myAverageSpeed + [avgSpeedInKMH floatValue];
    }
    
    if ([avgSpeedArray count] != 0) {
        myAverageSpeed = myAverageSpeed / [avgSpeedArray count];
    }
    
    spd = [NSString stringWithFormat:@"%@ / %f", spd, myAverageSpeed];
    
    NSString *mySpeed = [NSString stringWithFormat:@"%f", avgspeed];
    NSString *myAvgSpeed = [NSString stringWithFormat:@"%f", myAverageSpeed];        
    
    // Write the location data to the database
    
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    // Open the SQLite database
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {        
        NSString *querySQL = [NSString stringWithFormat:@"insert into coordinates (lat, lng, spd, time, vacc, hacc, type, myspeed, myavgspeed) values (\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", lat, lng, spd, tms, vacc, hacc, currentType, mySpeed, myAvgSpeed];
        
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE){
            //NSLog(@"Data added");
        }
        else{
            NSLog(@"Fail to add data");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}    

- (void)locationError:(NSError *)error {
    // Errors?
}

- (IBAction)doCalibrate:(id)sender{
    
    NSLog(@"doCalibrate!");
    
    CalibrationViewController *vmensaje = [[CalibrationViewController alloc] init];
    
    //----------
    [vmensaje setCalibratedAvgStopped:[NSNumber numberWithFloat:fabsf(calibratedAvgs[0])]];
    [vmensaje setCalibratedAvgWalking:[NSNumber numberWithFloat:fabsf(calibratedAvgs[1])]];
    [vmensaje setCalibratedAvgRunning:[NSNumber numberWithFloat:fabsf(calibratedAvgs[2])]];
    [vmensaje setCalibratedAvgBike:[NSNumber numberWithFloat:fabsf(calibratedAvgs[3])]];
    [vmensaje setCalibratedAvgCar:[NSNumber numberWithFloat:fabsf(calibratedAvgs[4])]];
    [vmensaje setCalibratedAvgBus:[NSNumber numberWithFloat:fabsf(calibratedAvgs[5])]];
    
    [vmensaje setTitle:@"Calibration"];
    [self.navigationController pushViewController:vmensaje animated:YES];
    
    [vmensaje release];
    
}

@end
