//
//  ViewController.h
//  iMidiFinder
//
//  Created by Olivier Scherler on 11.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *console;

- (void) appendToConsole: (NSString *) string;
- (void) method1;
- (void) method2;
- (IBAction)toto:(id)sender;

- (IBAction)rescan:(id)sender;

@end
