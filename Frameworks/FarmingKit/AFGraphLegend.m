/** AFGraphLegend 

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2003 May 17
   
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


#import "AFGraphLegend.h"

#import "AFGraphElement.h"
#import "AFGraphView.h"
#import "AFGraph.h"

#import <AppKit/NSColor.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSStringDrawing.h>

#define SAMPLE_WIDTH 20.0
#define TITLE_OFFSET  4.0
#define LABEL_OFFSET  4.0
#define LABEL_SPACING 2.0

@implementation AFGraphLegend:NSObject
- init
{
    [super init];

    /* Set default colors */
    
    backgroundColor = RETAIN([NSColor whiteColor]);
    
    titleFont = RETAIN([NSFont labelFontOfSize:0.0]);
    elementFont = RETAIN([NSFont labelFontOfSize:0.0]);
    
    /* Set default legend margin */
    
    margin = 6.0;
    
    return self;
}
- (void)dealloc
{
    RELEASE(titleFont);
    RELEASE(elementFont);
    RELEASE(backgroundColor);
    RELEASE(title);
    
    [super dealloc];
}

/** Set related graph. */
- (void)setGraph:(AFGraph *)aGraph
{
    graph = aGraph;
}

/** Return related graph cell */
- (AFGraph *)graph
{
    return graph;
}

- (void)drawInRect:(NSRect)rect
{
    NSAttributedString *label;
    AFGraphElement     *element;
    NSEnumerator       *enumerator;
    NSDictionary       *attr;
    NSPoint             point;
    NSRect              frame = [self bounds];
    NSRect              sampleRect;
    NSSize              size = {0.0, 0.0};
    float               yincrement;
    BOOL                hasTitle = (title && ![title isEqualToString:@""]);
    
//    NSLog(@"Draw legend %f %f",frame.origin.x, frame.origin.y);
        
    if(drawsBackground)
    {
        if ( [NSGraphicsContext currentContextDrawingToScreen] ) 
        {
            [backgroundColor set];
        } 
        else 
        {
            [[backgroundColor colorWithAlphaComponent:1.0] set];
        }
        [NSBezierPath fillRect:frame]; 
    }

    if(isBordered)
    {
        [[NSColor blackColor] set];
        [NSBezierPath strokeRect:frame]; 
    }

    if(hasTitle)
    {
        attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     titleFont,NSFontAttributeName,
                                     nil,nil];

        label = [[NSAttributedString alloc] initWithString:title
                                                attributes:AUTORELEASE(attr)];
        size = [label size];

        point.x = frame.origin.x + margin;
        point.y = frame.origin.y + frame.size.height - margin;
        [label drawAtPoint:point];
        RELEASE(label);
    }
        
    attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 elementFont,NSFontAttributeName,
                                 nil,nil];

    enumerator = [[graph elements] objectEnumerator];
    
    size = [elementFont maximumAdvancement];
    yincrement = size.height + LABEL_SPACING;

    point.x = frame.origin.x + margin;
    point.y = frame.origin.y + frame.size.height;
    point.y -= margin + (hasTitle ? TITLE_OFFSET : 0.0);

    while( (element = [enumerator nextObject]) )
    {
        label = [[NSAttributedString alloc] initWithString:[element label]
                                                attributes:attr];
        [label drawAtPoint:
                 NSMakePoint(point.x + SAMPLE_WIDTH + LABEL_OFFSET, point.y)];

        RELEASE(label);

        sampleRect.origin = NSMakePoint(point.x, point.y - yincrement);
        sampleRect.size = NSMakeSize(SAMPLE_WIDTH, yincrement);
        [element drawLegendSampleInRect:sampleRect];

        point.y -= yincrement;
    }

    RELEASE(attr);
}

- (void)sizeToFit
{
    NSAttributedString *label;
    AFGraphElement     *element;
    NSEnumerator       *enumerator;
    NSDictionary       *attr;
    NSPoint             point;
    NSRect              frame = [self bounds];
    NSSize              size;
    NSSize              newSize = {0.0, 0.0};
    float               w = 0.0, h = 0.0;
    float               elementHeight;
    float               maxLabelWidth = 0.0;
    BOOL                hasTitle = (title && ![title isEqualToString:@""]);

    if(hasTitle)
    {
        attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     titleFont,NSFontAttributeName,
                                     nil,nil];

        label = [[NSAttributedString alloc] initWithString:title
                                          attributes:attr];

        RELEASE(attr);
        size = [label size];
        maxLabelWidth = size.width;
        newSize = NSMakeSize(0.0,size.height);
    }
                                              
    enumerator = [[graph elements] objectEnumerator];

    attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 elementFont,NSFontAttributeName,
                                 nil,nil];
    label = [[NSAttributedString alloc] initWithString:@"M"
                                            attributes:attr];

    size = [elementFont maximumAdvancement];
    newSize.height += (size.height  + LABEL_SPACING) * [[graph elements] count];
    
    while( (element = [enumerator nextObject]) )
    {
        label = [[NSAttributedString alloc] initWithString:[element label]
                                                attributes:attr];
        size = [label size];
        maxLabelWidth = MAX(maxLabelWidth, size.width);
    }

    newSize.width += margin*2 + SAMPLE_WIDTH + LABEL_OFFSET + maxLabelWidth;
    newSize.height += margin*2 + (hasTitle ? TITLE_OFFSET : 0.0);
    
    [self setFrameSize:newSize];

    RELEASE(attr);
}
- (void)setTitle:(NSString *)aString
{
    ASSIGN(title,aString);
}
- (NSString *)title
{
    return title;
}
- (void)setTitleFont:(NSFont *)aFont
{
    ASSIGN(titleFont,aFont);
}
- (NSFont *)titleFont
{
    return titleFont;
}
- (void)setElementFont:(NSFont *)aFont
{
    ASSIGN(elementFont, aFont);
}
- (NSFont *)elementFont
{
    return elementFont;
}
- (void)setBordered:(BOOL)flag
{
    isBordered = flag;
}
- (BOOL)isBordered
{
    return isBordered;
}
- (void)setDrawsBackground:(BOOL)flag
{
    drawsBackground = flag;
}
- (void)drawsBackground;
{
    return drawsBackground;
}
- (void)setBackgroundColor:(NSColor *)color
{
    ASSIGN(backgroundColor, color);
}
- (NSColor *)backgroundColor
{
    return backgroundColor;
}
- (void)graphViewDidChangeGraphs:(AFGraphView *)view
{
    [self sizeToFit];
}
- (void)setMargin:(float)value
{
    margin = value;
}
- (float)margin
{
    return margin;
}
- (NSData *)dataWithEPS
{
    return [self dataWithEPSInsideRect:[self bounds]];
}
@end
