/** AFLattice

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2003 Sep 20
   
    This file is part of the XY Framework.
 
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

#import "AFLatticeView.h"

#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>

#import <AgentFarms/AFLattice.h>

#import "AFColorMap.h"

Class NSBezierPath_class;
@implementation AFLatticeView
+ (void) initialize
{
    NSBezierPath_class = [NSBezierPath class];
}
- initWithFrame:(NSRect)rect
{
    self = [super initWithFrame:rect];
        
    colorMap = [[AFColorMap alloc] initWithGrayGrades:100];

    return self;
}
- (void)dealloc
{
    RELEASE(colorMap);
    RELEASE(lattice);
    [super dealloc];
}

- (void)drawRect:(NSRect)rect
{
    NSBezierPath        *path;
    NSRect               bounds = [self bounds];
    NSRect               rect;
    NSColor             *color;
    int                  x, y;
    int                  value;

    float                cellWidth, cellHeight;

    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];

    rect.size.width = bounds.size.width / [lattice width];
    rect.size.height = bounds.size.height / [lattice height];

    for(x = 0; x < [lattice width]; x++)
    {
        for(y = 0; y < [lattice height]; y++)
        {
            value = [lattice intAtX:x y:y];
            // NSLog(@"---- %i %i: %i", x, y, value);

            color = [colorMap colorAtIndex:value];
            [color set];
            
            rect.origin.x = rect.size.width * x;
            rect.origin.y = rect.size.height * y;
            [NSBezierPath_class fillRect:rect];
            
            //[[NSColor blackColor] set];
            //[NSBezierPath strokeRect:rect];
        }
    }

    // NSLog(@"Time %f", [date timeIntervalSinceNow]);

}
- (void)mouseDown:(NSEvent *)event
{
//    [self setNeedsDisplay:YES];
}
- (void)setLattice:(AFLattice *)aLattice
{
    ASSIGN(lattice, aLattice);
}
- (AFLattice *)lattice
{
    return lattice;
}
- (void)setColorMap:(AFColorMap *)map
{
    ASSIGN(colorMap,map);
}
- (AFColorMap *)colorMap
{
    return colorMap;
}
@end
