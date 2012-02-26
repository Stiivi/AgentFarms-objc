/** AFGraph

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Nov 24
   
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

#import "AFGraph.h"

#import "AFGraphElement.h"
#import "AFGeometry.h"
#import <Foundation/NSDictionary.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSStringDrawing.h>
#import <AppKit/NSWindow.h>

@implementation AFGraph
+ (void)initialize
{
    /* initialize AFRect class to create AFNullRect */
    [AFRect class];
}
- init
{
    [super init];
    
    elements = [[NSMutableArray alloc] init];
        
    return self;
}

- (void)dealloc
{
    RELEASE(elements);

    [super dealloc];
}

/*=========================================================================
    Draw rect
=========================================================================*/

- (void)drawInRect:(NSRect)frame
        graphWindow:(AFRect *)windowRect
{   
    AFGraphElement *graph;
    NSBezierPath   *path;
    NSEnumerator   *enumerator;
    double          xmin, xmax, ymin, ymax, range;
    float           zero;

    xmin = AFMinX(windowRect);
    ymin = AFMinY(windowRect);
    xmax = AFMaxX(windowRect);
    ymax = AFMaxY(windowRect);
    
    /* Draw y zero line ------------------------------------------------- */
    
    if(ymin * ymax <= 0)
    {
        zero = (frame.size.height / (ymax - ymin)) * (-ymin);
        zero += frame.origin.y;

        [[NSColor blackColor] set];
   
        path = [NSBezierPath bezierPath];


#define ZERO_LINE_WIDTH  1.0

        [path setLineWidth:ZERO_LINE_WIDTH];

        [path moveToPoint:NSMakePoint(frame.origin.x, zero)];
        [path relativeLineToPoint: NSMakePoint(frame.size.width, 0)];
        [path stroke];
    }
    
    /* Draw x zero line ------------------------------------------------- */

    if(xmin * xmax <= 0)
    {
        zero = (frame.size.width / (xmax - xmin)) * (-xmin);
        zero += frame.origin.x;

        [[NSColor blackColor] set];
   
        path = [NSBezierPath bezierPath];
        [path setLineWidth:ZERO_LINE_WIDTH];

        [path moveToPoint:NSMakePoint(zero, frame.origin.y)];
        [path relativeLineToPoint: NSMakePoint(0, frame.size.height)];
        [path stroke];
    }

    enumerator = [elements objectEnumerator];

    [[NSGraphicsContext currentContext] DPSgsave];
    [NSBezierPath clipRect:frame];

    while( (graph = [enumerator nextObject]) )
    {
        AFRect *bounds;

        if(!relativeScale)
        {
            [graph drawWithFrame:frame 
                            minX:xmin
                            minY:ymin
                            maxX:xmax
                            maxY:ymax];
        }
        else
        {
            double xrange, yrange;
            
            bounds = [graph bounds];
            xrange = AFWidth(bounds);
            yrange = AFHeight(bounds);

            [graph drawWithFrame:frame 
                            minX:xmin
                            minY:AFMinY(bounds)+yrange*ymin
                            maxX:xmax
                            maxY:AFMinY(bounds)+yrange*ymax];
        }
    }

    [[NSGraphicsContext currentContext] DPSgrestore];
}

/*=========================================================================
    Elements
=========================================================================*/

/** Adds <var>element</var> to the list of receiver's graph elements and
    notifies associated graph legend view with graphViewDidChangeGraphs:self */
- (void)addElement:(AFGraphElement *)element
{
    [elements addObject:element];
}

/** Removes <var>element</var> from the list of receiver's graph elements and
    notifies associated graph legend view with graphViewDidChangeGraphs:self */

- (void)removeElement:(AFGraphElement *)element
{
    [elements removeObject:element];
}

/** Removes all elements of receiver and notifies associated graph legend view
    with graphViewDidChangeGraphs:self */

- (void)removeAllElements
{
    [elements removeAllObjects];
}

/** Sets all elements of receiver to be <var>array</var> and notifies 
    associated graph legend view with graphViewDidChangeGraphs:self */

- (void)setElements:(NSArray *)array
{
    [elements setArray:array];
}
- (NSArray *)elements
{
    return [NSArray arrayWithArray:elements];
}

/** Enable relative scaling when <var>flag</var> is YES. Relative scaling means
that all elements are drawn in different scales, so they minimum
values are drawn as equal, same for maximum values. */
- (void)setRelativeScale:(BOOL)flag
{
    relativeScale = flag;
}

/** Returns whether graph elements are drawn in relative scale. */
- (BOOL)relativeScale
{
    return relativeScale;
}

/** Set graph title to <var>aString</var> */
- (void)setTitle:(NSString *)aString
{
    ASSIGN(title,aString);
}
/** Returns graph title */
- (NSString *)title
{
    return title;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    
    [aCoder encodeObject:elements];
    [aCoder encodeValueOfObjCType: @encode(BOOL) at: &relativeScale];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    [aDecoder decodeValueOfObjCType: @encode(id) at: &elements];
    [aDecoder decodeValueOfObjCType: @encode(BOOL) at: &relativeScale];

    return self;
}
@end
