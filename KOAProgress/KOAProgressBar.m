//
//  KOAProgressBar.m
//  KOAProgress
//
//  Created by Miroslav Perović on 7/5/12.
//  Copyright (c) 2012 KeepOnApps. All rights reserved.
//

#import "KOAProgressBar.h"
#import "koaGradient.h"

@interface KOAProgressBar () {
	CGFloat components[8];
	BOOL initialized;
}

@property (readonly, strong) NSTimer* animator;
@property double progressOffset;
@property (readonly) float animationDuration;

- (void)initializeProgressBar;

@end

@implementation KOAProgressBar
@synthesize animator = _animator;
@synthesize progressOffset = _progressOffset;
@synthesize displayedWhenStopped = _displayedWhenStopped;
@synthesize shadowColor = _shadowColor;
@synthesize stripeColor = _stripeColor;
@synthesize stripeWidth = _stripeWidth;
@synthesize inset = _inset;
@synthesize radius = _radius;
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize progressBarColorBackground = _progressBarColorBackground;
@synthesize progressBarColorBackgroundGlow = _progressBarColorBackgroundGlow;
@synthesize lighterProgressColor = _lighterProgressColor;
@synthesize darkerProgressColor = _darkerProgressColor;
@synthesize realProgress = _realProgress;
@synthesize timerInterval = _timerInterval;
@synthesize progressValue = _progressValue;
@synthesize animationDuration = _animationDuration;
@synthesize lighterStripeColor = _lighterStripeColor;
@synthesize darkerStripeColor = _darkerStripeColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initializeProgressBar];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame duration:(float)duration {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initializeProgressBar];
		
		[self setAnimationDuration:duration];
    }
    return self;
}

- (void)initializeProgressBar {
	_animator = nil;
	self.progressOffset = 0.0;
	self.stripeWidth = 10.0;
	self.inset = 2.0;
	self.radius = 10.0;
	self.minValue = 0.0;
	self.maxValue = 1.0;
	self.shadowColor = [UIColor colorWithRed:223.0/255.0 green:238.0/255.0 blue:181.0/255.0 alpha:1.0];
	self.progressBarColorBackground = [UIColor colorWithRed:25.0/255.0 green:29.0/255 blue:33.0/255.0 alpha:1.0];
	self.progressBarColorBackgroundGlow = [UIColor colorWithRed:17.0/255.0 green:20.0/255.0 blue:23.0/255.0 alpha:1.0];
	self.stripeColor = [UIColor colorWithRed:101.0/255.0 green:151.0/255.0 blue:120.0/255.0 alpha:0.9];
	self.lighterProgressColor = [UIColor colorWithRed:223.0/255.0 green:237.0/255.0 blue:180.0/255.0 alpha:1.0];
	self.darkerProgressColor = [UIColor colorWithRed:156.0/255.0 green:200.0/255.0 blue:84.0/255.0 alpha:1.0];
	self.lighterStripeColor = [UIColor colorWithRed:182.0/255.0 green:216.0/255.0 blue:86.0/255.0 alpha:1.0];
	self.darkerStripeColor = [UIColor colorWithRed:126.0/255.0 green:187.0/255.0 blue:55.0/255.0 alpha:1.0];
	self.displayedWhenStopped = YES;
	self.timerInterval = 0.1;
	self.progressValue = 0.01;

	initialized = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeProgressBar];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.progressOffset = (self.progressOffset > (2*self.stripeWidth)-1) ? 0 : ++self.progressOffset;
    
	[self drawBackgroundWithRect:rect];

    if (self.progress) {
        CGRect bounds = CGRectMake(self.inset, self.inset, self.frame.size.width*self.progress-2*self.inset, (self.frame.size.height-2*self.inset)-1);
        
		[self drawProgressWithBounds:bounds];
		[self drawStripesInBounds:bounds];
		[self drawGlossWithRect:bounds];
    }
}


