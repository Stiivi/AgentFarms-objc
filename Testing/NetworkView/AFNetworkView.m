/* 2003 Jun 7 */

#import "AFNetworkView.h"

#import <Foundation/NSTimer.h>

#import <FarmsData/AFNetwork.h>
#import <FarmsData/AFNetworkLink.h>
#import "AFNetworkViewObject.h"

#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSForm.h>
#import <AppKit/NSProgressIndicator.h>
#import <limits.h>

#import "Vector.h"

NSColor *selectedObjectColor = nil;
NSColor *objectColor = nil;
NSColor *backgroundColor = nil;
NSColor *linkColor = nil;

@implementation AFNetworkView
+ (void)initialize
{
    selectedObjectColor = RETAIN([NSColor redColor]);
    objectColor = RETAIN([NSColor blackColor]);
    backgroundColor = RETAIN([NSColor whiteColor]);
    linkColor = RETAIN([NSColor blackColor]);
}
- initWithFrame:(NSRect)frame
{
    [super initWithFrame:frame];

    gravityCoeficient = 0.1;
    stringCoeficient = 1e-3;
    
    updateFrequency = 5;
    framesPerSecond = 30;

    [self restart:nil];
    
    return self;
}
- (void)awakeFromNib
{
    [self updateParametersForm];

    [[frequencyForm cellAtIndex:0] setDoubleValue:framesPerSecond];
    [[frequencyForm cellAtIndex:1] setDoubleValue:updateFrequency];

    [paramsForm  setNeedsDisplay:YES];
}
- (void)restart:(id)sender
{
    AFNetworkViewObject *object;
    AFNetworkViewObject *leftObject;
    AFNetworkViewObject *rightObject;
    NSMutableArray      *objects = [NSMutableArray array];
    NSRect       bounds = [self bounds];
    Vector       location;
    int          i;
    int          index;
    int          count;

    location.x = NSMinX(bounds) + NSWidth(bounds) / 2;
    location.y = NSMinY(bounds) + NSHeight(bounds) / 2;
    
    RELEASE(network);
    network = [[AFNetwork alloc] init];
    
    for(i = 0; i < 20; i++)
    {
        object = AUTORELEASE([[AFNetworkViewObject alloc] init]);

        location.x += (double)rand()/(double)UINT_MAX * 100.0;
        location.y += (double)rand()/(double)UINT_MAX * 100.0;

        [object setLocation:location];
        [objects addObject:object];
    }    

    [network addObjects:objects];

    count = [[network objects] count];

    for(i = 0; i < [objects count] * 2; i++)
    {
        index = rand() % count;
        leftObject = [objects objectAtIndex:index];
        index = rand() % count;
        rightObject = [objects objectAtIndex:index];

        if(leftObject != rightObject)
        {
            [network linkObject:leftObject
                     withObject:rightObject];
        }

    /*        
        [network linkObject:[objects objectAtIndex:i]
                 withObject:[objects objectAtIndex:(i + 1) % [objects count]]];
      */  
    }
}
- (void)add:(id)sender
{
    AFNetworkViewObject *object;
    Vector               location;

    object = AUTORELEASE([[AFNetworkViewObject alloc] init]);

    location = [selectedObject location];
    location.x += (double)rand()/(double)UINT_MAX * 10.0;
    location.y += (double)rand()/(double)UINT_MAX * 10.0;
    [object setLocation:location];
    
    [network addObject:object];
    [network linkObject:selectedObject withObject:object];
}

