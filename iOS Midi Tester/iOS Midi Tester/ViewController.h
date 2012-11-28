//
//  ViewController.h
//  iMidiFinder
//
//  Created by Olivier Scherler on 11.11.12.
//  Copyright (c) 2012 Olivier Scherler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MCMidiManager.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *console;
@property (retain) MCMidiManager *midi;

- (IBAction) rescan: (id) sender;
- (IBAction) play: (id) sender;

@end
