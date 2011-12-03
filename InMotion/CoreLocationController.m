//
//  CoreLocationController.m
//  InMotion
//
//  Created by Tony Karppinen on 10/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreLocationController.h"

@implementation CoreLocationController
@synthesize locMgr, delegate;

- (id)init {
    NSLog(@"Init...");
	self = [super init];
    
	if(self != nil) {
		self.locMgr = [[[CLLocationManager alloc] init] autorelease]; // Create new instance of locMgr
		self.locMgr.delegate = self; // Set the delegate as self.
	}
    
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"didUpdateToLocation...");    
    [self.delegate locationUpdate:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSString* errorMessage = [NSString stringWithFormat:@"Location manager error: %@", [error description]];
    NSLog(@"%@", errorMessage);
    [self.delegate locationError:error];
}

- (void)dealloc {
	[self.locMgr release];
	[super dealloc];
}

@end