- (void)dealloc
{
    RELEASE(network);
    [super dealloc];
}
- (void)drawRect:(NSRect)rect
{
    AFNetworkViewObject *object;
    AFNetworkLink       *link;
    NSEnumerator        *enumerator;
    NSBezierPath        *path;
    NSRect               bounds = [self bounds];
    Vector               location;
    
    [backgroundColor set];
    [NSBezierPath fillRect:bounds];

    enumerator = [[network objects] objectEnumerator];
    
    while( (object = [enumerator nextObject]) )
    {
        NSRect        rect;

        location = [object location];
        
        rect.origin.x = location.x - 5 - zero.x;
        rect.origin.y = location.y - 5 - zero.y;
        rect.size.width = 10;
        rect.size.height = 10;

        path = [NSBezierPath bezierPathWithRect:rect];
        if([object isSelected])
        {
            [selectedObjectColor set];
        }
        else
        {
            [objectColor set];
        }
        
        // [path fill];
        //[[NSColor blackColor] set];
        [path stroke];
    }

    enumerator = [[network links] objectEnumerator];

    [linkColor set];
/*
    while( (link = [enumerator nextObject]) )
    {
        Vector loc1;
        Vector loc2;

        object = [link source];
        loc1 = [object location];
        object = [link destination];
        loc2 = [object location];

        [NSBezierPath strokeLineFromPoint:NSMakePoint(loc1.x - zero.x, loc1.y- zero.y)
                                  toPoint:NSMakePoint(loc2.x- zero.x, loc2.y- zero.y)];
    }
*/    // [[NSColor redColor] set];
    // [NSBezierPath strokeRect:[self objectsBounds]];
}

- (void)startAnimation
{
    if(!animationTimer)
    {
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/framesPerSecond
                                                          target:self
                                                        selector:@selector(animate:)
                                                        userInfo:nil
                                                         repeats:YES];
        RETAIN(animationTimer);
    }
    NSLog(@"Start animation %i", framesPerSecond);
}
- (void)stopAnimation
{
    NSLog(@"Stop animation");
    if(animationTimer)
    {
        [animationTimer invalidate];
        RELEASE(animationTimer);
        animationTimer = nil;
    }
    NSLog(@"Stop animation");
}

/** Do one animation step */
- (void)animate:(id)sender
{
    AFNetworkViewObject *src;
    AFNetworkViewObject *dst;
    AFNetworkLink       *link;
    NSEnumerator        *enumerator;
    NSEnumerator        *enumerator2;
    Vector               sv, dv, rv, fv;
    double               R, F;
    NSDate              *date;
    enumerator = [[network links] objectEnumerator];
    
    while( (link = [enumerator nextObject]) )
    {
        src = [link source];
        dst = [link destination];
        sv = [src location];
        dv = [dst location];
        
            R = Vector_distance(sv, dv);
            rv = Vector_difference(sv, dv);
            F = stringCoeficient * (1 - R);
            fv = Vector_multiply(Vector_unit(rv), F);
        //        fv = Vector_multiply(Vector_unit(rv), F);
//                    NSLog(@"a R %f    F %f",R, F);

        [src addSpeed:fv];
        [dst addSpeed:Vector_multiply(fv, -1)];
    }

    enumerator = [[network objects] objectEnumerator];
    while( (dst = [enumerator nextObject]) )
    {
        enumerator2 = [[network objects] objectEnumerator];

        while( (src = [enumerator2 nextObject]) )
        {
            if(src == dst)
            {
                continue;
                
            }
            sv = [src location];
            dv = [dst location];

            R = Vector_distance(sv, dv);
            rv = Vector_difference(sv, dv);
            F = - gravityCoeficient/(R*R);
            fv = Vector_multiply(rv, -F);
            // NSLog(@"R %f    F %f",R, F);
            // NSLog(@"fx %f    y %f",fv.x, fv.y);
            // NSLog(@"rx %f    y %f",rv.x, rv.y);

            [src addSpeed:fv];
            [dst addSpeed:Vector_multiply(fv, -1)];
        }
    }

    temperature = 0.0;
    
    enumerator = [[network objects] objectEnumerator];
    
    while( (dst = [enumerator nextObject]) )
    {
        sv = [dst speed];
        [dst animate];
        temperature += Vector_length(sv);
    }
    
    // [self center:nil];
    [self updateTemperature];
    [self setNeedsDisplay:YES];    
}

/* Returns a rectangle bounding all objects */
- (NSRect)objectsBounds
{
    NSEnumerator *enumerator;
    AFNetworkViewObject  *object;
    NSRect        bounds = NSMakeRect(0.0,0.0,0.0,0.0);
    NSRect        pointRect = NSMakeRect(0.0,0.0,1e-5,1e-5);
    Vector        location;
    
    enumerator = [[network objects] objectEnumerator];
    
    while( (object = [enumerator nextObject]) )
    {
        location = [object location];
        pointRect.origin.x = location.x - zero.x;
        pointRect.origin.y = location.y - zero.y;
        bounds = NSUnionRect(bounds, pointRect);
    }
    return bounds;
}

