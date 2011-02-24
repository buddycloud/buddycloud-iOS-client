/* 
 CustomAlert.m
 Buddycloud
 
 Created by Adnan U - [Deminem] on 12/18/10.
 Copyright 2010 buddycloud. All rights reserved.
 
 */

#import "CustomAlert.h"

#define FIXED_LINE_HEIGHT 25.0
#define STARTING_TXT_POS 22.0f

@interface CustomAlert (CustomImage)

- (void) drawRoundedRect:(CGRect) rect inContext:(CGContextRef) 
context withRadius:(CGFloat) radius;

+ (void) dismissAlert:(NSTimer *)timer;
@end

static UIColor *fillColor = nil;
static UIColor *borderColor = nil;

@implementation CustomAlert

@synthesize textField;

+ (void) setBackgroundColor:(UIColor *) background 
			withStrokeColor:(UIColor *) stroke
{
	if(fillColor != nil)
	{
		[fillColor release];
		[borderColor release];
	}
	
	fillColor = [background retain];
	borderColor = [stroke retain];
}

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
	{
        if(fillColor == nil)
		{
			fillColor = [RGBACOLOR(16, 57, 71, 0.8) retain];
			borderColor = [RGBCOLOR(206, 216, 218) retain];
		}
    }
	
    return self;
}

- (void)layoutSubviews
{
	for (UIView *sub in [self subviews])
	{
		if([sub class] == [UIImageView class] && sub.tag == 0)
		{
			// The alert background UIImageView tag is 0, 
			// if you are adding your own UIImageView's 
			// make sure your tags != 0 or this fix 
			// will remove your UIImageView's as well!
			[sub removeFromSuperview];
			break;
		}
	}
}

- (void)drawRect:(CGRect)rect
{	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextClearRect(context, rect);
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetLineWidth(context, 0.0);
	CGContextSetAlpha(context, 0.9); 
	CGContextSetLineWidth(context, 2.0);
	CGContextSetStrokeColorWithColor(context, [borderColor CGColor]);
	CGContextSetFillColorWithColor(context, [fillColor CGColor]);
	
	// Draw background
	CGFloat backOffset = 2;
	CGRect backRect = CGRectMake(rect.origin.x + backOffset, 
								 rect.origin.y + backOffset, 
								 rect.size.width - backOffset*2, 
								 rect.size.height - backOffset*2);
	
	[self drawRoundedRect:backRect inContext:context withRadius:8];
	CGContextDrawPath(context, kCGPathFillStroke);
	
	// Clip Context
	CGRect clipRect = CGRectMake(backRect.origin.x + backOffset-1, 
								 backRect.origin.y + backOffset-1, 
								 backRect.size.width - (backOffset-1)*2, 
								 backRect.size.height - (backOffset-1)*2);
	
	[self drawRoundedRect:clipRect inContext:context withRadius:8];
	CGContextClip (context);
	
	//Draw highlight
	CGGradientRef glossGradient;
	CGColorSpaceRef rgbColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35, 1.0, 1.0, 1.0, 0.06 };
	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, 
														components, locations, num_locations);
	
	CGRect ovalRect = CGRectMake(-130, -115, (rect.size.width*2), 
								 rect.size.width/2);
	
	CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
	CGPoint end = CGPointMake(rect.origin.x, rect.size.height/5);
	
	CGContextSetAlpha(context, 1.0); 
	CGContextAddEllipseInRect(context, ovalRect);
	CGContextClip (context);
	
	CGContextDrawLinearGradient(context, glossGradient, start, end, 0);
	
	CGGradientRelease(glossGradient);
	CGColorSpaceRelease(rgbColorspace); 
}

- (void) drawRoundedRect:(CGRect) rrect inContext:(CGContextRef) context 
			  withRadius:(CGFloat) radius
{
	CGContextBeginPath (context);
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), 
	maxx = CGRectGetMaxX(rrect);
	
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), 
	maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
}

#pragma mark -
#pragma Utility methods.
- (id)initAlertWithTxtFieldTitle:(NSString *)title showPreMsg:(NSString *)message 
					  keypadType:(UIKeyboardType )keypadType delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle
{
	if (self = [super initWithTitle:title message:[message stringByAppendingFormat:@"\n\n"] delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okButtonTitle, nil])
	{
		CGFloat noOfLines = ceil([title length] / 25.0f) * 25.0f + ceil([message length] / 29.0f) * 20.0f;
		CGFloat txtFieldPosY = STARTING_TXT_POS + noOfLines ;
		
		UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, txtFieldPosY, 260.0, 25.0)]; 
		[theTextField setBackgroundColor:[UIColor whiteColor]];
		theTextField.keyboardType = UIKeyboardTypePhonePad;
		[self addSubview:theTextField];
		
		self.textField = theTextField;
		[theTextField release];
		CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 120.0); 
		[self setTransform:translate];
	}
	return self;
}

+ (void)showAlertMessageWithTitle:(NSString *)title showPreMsg:(NSString *)sMsg {
	CustomAlert *alert = [[CustomAlert alloc] initWithTitle:title message:sMsg delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[alert show];
	
	[NSTimer scheduledTimerWithTimeInterval:2.0 
									 target:self 
								   selector:@selector(dismissAlert:) 
								   userInfo:[NSArray arrayWithObject:alert] 
									repeats:NO];
}

+ (void) dismissAlert:(NSTimer *)timer {
	
	if (timer) {
		CustomAlert *alert = (CustomAlert *)[[timer userInfo] objectAtIndex:0];
		[alert dismissWithClickedButtonIndex:0 animated:YES];
	}
}


- (void)show
{
	if (textField != nil) {
		[textField becomeFirstResponder];
	}
	
	[super show];
}

- (NSString *)enteredText
{
	return textField.text;
}

- (NSString *) phoneNoValidation:(NSString *)phoneNo
{
	NSMutableString *enteredPhoneNo = [[phoneNo mutableCopy] autorelease];
	[enteredPhoneNo replaceOccurrencesOfString:@" " 
									withString:@"" 
									   options:NSLiteralSearch 
										 range:NSMakeRange(0, [enteredPhoneNo length])];
	[enteredPhoneNo replaceOccurrencesOfString:@"*" 
									withString:@"" 
									   options:NSLiteralSearch 
										 range:NSMakeRange(0, [enteredPhoneNo length])];
	[enteredPhoneNo replaceOccurrencesOfString:@"#" 
									withString:@"" 
									   options:NSLiteralSearch 
										 range:NSMakeRange(0, [enteredPhoneNo length])];
	[enteredPhoneNo replaceOccurrencesOfString:@"," 
									withString:@"" 
									   options:NSLiteralSearch 
										 range:NSMakeRange(0, [enteredPhoneNo length])];
	
	return enteredPhoneNo;
}

+ (BOOL) phoneNoLengthValidation:(NSString *)phoneNo
{
	NSMutableString *enteredPhoneNo = [[phoneNo mutableCopy] autorelease];
	if ([enteredPhoneNo length] > 13 ) {
		return NO;	
	}
	
	return YES;
}

- (void)dealloc
{
	[textField release];
	[super dealloc];
}

@end
