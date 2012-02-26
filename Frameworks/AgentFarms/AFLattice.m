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

#import "AFLattice.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSCoder.h>
#import <Foundation/NSString.h>
#import <Foundation/NSZone.h>

static NSZone *defaultZone = NULL;

@implementation AFLattice
+ (void)initialize
{
    defaultZone = NSDefaultMallocZone();
}

- initWithWidth:(int)newWidth height:(int)newHeight
{
    self = [super init];
    
    NSAssert(newWidth > 0, @"Width of lattice should be greather than zero");
    NSAssert(newHeight > 0, @"Height of lattice should be greather than zero");
    width = newWidth;
    height = newHeight;

    numbers = NSZoneMalloc(defaultZone, sizeof(int) * width * height);
    memset(numbers, 0, sizeof(int) * width * height);
    
    return self;
}
- (void)dealloc
{
    NSZoneFree(defaultZone, numbers);
    [super dealloc];
}

- (int)width
{
    return width;
}
- (int)height
{
    return height;
}

- (void)setInt:(int)value atX:(int)x y:(int)y
{
    NSAssert(x < width, @"X is out of lattice bounds");
    NSAssert(y < height, @"Y is out of lattice bounds");

    numbers[x + y*width] = value;
}
- (int)intAtX:(int)x y:(int)y
{
    NSAssert(x < width, @"X is out of lattice bounds");
    NSAssert(y < height, @"Y is out of lattice bounds");

    return numbers[x + y*width];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // [super encodeWithCoder: aCoder];
    
    [aCoder encodeValueOfObjCType: @encode(int) at: &width];
    [aCoder encodeValueOfObjCType: @encode(int) at: &height];
    [aCoder encodeArrayOfObjCType: @encode(int) count:width*height 
                                                      at: numbers];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    // self = [super initWithCoder: aDecoder];
    self = [super init];
    
    [aDecoder decodeValueOfObjCType: @encode(int) at: &width];
    [aDecoder decodeValueOfObjCType: @encode(int) at: &height];

    numbers = NSZoneMalloc(defaultZone, sizeof(int)*width*height);
    [aDecoder decodeArrayOfObjCType: @encode(int) count:width*height 
                                 at: numbers];

    return self;
}
@end
