//
//  ViewController.m
//  KOAProgress
//
//  Created by Miroslav Perović on 7/5/12.
//  Copyright (c) 2012 KeepOnApps. All rights reserved.
//

#import "ViewController.h"
#import "KOAProgressBar.h"

@interface ViewController ()

@property (strong, nonatomic) NSTimer *progressTimer;

@end

@implementation ViewController
@synthesize progressBar;
@synthesize progressTimer = _progressTimer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//	self.progressBar.progressBarColorBackground = [UIColor colorWithRed:0.0980f green:0.1137f blue:0.1294f alpha:1.0f];
//	self.progressBar.progressBarColorBackgroundGlow = [UIColor colorWithRed:0.0666f green:0.0784f blue:0.0901f alpha:1.0f];
	self.view.backgroundColor = [UIColor colorWithRed:0.85 green:0.25 blue:0.25 alpha:0.9];
	[self.progressBar setMinValue:0.25];
	self.progressBar.progress = 0.05;
	[self.progressBar setMaxValue:0.75];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f 
														  target:self 
														selector:@selector(changeProgressValue)
														userInfo:nil
														 repeats:YES];
}

- (void)viewDidUnload
{
    [self setProgressBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}

- (void)dealloc {
    if (_progressTimer && [_progressTimer isValid])
    {
        [_progressTimer invalidate];
    }
}

#pragma mark -
#pragma mark YLViewController Public Methods

- (void)changeProgressValue
{
    float progressValue = self.progressBar.progress;
    
    progressValue += 0.01f;
    
//	[progressValueLabel setText:[NSString stringWithFormat:@"%.0f%%", (progressValue * 100)]];
    [progressBar setProgress:progressValue];
}

@end
