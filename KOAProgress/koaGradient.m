//
//  koaGradient.m
//  KOAProgress
//
//  Created by Miroslav Perovic on 7/15/12.
//  Copyright (c) 2012 KeepOnApps. All rights reserved.
//

#import "koaGradient.h"

#if !defined(DegreesToRadians)
#define DegreesToRadians(x) (x * (CGFloat)M_PI / 180.0f)
#endif

#if !defined(RadiansToDegrees)
#define RadiansToDegrees(x) (x * 180.0f / (CGFloat)M_PI)
#endif

@interface koaGradient ()

@property (assign) CFMutableArrayRef cgColors;

- (BOOL)createWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locations colorSpace:(CGColorSpaceRef)colorSpace;

@end

@implementation koaGradient
@synthesize CGGradient = _cgGradient;
@synthesize numberOfColorStops = _numberOfColorStops;
@synthesize cgColors = _cgColors;
@synthesize colorLocations = _colorLocations;

#pragma mark -
#pragma mark Initialization
- (id)initWithStartingColor:(UIColor *)startingColor endingColor:(UIColor *)endingColor
{
	return [self initWithColors:[NSArray arrayWithObjects:startingColor, endingColor, nil]];
}

- (id)initWithColors:(NSArray *)colorArray
{
	if(nil != (self = [super init]))
	{
		NSUInteger count = [colorArray count];
		CGFloat delta = 1.0f/(count - 1);
		CGFloat locations[count];
		
		for(NSUInteger i = 0; i < count; i++)
		{
			locations[i] = i * delta;
		}
		
		if(![self createWithColors:colorArray atLocations:locations colorSpace:NULL])
		{
			self = nil;
		}
	}
	
	return self;
}

- (id)initWithColorsAndLocations:(UIColor *)firstColor, ...
{
	if(nil != (self = [super init]))
	{
		// Making a guess that you have 2 colors and two locations
		NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
		NSMutableArray *locArray = [NSMutableArray arrayWithCapacity:2];
		UIColor *theColor = nil;
		[colors addObject:firstColor];
		
		va_list	vargs;
		va_start(vargs, firstColor);
		double location = va_arg(vargs, double);
		[locArray addObject:[NSNumber numberWithDouble:location]];
		
		while(nil != (theColor = va_arg(vargs, UIColor *)))
		{
			[colors addObject:theColor];
			location = va_arg(vargs, double);
			[locArray addObject:[NSNumber numberWithDouble:location]];
		}
		va_end(vargs);
		
		NSUInteger count = [colors count];
		CGFloat locations[count];
		
		for(NSUInteger i = 0; i < count; i++)
		{
			locations[i] = [(NSNumber *)[locArray objectAtIndex:i] floatValue];
		}
		
		if(![self createWithColors:colors atLocations:locations colorSpace:NULL])
		{
			self = nil;
		}
	}
	return self;
}

- (id)initWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locations colorSpace:(CGColorSpaceRef)colorSpace
{
	if(nil != (self = [super init]))
	{
		if(![self createWithColors:colorArray atLocations:locations colorSpace:colorSpace])
		{
			self = nil;
		}
	}
	
	return self;
}

#pragma mark -
#pragma mark Drawing Linear Gradients
- (void)drawInRect:(CGRect)rect angle:(CGFloat)angle
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
	[self drawInBezierPath:path angle:angle];
}

