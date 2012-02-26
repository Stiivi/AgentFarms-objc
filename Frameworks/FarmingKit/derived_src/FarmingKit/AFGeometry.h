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

#import <Foundation/NSGeometry.h>

/* Point definition. */
@interface AFPoint:NSObject
{
@public
    double x;
    double y;
}
+ pointWithX:(double)nx y:(double)ny;
- initWithX:(double)nx y:(double)ny;
- (double)x;
- (double)y;
@end

@interface AFSize:NSObject
{
@public
    double width;
    double height;
}
+ sizeWithWidth:(double)w height:(double)h;
- initWithWidth:(double)w height:(double)h;
- (double)width;
- (double)height;
@end

@interface AFRect:NSObject
{
@public
    AFPoint *origin;
    AFSize  *size;
}
+ rectWithOrigin:(AFPoint *)o size:(AFSize *)s;
+ rectWithMinX:(double)xmin minY:(double)ymin maxX:(double)xmax maxY:(double)ymax;
- initWithMinX:(double)xmin minY:(double)ymin maxX:(double)xmax maxY:(double)ymax;
- initWithOrigin:(AFPoint *)o size:(AFSize *)size;

- (AFPoint *)origin;
- (AFSize *)size;

- (AFRect *)unionWithRect:(AFRect *)arect;
- (AFRect *)intersectWithRect:(AFRect *)aRect;

- (AFRect *)rectByZoom:(double)factor;
- (AFRect *)rectByTranslatingX:(double)xoff y:(double)yoff;
@end


extern AFPoint *AFNullPoint;
extern AFRect  *AFNullRect;
extern AFSize  *AFNullSize;

typedef struct
{
    @defs(AFPoint);
} AFPointStruct;

typedef struct
{
    @defs(AFRect);
} AFRectStruct;

typedef struct
{
    @defs(AFSize);
} AFSizeStruct;

#define AFMinX(rect) \
            (((AFPointStruct *)(((AFRectStruct *)rect)->origin))->x)
#define AFMinY(rect) \
            (((AFPointStruct *)(((AFRectStruct *)rect)->origin))->y)

#define AFMaxX(rect) \
            (((AFPointStruct *)(((AFRectStruct *)rect)->origin))->x + \
              ((AFSizeStruct *)(((AFRectStruct *)rect)->size))->width)
#define AFMaxY(rect) \
            (((AFPointStruct *)(((AFRectStruct *)rect)->origin))->y + \
              ((AFSizeStruct *)(((AFRectStruct *)rect)->size))->height)
#define AFWidth(rect) \
            (((AFSizeStruct *)(((AFRectStruct *)rect)->size))->width)
#define AFHeight(rect) \
            (((AFSizeStruct *)(((AFRectStruct *)rect)->size))->height)

#define AFPointFromNSPoint(_nsp) \
            ([AFPoint pointWithX:_nsp.x y:_nsp.y])
#define AFSizeFromNSSize(_nss) \
            ([AFPoint pointWithWidth:_nss.width y:_nss.height])
#define AFRectFromNSRect(_nsr) \
            ([AFRect rectWithMinX:NSMinX(_nsr)  \
                             minY:NSMinY(_nsr)  \
                             maxX:NSMaxX(_nsr)  \
                             maxY:NSMaxY(_nsr)])
                             
#define NSPointFromAFPoint(_afp) \
            (NSMakePoint(((AFPointStruct *)_afp)->x,((AFPointStruct *)_afp)->y))
#define NSSizeFromAFSize(_afs) \
            (NSMakePoint(((AFSizeStruct *)_afp)->width, \
                         ((AFSizeStruct *)_afp)->height))
#define NSRectFromAFRect(_afr) \
            (NSMakeRect(AFMinX(_afr), AFMinY(_afr), AFMaxX(_afr), AFMaxY(_afr)))


            
