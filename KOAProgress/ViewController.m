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

@end

@implementation ViewController
@synthesize progressBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithRed:0.85 green:0.25 blue:0.25 alpha:0.9];
	[self.progressBar setMinValue:0.0];
	[self.progressBar setMaxValue:1.0];
	[self.progressBar setRealProgress:0.25];
	[self.progressBar setDisplayedWhenStopped:NO];
//	[self.progressBar setTimerInterval:0.05];
//	[self.progressBar setProgressValue:0.005];
	[self.progressBar setAnimationDuration:5.0];
	
	[self.progressBar startAnimation:self];
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
@end
