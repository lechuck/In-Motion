//
//  InMotionViewController.m
//  InMotion
//
//  Created by Tony Karppinen on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InMotionViewController.h"
#import <sqlite3.h>
@implementation InMotionViewController

@synthesize accelerometerStatus, gpsStatus;
@synthesize accelX, accelY, accelZ, sum, max;
@synthesize CLController;

NSDateFormatter *formatter;
NSString        *dateString;
NSString *databasePath;
NSInteger *resultado;
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
    

    /*WE STORE DATA AS WE GET THE ACCELEROMETER INFORMATION******************/    
   /*************************************/
    
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];

    NSLog(@"%@", databasePath);
    /*
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];   
    */
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
    NSString *querySQL = [NSString stringWithFormat:@"insert into data (x, y, z, time) values (\"%@\",\"%@\",\"%@\",\"%@\")",
                          stringAccelX, stringAccelY, stringAccelZ, @"tiempo"];
    
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

- (void)locationUpdate:(CLLocation *)location {
	locLabel.text = [location description];
}

- (void)locationError:(NSError *)error {
	locLabel.text = [error description];
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
    [super viewDidLoad];
    
    // Location controller
	CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locMgr startUpdatingLocation];
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"accelData.sqlite"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
		const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE if not exists data(id INTEGER PRIMARY KEY, x TEXT, y TEXT, z TEXT, time TEXT)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
               NSLog(@"Failed to create table");
            }
            
            sqlite3_close(database);
            
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
    
    [filemgr release];

    
    
    
    
  

    /*const char *dbpath = [@"/Users/matiaspacelli/Desktop/HCI/In-Motion/accelData.sqlite" UTF8String]; // Convert NSString to UTF-8
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //Database opened successfully
        NSLog(@"database opened correctlly!");
    } else {
        //Failed to open database
         NSLog(@"database failed to open!");
    }
*/
    
    

}

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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
       
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

- (void)dealloc {
	[CLController release];
    [super dealloc];
}


@end
