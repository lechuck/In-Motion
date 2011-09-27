//
//  MicBlowAppDelegate.h
//  MicBlow
//
//  Created by Dan Grigsby on 8/19/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MicBlowViewController;

@interface MicBlowAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MicBlowViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MicBlowViewController *viewController;

@end

