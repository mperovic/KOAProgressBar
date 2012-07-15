//
//  koaGradient.h
//  KOAProgress
//
//  Created by Miroslav Perovic on 7/15/12.
//  Copyright (c) 2012 KeepOnApps. All rights reserved.
//

// This class is my version of NSGradient class from OS X

#import <Foundation/Foundation.h>

@interface koaGradient : NSObject {
	CGColorSpaceRef _colorSpace;
}

@property CGGradientRef CGGradient;
@property NSUInteger numberOfColorStops;
@property CGFloat *colorLocations;

// Initialization
- (id)initWithStartingColor:(UIColor *)startingColor endingColor:(UIColor *)endingColor;
- (id)initWithColors:(NSArray *)colorArray;

// Drawing Linear Gradients
- (void)drawInRect:(CGRect)rect angle:(CGFloat)angle;
- (void)drawInBezierPath:(UIBezierPath *)path angle:(CGFloat)angle;

// Drawing Radial Gradients
- (void)drawInRect:(CGRect)rect relativeCenterPosition:(CGPoint)relativeCenterPosition;
- (void)drawInBezierPath:(UIBezierPath *)path relativeCenterPosition:(CGPoint)relativeCenterPosition;

// Color Location Color Location (MUST BE nil TERMINATED)
- (id)initWithColorsAndLocations:(UIColor *)firstColor, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locations colorSpace:(CGColorSpaceRef)colorSpace;

// Primitive Drawing Methods
- (void)drawFromPoint:(CGPoint)startingPoint toPoint:(CGPoint)endingPoint options:(CGGradientDrawingOptions)options;
- (void)drawFromCenter:(CGPoint)startCenter radius:(CGFloat)startRadius toCenter:(CGPoint)endCenter radius:(CGFloat)endRadius options:(CGGradientDrawingOptions)options;

- (void)getColor:(UIColor **)color location:(CGFloat *)location atIndex:(NSInteger)colorIndex;

@end
