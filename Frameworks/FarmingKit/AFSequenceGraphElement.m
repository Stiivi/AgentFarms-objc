/** AFSequenceGraphElement
 
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

#import "AFSequenceGraphElement.h"

#import <AgentFarms/AFNumberCollection.h>
#import "AFGeometry.h"

#import <Foundation/NSException.h>

#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>

#import <math.h>

/* Maximum number of lines per point */
#define MAXIMUM_DENSITY 4

static SEL lineToPointSel;
static SEL moveToPointSel;
static SEL atIndexSel;

@implementation AFSequenceGraphElement
+ (void)initialize
{
    lineToPointSel = @selector(lineToPoint:);
    moveToPointSel = @selector(moveToPoint:);
    atIndexSel = @selector(numberAtIndex:);
}
+ elementWithCollection:(AFNumberCollection *)aCollection
{
    return AUTORELEASE([[self alloc] initWithCollection:aCollection]);
}
- initWithCollection:(AFNumberCollection *)aCollection
{
    [super init];

    if(!aCollection)
    {
        [NSException raise:@"AFInvalidArgumentException"
                     format:@"Time graph initialized with nil collection"];
        [self dealloc];
        return nil;                     
    }
    collection = RETAIN(aCollection);
    return self;
}
- (void)dealloc
{
    RELEASE(collection);
}

- (AFNumberCollection *)collection
{
    return collection;
}

- (AFRect *)bounds
{
    AFPoint *point;
    AFSize  *size;
    double   maxx, maxy, minx, miny;
    int      count = [collection count];
       
    minx = 0;
    miny = [collection minValue];
    maxx = (count > 1) ? (count - 1) : 0;
    maxy = [collection maxValue];

    point = [AFPoint pointWithX:minx y:miny];
    size = [AFSize sizeWithWidth:maxx-minx height:maxy - miny];  
    
    return [AFRect rectWithOrigin:point size:size];
}

- (void)drawWithFrame:(NSRect)frame 
            minX:(double)xmin
            minY:(double)ymin
            maxX:(double)xmax
            maxY:(double)ymax
{
    NSBezierPath  *graph = [NSBezierPath bezierPath];;
    double        (*atIndexImp)(id, SEL, int);
    IMP            lineToPointImp;
    IMP            moveToPointImp;
    double         value;
    double         x, y;
    double         xscale, yscale; 
    int            count = [collection count];
    int            i;
    int            from, to; /* colletion ellement range */
    int            win;      /* graph points per graphics point */
    int            wpos;
    double         wmin, wmax, wmid;
    
    from = MAX(xmin, 0);
    to = MIN(xmax, count - 1);
    if(to < 0)
        to = 0;
    if(from > count)
        from = count;
        
    [graph setLineJoinStyle:NSRoundLineJoinStyle];

    atIndexImp = [collection methodForSelector:atIndexSel];
    lineToPointImp = [graph methodForSelector:lineToPointSel];
    moveToPointImp = [graph methodForSelector:moveToPointSel];

    yscale = (frame.size.height / (ymax - ymin));
    xscale = (frame.size.width / (double)((xmax - xmin) ));

    // NSLog(@"-- %f %f %f", frame.size.height, ymax, ymin);

    [graph setLineWidth:lineWidth];

    value = (*atIndexImp)(collection,atIndexSel,from);

    y = (value - ymin)* yscale + frame.origin.y;
    x = ((double)(from - xmin)) * xscale + frame.origin.x;

    (*moveToPointImp)(graph, moveToPointSel, NSMakePoint(x,y));

    win = (int)floor(1.0 / xscale);

    if(win < MAXIMUM_DENSITY)
    {
        for(i = from + 1; i <= to; i++)
        {
            value = (*atIndexImp)(collection,atIndexSel,i);

            y = (value - ymin)* yscale + frame.origin.y;
            x = ((double)(i - xmin)) * xscale + frame.origin.x;

            (*lineToPointImp)(graph, lineToPointSel, NSMakePoint(x,y));
        }
    }
    else
    {
        /* Draw something like this: -^v- */
        
        for(i = from + 1; i <= to; i += win)
        {

            value = (*atIndexImp)(collection,atIndexSel,i);
            wmin = wmax = value;
            
            for(wpos = 1; wpos < win && (i + wpos) <= to; wpos++)
            {
                value = (*atIndexImp)(collection,atIndexSel,i + wpos);
                wmin = MIN(wmin, value);
                wmax = MAX(wmax, value);
            }

            wmid = wmin + (wmax - wmin) / 2.0;

            x = ((double)(i - xmin)) * xscale + frame.origin.x;
            y = (wmid - ymin)* yscale + frame.origin.y;
            (*lineToPointImp)(graph, lineToPointSel, NSMakePoint(x,y));

            x = ((double)(i - xmin) + ((double)(win) / 2.0)) * xscale + frame.origin.x;
            y = (wmax - ymin)* yscale + frame.origin.y;
            (*lineToPointImp)(graph, lineToPointSel, NSMakePoint(x,y));
            y = (wmin - ymin)* yscale + frame.origin.y;
            (*lineToPointImp)(graph, lineToPointSel, NSMakePoint(x,y));

            x = ((double)(i + win - xmin)) * xscale + frame.origin.x;
            y = (wmid - ymin)* yscale + frame.origin.y;
            (*lineToPointImp)(graph, lineToPointSel, NSMakePoint(x,y));
        }
    }
    
    [color set];
    [graph stroke];

}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    
    [aCoder encodeObject:collection];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    [aDecoder decodeValueOfObjCType: @encode(id) at: &collection];
    
    return self;
}
@end
