/** AFGeometry

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek <urbanek@host.sk>
    Date: 2002 Oct 27
   
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

#import "AFGeometry.h"

#import <Foundation/NSString.h>

AFPoint *AFNullPoint = nil;
AFRect  *AFNullRect = nil;
AFSize  *AFNullSize = nil;

/* Point definition. */
@implementation AFPoint
+ (void)initialize
{
    AFNullPoint = [[AFPoint alloc] initWithX:0.0 y:0.0];
}
+ pointWithX:(double)nx y:(double)ny
{
    return AUTORELEASE([[self alloc] initWithX:nx y:ny]);
}
- initWithX:(double)nx y:(double)ny
{
    x = nx;
    y = ny;
    return self;
}
- (double)x { return x; }
- (double)y { return y; }
- (void)setX:(double)nx { x = nx; }
- (void)setY:(double)ny { y = ny; }
- (BOOL)isEqual:(id)anObject
{
    if( [anObject class] == [self class] )
    {
        return (x == [anObject x] && y == [anObject y]);
    }
    return NO;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"{ x = %f ; y = %f }", 
                                        x,y];
}
@end

@implementation AFSize
+ (void)initialize
{
    AFNullSize = [[AFSize alloc] initWithWidth:0.0 height:0.0];
}
+ sizeWithWidth:(double)w height:(double)h
{
    return AUTORELEASE([[self alloc] initWithWidth:w height:h]);
}
- initWithWidth:(double)w height:(double)h
{
    width = w;
    height = h;
    return self;
}
- (double)width { return width; }
- (double)height { return height; }
- (void)setWidth:(double)w { width = w; }
- (void)setHeight:(double)h { height = h; }
- (BOOL)isEqual:(id)anObject
{
    if( [anObject class] == [self class] )
    {
        return (width == [anObject width] && height == [anObject height]);
    }
    return NO;
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"{ width = %f ; height = %f }", 
                                        width, height];
}
@end