#pragma mark -
#pragma mark Drawing

- (void)drawBackgroundWithRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    {
        // Draw the white shadow
        [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2] set];
        UIBezierPath* shadow = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.5, 0, rect.size.width - 1, rect.size.height - 1) 
														  cornerRadius:self.radius];
        [shadow stroke];
        
        // Draw the track
		[self.progressBarColorBackground set];
        
        UIBezierPath* roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height-1) cornerRadius:self.radius];
        [roundedRect fill];
        
        CGMutablePathRef glow = CGPathCreateMutable();
        CGPathMoveToPoint(glow, NULL, self.radius, 0);
        CGPathAddLineToPoint(glow, NULL, rect.size.width - self.radius, 0);
        CGContextAddPath(ctx, glow);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGPathRelease(glow);
    }
    CGContextRestoreGState(ctx);
}

-(void)drawShadowInBounds:(CGRect)bounds {
    [self.shadowColor set];
    
	UIBezierPath *shadow = [UIBezierPath bezierPath];
	[shadow moveToPoint:CGPointMake(5.0, 2.0)];
	[shadow addLineToPoint:CGPointMake(bounds.size.width - 10.0, 3.0)];
    
    [shadow stroke];
}

-(UIBezierPath*)stripeWithOrigin:(CGPoint)origin bounds:(CGRect)frame {
    float height = frame.size.height;
	
	UIBezierPath *rect = [UIBezierPath bezierPath];
    
    [rect moveToPoint:origin];
	[rect addLineToPoint:CGPointMake(origin.x + self.stripeWidth, origin.y)];
	[rect addLineToPoint:CGPointMake(origin.x + self.stripeWidth - 8.0, origin.y + height)];
	[rect addLineToPoint:CGPointMake(origin.x - 8.0, origin.y + height)];
	[rect addLineToPoint:origin];
    
    return rect;
}

-(void)drawStripesInBounds:(CGRect)frame {
	koaGradient *gradient = [[koaGradient alloc] initWithStartingColor:self.lighterStripeColor endingColor:self.darkerStripeColor];
    UIBezierPath* allStripes = [[UIBezierPath alloc] init];
    
    for (int i = 0; i <= frame.size.width/(2*self.stripeWidth)+(2*self.stripeWidth); i++) {
		UIBezierPath *stripe = [self stripeWithOrigin:CGPointMake(i*2*self.stripeWidth+self.progressOffset, self.inset) bounds:frame];
		[allStripes appendPath:stripe];
    }
    
    //clip
	UIBezierPath *clipPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:self.radius];
    [clipPath addClip];
    
    [gradient drawInBezierPath:allStripes angle:90];
}

-(void)drawProgressWithBounds:(CGRect)frame {
	UIBezierPath *bounds = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:self.radius];
    koaGradient *gradient = [[koaGradient alloc] initWithStartingColor:self.lighterProgressColor endingColor:self.darkerProgressColor];
    [gradient drawInBezierPath:bounds angle:90];
}