- (void)drawInBezierPath:(UIBezierPath *)path angle:(CGFloat)angle
{
	CGRect rect = path.bounds;
	CGPoint startPoint = rect.origin, endPoint = CGPointMake(0.0f, CGRectGetHeight(rect));
	if(angle == 0)
  	{
		startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
		endPoint   = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
  	} else if(angle == 90) {
		startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
		endPoint   = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
  	} else {
		double_t x, y;
		double_t sina, cosa, tana;
		double_t length;
		double_t deltax, deltay;
		
		double_t radians = DegreesToRadians(angle);
		
		if(fabs(tan(radians)) <= 1.0f)
		{
			x = CGRectGetWidth(rect);
			y = CGRectGetHeight(rect);
			
			sina = sin(radians);
			cosa = cos(radians);
			tana = tan(radians);
			
			length = x/fabs(cosa) + (y - x * fabs(tana)) * fabs(sina);
			
			deltax = length * cosa/2;
			deltay = length * sina/2;
		} else	{					//[45,135], [225,315]
			x = CGRectGetHeight(rect);
			y = CGRectGetWidth(rect);
			
			sina = sin(radians - DegreesToRadians(90));
			cosa = cos(radians - DegreesToRadians(90));
			tana = tan(radians - DegreesToRadians(90));
			
			length = x/fabs(cosa) + (y - x * fabs(tana)) * fabs(sina);
			
			deltax = -length * sina/2;
			deltay = length * cosa/2;
		}
		
		startPoint = CGPointMake(CGRectGetMidX(rect) - (CGFloat)deltax, CGRectGetMidY(rect) - (CGFloat)deltay);
		endPoint   = CGPointMake(CGRectGetMidX(rect) + (CGFloat)deltax, CGRectGetMidY(rect) + (CGFloat)deltay);
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextAddPath(context, path.CGPath);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, _cgGradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Drawing Radial Gradients
- (void)drawInRect:(CGRect)rect relativeCenterPosition:(CGPoint)relativeCenterPosition
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
	[self drawInBezierPath:path relativeCenterPosition:relativeCenterPosition];
}

- (void)drawInBezierPath:(UIBezierPath *)path relativeCenterPosition:(CGPoint)relativeCenterPosition
{
	CGRect rect = path.bounds;
	CGSize size;
	CGPoint startCenter;
	
	if(relativeCenterPosition.x == 0 && relativeCenterPosition.y == 0)
	{
		startCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
		size.width = startCenter.x; size.height = startCenter.y;
	} else {
		CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
		startCenter = CGPointMake(center.x + relativeCenterPosition.x, center.y + relativeCenterPosition.y);
		size.width = relativeCenterPosition.x < 0 ? CGRectGetWidth(rect) - startCenter.x : startCenter.x;
		size.height = relativeCenterPosition.y < 0 ? CGRectGetHeight(rect) - startCenter.y : startCenter.y;
	}
	
	CGFloat endRadius = (CGFloat)sqrt(size.width*size.width + size.height*size.height);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGContextAddPath(context, path.CGPath);
	CGContextClip(context);
	CGContextDrawRadialGradient(context, _cgGradient, startCenter, 0.0f, startCenter, endRadius, 0);
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Primitive Drawing Methods
- (void)drawFromPoint:(CGPoint)startingPoint toPoint:(CGPoint)endingPoint options:(CGGradientDrawingOptions)options
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawLinearGradient(context, _cgGradient, startingPoint, endingPoint, options);
}

- (void)drawFromCenter:(CGPoint)startCenter radius:(CGFloat)startRadius toCenter:(CGPoint)endCenter radius:(CGFloat)endRadius options:(CGGradientDrawingOptions)options
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawRadialGradient(context, _cgGradient, startCenter, startRadius, endCenter, endRadius, options);
}

- (void)getColor:(UIColor **)color location:(CGFloat *)location atIndex:(NSInteger)colorIndex
{
    *color = nil;
    *location = FP_NAN;
    if((NSUInteger)colorIndex < _numberOfColorStops)
    {
        *location = _colorLocations[colorIndex];
        CGColorRef cgColor = (CGColorRef)CFArrayGetValueAtIndex(_cgColors, (CFIndex)colorIndex);
        if(NULL != cgColor)
        {
            *color = [UIColor colorWithCGColor:cgColor];
        }
    }
}

- (UIColor *)interpolatedColorAtLocation:(CGFloat)location
{
	UIColor *color = nil;
	if(_colorLocations[0] <= location && location <= _colorLocations[_numberOfColorStops - 1])
	{
		NSUInteger i = 0;
		for(i = 0; _colorLocations[i] <= location; i++);
		
		const CGFloat *start = CGColorGetComponents((CGColorRef)CFArrayGetValueAtIndex(_cgColors, (CFIndex)(i-1)));
		const CGFloat *end = CGColorGetComponents((CGColorRef)CFArrayGetValueAtIndex(_cgColors, (CFIndex)i));
		CGFloat components[4];
		
		for(i = 0; i < 4; i++)
		{
			components[i] = (1.0f - location) * start[i] + location * end[i];
		}
		
		color = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
	}
	
	return color;
}

- (void)dealloc
{
    if(NULL != _cgColors)
    {
        CFRelease(_cgColors), _cgColors = NULL;
    }
    
	if(NULL != _cgGradient)
	{
		CGGradientRelease(_cgGradient);
	}
	
	self.colorSpace = NULL;
	
	if(NULL != _colorLocations)
	{
		free(_colorLocations);
	}
}

#pragma mark colorSpace geter & seter
- (CGColorSpaceRef)colorSpace
{
	if(NULL == _colorSpace)
	{
		_colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	
	return _colorSpace;
}

- (void)setColorSpace:(CGColorSpaceRef)newColorSpace;
{
	if(NULL != _colorSpace)
	{
		CGColorSpaceRelease(_colorSpace);
	}
	
	_colorSpace = (NULL == newColorSpace) ? NULL : CGColorSpaceRetain(newColorSpace);
}

#pragma mark -
#pragma mark Private
- (BOOL)createWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locations colorSpace:(CGColorSpaceRef)colorSpace
{
	_numberOfColorStops = [colorArray count];
	_cgColors = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)_numberOfColorStops,  &kCFTypeArrayCallBacks);
	
	for(NSUInteger i = 0; i < _numberOfColorStops; i++)
	{
		CFArrayInsertValueAtIndex(_cgColors, (CFIndex)i, ((UIColor *)[colorArray objectAtIndex:i]).CGColor);
	}
	
	size_t count = sizeof(CGFloat) * _numberOfColorStops;
	
	_colorLocations = malloc(count);
	memcpy(_colorLocations, locations, count);
	
	self.colorSpace = colorSpace;
	_cgGradient = CGGradientCreateWithColors(self.colorSpace, _cgColors, _colorLocations);
	
	return (NULL != _cgGradient);
}

@end