@implementation AFRect
+ (void)initialize
{
    [AFPoint class];
    [AFSize class];
    AFNullRect = [[AFRect alloc] initWithOrigin:AFNullPoint size:AFNullSize];
}
+ rectWithOrigin:(AFPoint *)o size:(AFSize *)s
{
    return AUTORELEASE([[self alloc] initWithOrigin:o size:s]);
}
+ rectWithMinX:(double)xmin minY:(double)ymin maxX:(double)xmax maxY:(double)ymax
{
    AFRect *rect;
    rect = [[AFRect alloc] initWithMinX:(double)xmin 
                                   minY:(double)ymin 
                                   maxX:(double)xmax 
                                   maxY:(double)ymax];
    return AUTORELEASE(rect);
}
- initWithMinX:(double)xmin minY:(double)ymin maxX:(double)xmax maxY:(double)ymax
{
    origin = [[AFPoint alloc] initWithX:xmin y:ymin];
    size = [[AFSize alloc] initWithWidth:xmax - xmin height:ymax - ymin];
    
    return self;
}
- (void)dealloc
{
    RELEASE(origin);
    RELEASE(size);
    [super dealloc];
}
- initWithOrigin:(AFPoint *)o size:(AFSize *)s
{
    origin = RETAIN(o);
    size = RETAIN(s);
    return self;
}
- (AFPoint *)origin { return origin; }
- (AFSize *)size { return size; }
- (void)setOrigin:(AFPoint *)o { ASSIGN(origin,o); }
- (void)setSize:(AFPoint *)s { ASSIGN(size,s); }
- (double)maxX
{
    return AFMaxX(self);
}
- (double)minX
{
    return [origin x];
}
- (double)maxY
{
    return [origin y] + [size height];
}
- (double)minY
{
    return AFMinY(self);
}
- (double)midX
{
    return [origin x] + [size width] / 2.0;
}
- (double)midY
{
    return [origin y] + [size height] / 2.0;
}
- (BOOL)isEqual:(id)anObject
{
    if( [anObject class] == [self class] )
    {
        return ([origin isEqual:[anObject origin]] 
                  && [size isEqual:[anObject size]]);
    }
    return NO;
}
- (AFRect *)unionWithRect:(AFRect *)arect
{
    AFRect *rect;
    double  minx, miny, maxx, maxy;
    
    minx = MIN(AFMinX(self), AFMinX(arect));
    miny = MIN(AFMinY(self), AFMinY(arect));
    maxx = MAX(AFMaxX(self), AFMaxX(arect));
    maxy = MAX(AFMaxY(self), AFMaxY(arect));

    rect = [AFRect rectWithOrigin:[AFPoint pointWithX:minx y:miny]
                             size:[AFSize sizeWithWidth:maxx - minx 
                                                 height:maxy - miny]];
    return rect;
}
- (AFRect *)intersectWithRect:(AFRect *)aRect
{
    if (AFMaxX(aRect) <= AFMinX(self) || AFMaxX(self) <= AFMinX(aRect) 
        || AFMaxY(aRect) <= AFMinX(self) || AFMaxY(self) <= AFMinX(aRect)) 
    {
        return AFNullRect;
    }
    else
    {
         double minx, maxx, miny, maxy;

         if (AFMinX(aRect) <= AFMinX(self))
           minx = AFMinX(self);
         else
           minx = AFMinX(aRect);

         if (AFMinY(aRect) <= AFMinY(self))
           miny = AFMinY(self);
         else
           miny = AFMinY(aRect);

         if (AFMaxX(aRect) >= AFMaxX(self))
           maxx = AFMaxX(self);
         else
           maxx = AFMaxX(aRect);

         if (AFMaxY(aRect) >= AFMaxY(self))
           maxy = AFMaxY(self);
         else
           maxy = AFMaxY(aRect);

         return [AFRect rectWithMinX:minx minY:miny maxX:maxx maxY:maxy];
    }
}
#define myX (((AFPointStruct *)origin)->x)
#define myY (((AFPointStruct *)origin)->y)
#define myWidth (((AFSizeStruct *)size)->width)
#define myHeight (((AFSizeStruct *)size)->height)

- (AFRect *)rectByZoom:(double)factor
{
    double cx, cy;
    double w,h;
    
    cx = myX + myWidth / 2.0;
    cy = myY + myHeight / 2.0;
    w = myWidth * factor;
    h = myHeight * factor;
    
    return [AFRect rectWithMinX:cx - w / 2.0
                           minY:cy - h / 2.0
                           maxX:cx + w / 2.0
                           maxY:cy + h / 2.0];
}
- (AFRect *)rectByTranslatingX:(double)xoff y:(double)yoff
{
    return [AFRect rectWithOrigin:[AFPoint pointWithX:myX + xoff y:myY + yoff]
                           size:size];
}
- (AFRect *)rectWithinBounds:(AFRect *)bounds
{
    double x = myX;
    double y = myY;
    
    if(AFMinX(self) < AFMinX(bounds))
    {
        x = AFMinX(bounds);
    }
    else if(AFMaxX(self) >= AFMaxX(bounds))
    {
        x = AFMaxX(bounds) - myWidth;
    }

    if(AFMinY(self) <= AFMinY(bounds))
    {
        y = AFMinY(bounds);
    }
    else if(AFMaxY(self) >= AFMaxY(bounds))
    {
        y = AFMaxY(bounds) - myHeight;
    }

    x = MAX(x, AFMinX(bounds));
    y = MAX(y, AFMinY(bounds));

    return [AFRect rectWithOrigin:[AFPoint pointWithX:x y:y]
                             size:size];
    
    
}
- (NSString *)description
{
    return [NSString stringWithFormat:@"{ origin = %@ ; size = %@ }", origin, size];
}
@end