- (void)drawGlossWithRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(ctx);
    {
        // Draw the gloss
        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextBeginTransparencyLayerWithRect(ctx, CGRectMake(rect.origin.x, rect.origin.y + floorf(rect.size.height) / 2, rect.size.width, floorf(rect.size.height) / 2), NULL);
        {
            const CGFloat glossGradientComponents[] = {1.0f, 1.0f, 1.0f, 0.50f, 0.0f, 0.0f, 0.0f, 0.0f};
            const CGFloat glossGradientLocations[] = {1.0, 0.0};
            CGGradientRef glossGradient = CGGradientCreateWithColorComponents(colorSpace, glossGradientComponents, glossGradientLocations, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
            CGContextDrawLinearGradient(ctx, glossGradient, CGPointMake(0, 0), CGPointMake(0, rect.size.width), 0);
            CGGradientRelease(glossGradient);
        }
        CGContextEndTransparencyLayer(ctx);
        
        // Draw the gloss's drop shadow
        CGContextSetBlendMode(ctx, kCGBlendModeSoftLight);
        CGContextBeginTransparencyLayer(ctx, NULL);
        {
            CGRect fillRect = CGRectMake(rect.origin.x, rect.origin.y + floorf(rect.size.height / 2), rect.size.width, floorf(rect.size.height / 2));
            
            const CGFloat glossDropShadowComponents[] = {0.0f, 0.0f, 0.0f, 0.56f, 0.0f, 0.0f, 0.0f, 0.0f};
            CGColorRef glossDropShadowColor = CGColorCreate(colorSpace, glossDropShadowComponents);
            
            CGContextSaveGState(ctx);
            {
                CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 4, glossDropShadowColor);
                CGContextFillRect(ctx, fillRect);
                CGColorRelease(glossDropShadowColor);
            }
            CGContextRestoreGState(ctx);
            
            CGContextSetBlendMode(ctx, kCGBlendModeClear);   
            CGContextFillRect(ctx, fillRect);
        }
        CGContextEndTransparencyLayer(ctx);
    }
    CGContextRestoreGState(ctx);
    
    UIBezierPath *progressBounds = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.radius];
    
    // Draw progress bar glow
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, [progressBounds CGPath]);
        const CGFloat progressBarGlowComponents[] = {1.0f, 1.0f, 1.0f, 0.12f};
        CGColorRef progressBarGlowColor = CGColorCreate(colorSpace, progressBarGlowComponents);
        
        CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
        CGContextSetStrokeColorWithColor(ctx, progressBarGlowColor);
        CGContextSetLineWidth(ctx, 2.0f);
        CGContextStrokePath(ctx);
        CGColorRelease(progressBarGlowColor);
    }
    CGContextRestoreGState(ctx);
    
    CGColorSpaceRelease(colorSpace);
}


#pragma mark -
- (void)setMaxValue:(float)mValue {
	if (mValue < _minValue) {
		_maxValue = _minValue + 1.0;
	} else {
		_maxValue = mValue;
	}
}

- (void)setMinValue:(float)mValue {
	if (mValue > _maxValue) {
		_minValue = _maxValue - 1.0;
	} else {
		_minValue = mValue;
	}
}

- (void)setProgress:(float)progress {
	[super setProgress:progress];
	
	if (self.realProgress >= self.maxValue) {
        [self stopAnimation:self];
		if (!self.isDisplayedWhenStopped && initialized) {
			self.hidden = YES;
		}
	}
}

- (void)setRealProgress:(float)realProgress {
	_realProgress = realProgress;
	if (self.realProgress < self.minValue) {
		_realProgress = self.minValue;
	}
	if (self.realProgress > self.maxValue) {
		_realProgress = self.maxValue;
	}
    
	float distance = self.maxValue - self.minValue;
	float value = (self.realProgress) ? (self.realProgress - self.minValue)/distance : 0;
	
	[self setProgress:value];
}

#pragma mark Animation
-(void)startAnimation:(id)sender {
	self.hidden = NO;
    if (!self.animator) {
        self.animator = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval
														 target:self
													   selector:@selector(activateAnimation:)
													   userInfo:nil
														repeats:YES];
    }
}

-(void)stopAnimation:(id)sender {
    self.animator = nil;
}

-(void)activateAnimation:(NSTimer*)timer {
    float progressValue = self.realProgress;
    progressValue += self.progressValue;
    [self setRealProgress:progressValue];
	
	[self setNeedsDisplay];
}

-(void)setAnimator:(NSTimer *)value {
    if (_animator != value) {
        [_animator invalidate];
		_animator = value;
    }
}

- (void)dealloc {
	[_animator invalidate];
}

- (void)setAnimationDuration:(float)duration {
	float distance = self.maxValue - self.minValue;
	float steps = distance / self.progressValue;
	self.timerInterval = duration / steps;
}
@end