- (void)center:(id)sender
{
    NSEnumerator         *enumerator;
    AFNetworkViewObject  *object;
    Vector        location;
    Vector        speed;
    NSRect        bounds = [self bounds];
    NSRect        objectsBounds = [self objectsBounds];
    double        x = 0,y=0;
    float         dx;
    float         dy;

    enumerator = [[network objects] objectEnumerator];
    
    while( (object = [enumerator nextObject]) )
    {
        location = [object location];
        x += location.x;
        y += location.y;
    }
    
    x = x / [[network objects] count];
    y = y / [[network objects] count];

    dx = NSMidX(bounds);
    dy = NSMidY(bounds);
    
    enumerator = [[network objects] objectEnumerator];
    
    zero.x = x - dx;
    zero.y = y - dy;
    
    [self setNeedsDisplay:YES];
}

- (void)updateParametersForm
{
    [[paramsForm cellAtIndex:0] setDoubleValue:gravityCoeficient];
    [[paramsForm cellAtIndex:1] setDoubleValue:stringCoeficient];

    [paramsForm  setNeedsDisplay:YES];
}
- (void)parametersChanged:(id)sender
{
    gravityCoeficient = [[paramsForm cellAtIndex:0] doubleValue];
    stringCoeficient = [[paramsForm cellAtIndex:1] doubleValue];
}

- (void)frequencyUpdated:(id)sender
{
    NSLog(@"GHERE");
    framesPerSecond = [[frequencyForm cellAtIndex:0] intValue];
    updateFrequency = [[frequencyForm cellAtIndex:1] intValue];
    [self stopAnimation];
    [self startAnimation];
}

/* Mouse down */

- (AFNetworkViewObject *)objectAtPoint:(NSPoint)point
{
    NSEnumerator *enumerator = [[network objects] objectEnumerator];
    AFNetworkViewObject  *object;
    
    point.x += zero.x;
    point.y += zero.y;
    
    while( (object = [enumerator nextObject]) )
    {
        if([object containsPoint:point])
        {
            return object;  
        }
    }
    return nil;
}
- (void)selectObject:(AFNetworkViewObject *)anObject
{
    NSEnumerator *enumerator;
    AFNetworkViewObject  *object;
    
    enumerator = [[network objects] objectEnumerator];
    
    while( (object = [enumerator nextObject]) )
    {
        [object setSelected:NO];
    }
    
    [anObject setSelected:YES];
    selectedObject = anObject;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    AFNetworkViewObject   *object;
    NSRect         frame;
    unsigned int   eventMask = NSLeftMouseDownMask | NSLeftMouseUpMask
			                   | NSLeftMouseDraggedMask;
    NSEventType    eventType = [theEvent type];
    NSPoint        point;
    NSPoint        oldPoint;
    NSEvent       *presentEvent;
    float          dx,dy;
    NSRect         bounds = [self bounds];
    Vector         location;
    
    dragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    object = [self objectAtPoint:dragPoint];
    
    NSLog(@"Select %@ %f %f", object, dragPoint.x, dragPoint.y, dx, dy);

    [self selectObject:object];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    AFNetworkViewObject   *object;
    NSRect         frame;
    unsigned int   eventMask = NSLeftMouseDownMask | NSLeftMouseUpMask
			                   | NSLeftMouseDraggedMask;
    NSEventType    eventType = [theEvent type];
    NSPoint        point;
    NSPoint        oldPoint;
    NSEvent       *presentEvent;
    float          dx,dy;
    NSRect         bounds = [self bounds];
    Vector         speed;
    Vector         location;
    
    if(!selectedObject)
    {
        return nil;
    }
    
    point = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    dx = point.x - dragPoint.x;
    dy = point.y - dragPoint.y;

    location = [selectedObject location];
    
    // location.x += dx;
    // location.y += dy;
    location.x = point.x + zero.x;
    location.y = point.y + zero.y;
    
    dragPoint = point;
    
    speed.x = 0;
    speed.y = 0;
    [selectedObject setLocation:location];
    [selectedObject setSpeed:speed];
    
    [self setNeedsDisplay:YES];
}

- (double)temperature
{
    return temperature;
}
- (void)updateTemperature
{
    [temperatureField setDoubleValue:temperature];
}
@end


