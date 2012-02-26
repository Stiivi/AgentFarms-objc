/** AFGraphElement

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Oct 6
   
    This file is part of the AgentFarmsViewsramework.
 
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.
 
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 */

#import "AFGraphElement.h"

#import <AppKit/NSColor.h>
#import <AppKit/NSBezierPath.h>


#import "AFGeometry.h"

static NSColor *defaultColor = nil;

@implementation AFGraphElement
+ (void)setDefaultColor:(NSColor *)aColor
{
    ASSIGN(defaultColor, aColor);
}

+ (NSColor *)defaultColor
{
    return defaultColor;
}
+ (void)initialize
{
    defaultColor = RETAIN([NSColor blackColor]);
}

- init
{
    [super init];

    color = RETAIN([[self class] defaultColor]);
    label = @"Unknown";
    
    return self;
}
- (void)dealloc
{
    RELEASE(label);
    RELEASE(color);
    [super dealloc];
}
- (void)setLabel:(NSString *)aString
{
    ASSIGN(label, aString);
}
- (NSString *)label
{
    return label;
}

- (void)setColor:(NSColor *)aColor
{
    ASSIGN(color, aColor);
}
- (NSColor *)color
{
    return color;
}

- (void)setLineWidth:(float)width
{
    lineWidth = width;
}
- (float)lineWidth
{
    return lineWidth;
}

- (void)drawWithFrame:(NSRect)frame minValue:(double)min maxValue:(double)max
{
    [self subclassResponsibility:_cmd];
}
- (AFRect *)bounds
{
    return AFNullRect;
}

- (void)drawLegendSampleInRect:(NSRect)frame
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float         x,y;

    [color set];

    x = frame.origin.x;
    y = frame.origin.y + frame.size.height / 2.0;

    [path setLineWidth:lineWidth];
    [path moveToPoint:NSMakePoint(x,y)];
    [path relativeLineToPoint:NSMakePoint(frame.size.width,0)];
    [path stroke];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    
    [aCoder encodeObject:label];
    [aCoder encodeObject:color];

    [aCoder encodeValueOfObjCType: @encode(float) at: &lineWidth];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    [aDecoder decodeValueOfObjCType: @encode(id) at: &label];
    [aDecoder decodeValueOfObjCType: @encode(id) at: &color];
    [aDecoder decodeValueOfObjCType: @encode(float) at: &lineWidth];
    
    return self;
}
@end
