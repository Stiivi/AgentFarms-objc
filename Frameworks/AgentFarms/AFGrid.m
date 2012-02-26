/** AFGrid

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 10
    
    This file is part of the AgentFarms project.
 
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

#import "AFGrid.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSString.h>

@interface AFGridPoint:NSObject
{
    NSPoint point;
}
- initWithPoint:(NSPoint)point;
- (NSPoint)point;
- (void)setPoint:(NSPoint)aPoint;
- (void)setX:(float)x;
- (void)setY:(float)y;
- (float)x;
- (float)y;
@end

@implementation AFGridPoint
+ pointWithPoint:(NSPoint)aPoint
{
    AFGridPoint *gp;
    gp = [[AFGridPoint alloc] initWithPoint:aPoint];
    return AUTORELEASE(gp);
}
- initWithPoint:(NSPoint)aPoint
{
    point = aPoint;
    return self;
}
- (NSPoint)point
{
    return point;
}
- (unsigned) hash
{
    return (point.x * point.y);
}
- (BOOL)isEqual:(id)anObject
{
    if([self class] == [anObject class])
    {
        return NSEqualPoints(point, [anObject point]);
    }
    return NO;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"(%i, %i)", (int)point.x, (int)point.y];
}
- (void)setX:(float)x
{
    point.x = x;
}
- (void)setY:(float)y
{
    point.y = y;
}
- (float)x
{
    return point.x;
}
- (float)y
{
    return point.y;
}
- (void)setPoint:(NSPoint)aPoint
{
    point = aPoint;
}
@end

@implementation AFGrid
- initWithWidth:(unsigned int)w height:(unsigned int)h
{
    self = [super init];

    width = w;
    height = h;
    
    if(w == 0 || h == 0)
    {
        [NSException raise:@"AFGridException"
                     format:@"Given null width or height (%i, %i)", w, h];
    }
    objects = [[NSMutableArray alloc] init];
    points = [[NSMutableArray alloc] init];

    return self;
}
- (void)dealloc
{
    RELEASE(points);
    RELEASE(objects);
    [super dealloc];
}
- (void)putObject:(id)anObject atLocation:(NSPoint)point
{
    AFGridPoint *gp;
    int x = (int)point.x;
    int y = (int)point.y;
    int i;

    if(x < 0 || y < 0)
    {
        [NSException raise:@"AFGridException"
                    format:@"Negative location (%i, %i)", x,y];
        return;
    }    
    if(x >= width)
    {
        if(wraps)
            x = x % width;
        else
        {
            [self invalidLocation:point];
            return;
        }
    }
    else if (x < 0)
    {
        if(wraps)
            x = width - ((-x) % width);
        else
        {
            [self invalidLocation:point];
            return;
        }
    }
    if(y >= height)
    {
        if(wraps)
            y = y % height;
        else
        {
            [self invalidLocation:point];
            return;
        }
    }
    else if (y < 0)
    {
        if(wraps)
            y = height - ((-y) % height);
        else
        {
            [self invalidLocation:point];
            return;
        }
    }
    
    i = [objects indexOfObject:anObject];
    if(i != NSNotFound)
    {
        gp = [points objectAtIndex:i];
        [gp setPoint:NSMakePoint(x,y)];
    }
    else
    {
        gp = [AFGridPoint pointWithPoint:NSMakePoint(x,y)];
        [objects addObject:anObject];
        [points addObject:gp];
    }
}
- (void)invalidLocation:(NSPoint)point
{
    [NSException raise:@"AFGridException"
                 format:@"Invalid location (%i,%i) in grid (%i,%i), wraps %i",
                         (int)point.x, (int)point.y, width, height, wraps];
}
- (void)setWraps:(BOOL)flag
{
    wraps = flag;
}
- (BOOL)wraps
{
    return wraps;
}
- (NSPoint)locationOfObject:(id)anObject
{
    int i = [objects indexOfObject:anObject];
    
    if(i!= NSNotFound)
    {
        return [(AFGridPoint *)[points objectAtIndex:i] point];
    }
    return NSMakePoint(-1, -1);
}
- (BOOL)containsObject:(id)anObject
{
    return [objects containsObject:anObject];
}
- (void)moveObject:(id)anObject direction:(AFGridDirection) dir
{
    AFGridPoint *gp;
    NSPoint      point;
    int          i;

    if(![self containsObject:anObject])
    {
        return;
    }
    
    i = [objects indexOfObject:anObject];
    
    gp = [points objectAtIndex:i];
    point = [gp point];

    switch(dir)
    {
    case AFUpGridDirection:    point.y++; break;
    case AFRightGridDirection: point.x++; break;
    case AFDownGridDirection:  point.y--; break;
    case AFLeftGridDirection:  point.x--; break;
    case AFNoGridDirection: break;
    default: NSLog(@"Grid: invalid direction %i", dir);
    }
    
    if(point.x < 0)
        point.x = width - 1;
    else if(point.x >= width)
        point.x = 0;
    if(point.y < 0)
        point.y = height - 1;
    else if(point.y >= height)
        point.y = 0;
    
    [gp setPoint:point];
}
- (void)removeObject:(id)anObject
{
    int i = [objects indexOfObject:anObject];
    
    if(i!=NSNotFound)
    {
        [points removeObjectAtIndex:i];
        [objects removeObjectAtIndex:i];
    }
}
- (void)removeAllObjects
{
    [points removeAllObjects];
    [objects removeAllObjects];
}
- (NSArray *)allObjects
{
    return [NSArray arrayWithArray:objects];
}
- (int)width
{
    return width;
}
- (int)height
{
    return height;
}
@end
