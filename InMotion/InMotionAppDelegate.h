//
//  InMotionAppDelegate.h
//  InMotion
//
//  Created by Tony Karppinen on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class InMotionViewController;

@interface InMotionAppDelegate : NSObject <UIApplicationDelegate>{


}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet InMotionViewController *viewController;

@end
