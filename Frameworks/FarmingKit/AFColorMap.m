/** AFColorMap

    Copyright (c) 2003 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2003 Oct 5
   
    This file is part of the AgentFarms suite.
 
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

#import <FarmsData/AFLattice.h>

#import "AFColorMap.h"

Class NSBezierPath_class;
@implementation AFColorMap
+ colorMapWithGrayGrades:(int)grades
{
    return AUTORELEASE([[self alloc] initWithGrayGrades:grades]);
}
- initWithGrayGrades:(int)grades
{
    NSMutableArray *array = [NSMutableArray array];
    NSColor        *color;
    double          gray;
    int             i;
    
    self = [super init];
    
    undefinedColor = RETAIN([NSColor redColor]);
    count = grades;

    [array addObject:[NSColor colorWithCalibratedWhite:1 alpha:1.0]];
    
    for(i = 1; i <= count; i++)
    {
        color = [NSColor colorWithCalibratedWhite:1 - ((double)i/(double)(count-1))
                                            alpha:1.0];
        [array addObject:color];
    }
    colors = [[NSArray alloc] initWithArray:array];
    
    return self;
    
}
- init
{
    self = [super init];
    
    undefinedColor = RETAIN([NSColor blackColor]);
    
    return self;
}
- (void)dealloc
{
    RELEASE(undefinedColor);
    RELEASE(colors);
    [super dealloc];
}
- (int)count
{
    return count;
}
- (NSColor *)colorAtIndex:(int)index
{
    if(index > count)
    {
        return undefinedColor;
    }
    else if(index < 0)
    {
        return [NSColor yellowColor];
    }
    return [colors objectAtIndex:index];
}
- (void)setUndefinedColor:(NSColor *)aColor
{
    ASSIGN(undefinedColor, aColor);
}
- (NSColor *)undefinedColor
{
    return undefinedColor;
}
/*
                color = [zeroColor blendedColorWithFraction:fraction 
                                                    ofColor:positiveColor];
*/

@end
