/** AFGraphView 

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

#import "AFGraphView.h"

#import "AFGraphElement.h"
// #import "AFGraphLegendView.h"
#import "AFGeometry.h"
#import <Foundation/NSDictionary.h>

#import <AppKit/NSApplication.h>
#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSStringDrawing.h>
#import <AppKit/NSWindow.h>

#define STICKY_MARGIN 10
#define RULER_TICK_LENGTH 10
#define RULER_LINE_WIDTH 0.1
#define TICK_LINE_WIDTH  0.1

#include <math.h>

/* Modified function from gnuplot */
static double get_tick(double range, double guide, BOOL isInt)
{
    double tick, l10;
    double xnorm, posns;
    int fl;

    l10 = log(range)/log(10);
    fl  = (int) floor(l10);
    
    xnorm = pow(10.0, l10 - fl);    /* approx number of decades */

    posns = guide / xnorm;          /* approx number of tic posns per decade */

    if (posns > 40)
        tick = 0.05;        /* eg 0, .05, .10, ... */
    else if (posns > 20)
        tick = 0.1;     /* eg 0, .1, .2, ... */
    else if (posns > 10)
        tick = 0.2;     /* eg 0,0.2,0.4,... */
    else if (posns > 4)
        tick = 0.5;     /* 0,0.5,1, */
    else if (posns > 1)
        tick = 1;       /* 0,1,2,.... */
    else if (posns > 0.5)
        tick = 2;       /* 0, 2, 4, 6 */
    else
        tick = ceil(xnorm);

    tick = tick * pow(10.0, fl);

    if (isInt && tick < 1.0)
        tick = 1.0;

    return (tick);
}

static NSString *string_from_double(double value, double range)
{
    double l10;
    int    fl;

    l10 = log(range)/log(10);
    fl  = (int) floor(l10);
    
    if(value == 0.0)
    {
        return @"0";
    }
    else if(l10 > 0 && l10 < 1)
    {
        return [NSString stringWithFormat:@"%1.1f", value];
    }
    else if(l10 > 1 && l10 < 5)
    {
        return [NSString stringWithFormat:@"%i", (int)value];
    }
    else if(l10 > 5 || l10 < -3)
    {
        return [NSString stringWithFormat:@"%1.2e", value];
    }
    else if(l10 >= -1 || l10 < 0)
    {
        return [NSString stringWithFormat:@"%1.1f", value];
    }
    else if(l10 >= -2 || l10 < -1)
    {
        return [NSString stringWithFormat:@"%1.2f", value];
    }
    else if(l10 >= -3 || l10 < -2)
    {
        return [NSString stringWithFormat:@"%1.3f", value];
    }
    else
    {
        return [NSString stringWithFormat:@"%f", value];
    }
}

@implementation AFGraphView
+ (void)initialize
{
    /* initialize AFRect class to create AFNullRect */
    [AFRect class];
}

- initWithFrame:(NSRect)frame
{
    NSRect rect;
    NSRect bounds;

    [super initWithFrame:frame];
    
    /* Create default graph */
    graph = [[AFGraph alloc] init];
    
    /* Init background */
    backgroundColor = RETAIN([NSColor whiteColor]);
    drawsBackground = YES;

    gridColor = RETAIN([NSColor grayColor]);

    /* Init ruler */
    [self setRulerFont:[NSFont labelFontOfSize:0.0]];
    rulerColor = RETAIN([NSColor blackColor]);
    rulerVisible = YES;
    autosizesRuler = YES;

    [self setScalesGraphToFit:YES];

    return self;
}

- (void)dealloc
{
    [self removeSubview:legendView];

    RELEASE(backgroundColor);
    RELEASE(rulerColor);
    RELEASE(gridColor);
    RELEASE(rulerFont);
    RELEASE(tickLabelAttributes);
    
    [super dealloc];
}


/** Returns displayed graph. */
- (AFGraph *)graph
{
    return graph;
}

/** Sets a graph to be displayed. */
- (void)setGraph:(AFGraph *)aGraph
{
    ASSIGN(graph,aGraph);

    [legendView setGraph:aGraph];
    [legendView graphViewDidChangeGraphs:self];
//    [self fixLegendViewPosition];
}
/*=========================================================================
    Draw rect
=========================================================================*/

- (void)drawRect:(NSRect)rect
{   
    NSRect frame = [self bounds];
    double xmin, xmax, ymin, ymax, range;

    /* FIXME: draw only the rect 'rect' */
    
    if(scalesGraphToFit)
    {
        [self updateGraphBounds];
        ASSIGN(graphWindow,graphBounds);
    }

    /* Draw background */
    if(drawsBackground)
    {
        [backgroundColor set];
        [NSBezierPath fillRect:frame]; 
    }

    [self calculateGraphFrame];
    
    if(drawsGrid)
    {
        [self drawGridInRect:graphFrame];
    }

    [graph  drawInRect:graphFrame
           graphWindow:graphWindow];

    if(rulerVisible)
    {
        [self drawXRulerInRect:graphFrame];
        [self drawYRulerInRect:graphFrame];
    }
}

- (void)calculateGraphFrame
{
    NSRect frame = [self bounds];
    double xmin, xmax, ymin, ymax, range;
    double bmin;
    double bmax;
    double brange;

    /* Set the graph frame to fill whole view */
    graphFrame = frame;

    xmin = AFMinX(graphWindow);
    ymin = AFMinY(graphWindow);
    xmax = AFMaxX(graphWindow);
    ymax = AFMaxY(graphWindow);

    if(rulerVisible)
    {
        NSString *str;
        float     maxYLabelWidth;
        float     maxXLabelWidth;
        float     labelHeight;
        
        range = xmax - xmin;
        str = string_from_double(xmin, range);
        maxXLabelWidth = [rulerFont widthOfString:str];
        str = string_from_double(xmax, range);
        maxXLabelWidth = MAX(maxXLabelWidth, [rulerFont widthOfString:str]);

        range = ymax - ymin;
        if(![graph relativeScale])
        {        
            str = string_from_double(ymin,range);
        }
        else
        {
            str = [NSString stringWithFormat:@"%@%%",
                                    string_from_double(ymin*100.0,range*100.0)];
        }

        maxYLabelWidth = [rulerFont widthOfString:str];
        if(![graph relativeScale])
        {        
            str = string_from_double(ymax,range);
        }
        else
        {
            str = [NSString stringWithFormat:@"%@%%",
                                    string_from_double(ymax*100.0,range*100.0)];
        }
        maxYLabelWidth = MAX(maxYLabelWidth, [rulerFont widthOfString:str]);

        labelHeight = [rulerFont maximumAdvancement].height;

        if(autosizesRuler)
        {
            rulerSize.height = RULER_TICK_LENGTH + labelHeight + 4;
            rulerSize.width = maxYLabelWidth + RULER_TICK_LENGTH + 4;
        }

        if(autosizesPadding)
        {
            paddingSize.width = maxXLabelWidth / 2.0;
            paddingSize.height = labelHeight / 2.0;
        }
    }
    /* Compute the graph frame */
    
    if(rulerVisible)
    {
        graphFrame.origin.x  += rulerSize.width;
        graphFrame.origin.y  += rulerSize.height;
        graphFrame.size.width -= rulerSize.width + paddingSize.width;
        graphFrame.size.height -= rulerSize.height  + paddingSize.height;
    }
}

/*=========================================================================
    Ruler
=========================================================================*/

- (void)setRulerFont:(NSFont *)font
{
    ASSIGN(rulerFont, font);

    RELEASE(tickLabelAttributes);
    tickLabelAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   font,
                                   NSFontAttributeName,
                                   nil,nil];
}

- (NSFont *)rulerFont
{
    return rulerFont;
}

- (void)drawXRulerInRect:(NSRect)frame
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSString     *label;
    NSPoint       point;
    NSSize        size;
    double        scale;
    double        min = AFMinX(graphWindow), max = AFMaxX(graphWindow);
    double        range = max - min;
    double        tick;
    double        x;
    float         px;
    float         tickmod;
    
    scale = (graphFrame.size.width) / range;

    [rulerColor set];
    
    point = graphFrame.origin;

    [path setLineWidth:RULER_LINE_WIDTH];
    [path moveToPoint:point];
    point.x += graphFrame.size.width;
    [path lineToPoint:point];

    tick = get_tick(range,20, YES);

    tickmod = fmod(min, tick);
    
    if(min > 0)
        x = min + tick - tickmod;
    else
        x = min + tickmod;

    while(x <= max)
    {
        px = (x - min) * scale + rulerSize.width;

        label = string_from_double(x,range);

        size = [label sizeWithAttributes:tickLabelAttributes];

        point.x = px - size.width / 2.0;
        point.y = rulerSize.height - RULER_TICK_LENGTH - 2 - size.height;

        [path moveToPoint:NSMakePoint(px, rulerSize.height)];
        [path relativeLineToPoint:NSMakePoint(0, - RULER_TICK_LENGTH)];
        [label    drawAtPoint:point
               withAttributes:tickLabelAttributes];
        
        x += tick;
    }

    [path stroke];
}

- (void)drawYRulerInRect:(NSRect)frame
{
    NSBezierPath  *path = [NSBezierPath bezierPath];
    NSString      *label;
    NSPoint        point;
    NSSize         size;
    double         scale;
    double         min = AFMinY(graphWindow), max = AFMaxY(graphWindow);
    double         range = (double)(max - min);
    double         tick;
    double         y;
    float          py;
    float          tickmod;
    
    scale = graphFrame.size.height / range;

    [rulerColor set];
    
    point.x = graphFrame.origin.x;
    point.y = graphFrame.origin.y;
    [path setLineWidth:RULER_LINE_WIDTH];
    [path moveToPoint:point];
    point.y += graphFrame.size.height;
    [path lineToPoint:point];

    size = [@"0" sizeWithAttributes:tickLabelAttributes];

    tick = get_tick(range,20, NO);
    tickmod = fmod(min,tick);
    if(min > 0)
        y = min + tick - tickmod;
    else
        y = min - tickmod;

    while(y <= max)
    {
        py = (y - min) * scale + graphFrame.origin.y;

        if(![graph relativeScale])
        {        
            label = string_from_double(y,range);
        }
        else
        {
            label = [NSString stringWithFormat:@"%@%%",
                                    string_from_double(y*100.0,range*100.0)];
        }

        size = [label sizeWithAttributes:tickLabelAttributes];
        
        point.x = graphFrame.origin.x - size.width - RULER_TICK_LENGTH - 4;
        point.y = py - size.height/2.0;
        
        [path moveToPoint:NSMakePoint(graphFrame.origin.x, py)];
        [path relativeLineToPoint:NSMakePoint(- RULER_TICK_LENGTH , 0)];
        [label drawAtPoint:point
            withAttributes:tickLabelAttributes];

        y += tick;
    }

    [path stroke];
}

- (void)drawGridInRect:(NSRect)frame
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    double        scale;
    double        range;
    double        tick;
    double        x, px, y, py;
    float         dashes[] = {2, 2};
    double        xmin = AFMinX(graphWindow), xmax = AFMaxX(graphWindow);
    double        ymin = AFMinY(graphWindow), ymax = AFMaxY(graphWindow);

    range = xmax - xmin;
    scale = graphFrame.size.width / range;

    [gridColor set];
    [path setLineWidth:0.2];
    /* FIXME */
    //    [path setLineDash:dashes count:2 phase:0.0];        
    tick = get_tick(range,20, YES);

    if(xmin >= 0)
        x = xmin + (tick - fmod(xmin, tick));
    else
        x = xmin + (fmod(-xmin, tick));

    while(x <= xmax)
    {
        px = (x - xmin)* scale + rulerSize.width;
        [path moveToPoint:NSMakePoint(px, graphFrame.origin.y)];
        [path lineToPoint:NSMakePoint(px, graphFrame.origin.y + graphFrame.size.height)];

        x += tick;
    }

    range = ymax - ymin;
    tick = get_tick(range,20, NO);
    scale = graphFrame.size.height / range;

    if(ymin >= 0)
        y = ymin + (tick - fmod(ymin, tick));
    else
        y = ymin + (fmod(-ymin, tick));

    while(y <= ymax)
    {
        py = (y - ymin)* scale + rulerSize.height;
        [path moveToPoint:NSMakePoint(graphFrame.origin.x, py)];
        [path lineToPoint:NSMakePoint(graphFrame.origin.x + graphFrame.size.width, py)];

        y += tick;
    }

    [path stroke];
}

- (NSData *)dataWithEPS
{
    return [self dataWithEPSInsideRect:[self bounds]];
}
/*=========================================================================
    Window
=========================================================================*/

/** If flag is YES then graph window is scaled to fit all graph elements. If set
to NO, then graph window is used. */

- (void)setScalesGraphToFit:(BOOL)flag
{
    scalesGraphToFit = flag;
}

/** Return whether graph view scales graph window to fit all graph elements. */

- (BOOL)scalesGraphToFit
{
    return scalesGraphToFit;
}

- (void)setGraphWindow:(AFRect *)rect
{
    ASSIGN(graphWindow, rect);
}
- (AFRect *)graphWindow
{
    return graphWindow;
}
/* Bounds */
- (AFRect *)updateGraphBounds
{
    AFGraphElement *element;
    NSEnumerator   *enumerator;

    RELEASE(graphBounds);

    enumerator = [[graph elements] objectEnumerator];

    graphBounds = AFNullRect;

    while( (element = [enumerator nextObject]) )
    {
        graphBounds = [graphBounds unionWithRect:[element bounds]];
    }

    if([graph relativeScale])
    {
        graphBounds = [AFRect rectWithMinX:AFMinX(graphBounds) 
                                      minY:0.0 
                                      maxX:AFMaxX(graphBounds) 
                                      maxY:1.0];
    }
    
    RETAIN(graphBounds);
    return graphBounds;
}
- (AFRect *)graphBounds
{
    return graphBounds;
}

/**
    If <var>flag</var> is YES scale each graph element to its bounds, therfore
    all elements are displayed in same size. Graph bounds are set to abstract
    range from 0.0 to 1.0 representing minimum value and maximum value
    relatively. If <var>flag</var> is NO, graph bounds are calculated to enclose
    all graphs in same scale for each graph. Default value is NO.
*/
- (void)setRelativeScale:(BOOL)flag
{
    [graph setRelativeScale:flag];
    [self updateGraphBounds];
}
- (BOOL)relativeScale
{
    return [graph relativeScale];
}
/*=========================================================================
    Elements
=========================================================================*/

/** Adds <var>element</var> to the list of receiver's graph elements and
    notifies associated graph legend view with graphViewDidChangeGraphs:self */
- (void)addElement:(AFGraphElement *)element
{
    [graph addElement:element];
    [legendView graphViewDidChangeGraphs:self];
//    [self fixLegendViewPosition];
}

/** Removes <var>element</var> from the list of receiver's graph elements and
    notifies associated graph legend view with graphViewDidChangeGraphs:self */

- (void)removeElement:(AFGraphElement *)element
{
    [graph removeElement:element];
    [legendView graphViewDidChangeGraphs:self];
}

/** Removes all elements of receiver and notifies associated graph legend view
    with graphViewDidChangeGraphs:self */

- (void)removeAllElements
{
    [graph removeAllElements];
    [legendView graphViewDidChangeGraphs:self];
}

/** Sets all elements of receiver to be <var>array</var> and notifies 
    associated graph legend view with graphViewDidChangeGraphs:self */

- (void)setElements:(NSArray *)array
{
    [graph setElements:array];
    [legendView graphViewDidChangeGraphs:self];
//    [self fixLegendViewPosition];
}
- (NSArray *)elements
{
    return [graph elements];
}

/*=========================================================================
    Background, colors and fonts
=========================================================================*/

- (void)setBackgroundColor:(NSColor *)color
{
    ASSIGN(backgroundColor, color);
}
- (NSColor *)backgroundColor
{
    return backgroundColor;
}
- (void)setRulerColor:(NSColor *)color
{
    ASSIGN(rulerColor, color);
}
- (NSColor *)rulerColor
{
    return rulerColor;
}

- (void)setDrawsBackground:(BOOL)flag
{
    drawsBackground = flag;
}
- (BOOL)drawsBackground
{
    return drawsBackground;
}

- (void)setRulerVisible:(BOOL)flag
{
    rulerVisible = flag;
}

- (BOOL)rulerVisible
{
    return rulerVisible;
}

/** If <var>flag</var> is YES then grid is drawn under the graph elements. */
- (void)setDrawsGrid:(BOOL)flag
{
    drawsGrid = flag;
}

/** Returns YES if the grid is drawn under the graph elements. */
- (BOOL)drawsGrid
{
    return drawsGrid;
}

/** Sets color of the grid. */
- (void)setGridColor:(NSColor *)color
{
    ASSIGN(gridColor, color);
}

/** Returns the color of the grid. */
- (NSColor *)gridColor
{
    return gridColor;
}
/** Set size*/
- (void)setRulerSize:(NSSize)size
{
    rulerSize = size;
}
- (NSSize)rulerSize
{
    return rulerSize;
}

- (void)setAutosizesRuler:(BOOL)flag
{
    autosizesRuler = flag;
}
- (BOOL)autosizesRuler
{
    return autosizesRuler;
}

- (void)setPaddingSize:(NSSize)size
{
    paddingSize = size;
}

- (NSSize)paddingSize
{
    return paddingSize;
}
- (void)setAutosizesPadding:(BOOL)flag
{
    autosizesPadding = flag;
}
- (BOOL)autosizesPadding
{
    return autosizesPadding;
}

/*=========================================================================
    Legend view
=========================================================================*/
#if 0
- (void)setLegendView:(AFGraphLegendView *)aView
{
    ASSIGN(legendView,aView);
}
- (AFGraphLegendView *)legendView
{
    return legendView;
}
- (void)setLegendVisible:(BOOL)flag
{
    if(flag && legendView)
    {
        [self addSubview:legendView];
    }
    else
    {
        if(legendVisible)
        {
            [self removeSubview:legendView];
        }
    }
    legendVisible = flag;
}
- (BOOL)legendVisible
{
    return legendVisible;
}

- (void)fixLegendViewPosition
{
    NSRect frame = [self frame];
    NSRect lframe = [legendView frame];
    
    if(NSMaxX(lframe) > NSMaxX(frame) + 4)
    {
        lframe.origin.x = NSMaxX(frame) - lframe.size.width - 4;
    }
    if(NSMaxY(lframe) > NSMaxY(frame) + 4)
    {
        lframe.origin.y = NSMaxY(frame) - lframe.size.height - 4;
    }
    [legendView setFrame:lframe];
}

- (void)homeLegend
{
    NSRect frame = [self frame];
    NSRect lframe = [legendView frame];
    
    lframe.origin.x = NSMaxX(frame) - lframe.size.width - 4.0;
    lframe.origin.y = NSMaxY(frame) - lframe.size.height - 4.0;

    [legendView setFrame:lframe];
}
#endif

/*=========================================================================
    Mouse dragging
=========================================================================*/
#if 0
- (void)drawStickyPadding
{
    NSColor *color = [NSColor whiteColor];
    NSRect   bounds = [self bounds];
    NSRect   rect;
    
    color = [color colorWithAlphaComponent:0.6667];
    
    [color set];

    rect.origin = bounds.origin;
    rect.size.width = bounds.size.width;
    rect.size.height = STICKY_MARGIN;
    [NSBezierPath fillRect:rect]; 

    rect.origin.y = bounds.origin.y + bounds.size.height - STICKY_MARGIN;
    rect.size.width = bounds.size.width;
    rect.size.height = STICKY_MARGIN;
    [NSBezierPath fillRect:rect]; 
    
    rect.origin.x = bounds.origin.x;
    rect.origin.y = bounds.origin.y + STICKY_MARGIN;
    rect.size.width = STICKY_MARGIN;
    rect.size.height = bounds.size.height - STICKY_MARGIN * 2;
    [NSBezierPath fillRect:rect]; 

    rect.origin.x = bounds.origin.x + bounds.size.width - STICKY_MARGIN;
    rect.origin.y = bounds.origin.y + STICKY_MARGIN;
    rect.size.width = STICKY_MARGIN;
    rect.size.height = bounds.size.height - STICKY_MARGIN * 2;
    [NSBezierPath fillRect:rect]; 

    [[NSColor controlHighlightColor] set];
    rect.origin.x = bounds.origin.x + STICKY_MARGIN;
    rect.origin.y = bounds.origin.y + STICKY_MARGIN;
    rect.size.width = bounds.size.width - STICKY_MARGIN * 2;
    rect.size.height = bounds.size.height - STICKY_MARGIN * 2;
    [NSBezierPath strokeRect:rect]; 
}
- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint       hitPoint;
    NSView        *view;

    if(!legendView)
    {
        NSLog(@"No legend view to drag");
        return;
    }
    
    hitPoint = [self convertPoint:[theEvent locationInWindow] toView:self];
    view = [self hitTest:hitPoint];
    
    if(view == legendView)
    {
        [self dragLegendFromPoint:hitPoint];
    }
    else
    {
        if([theEvent modifierFlags] & NSControlKeyMask)
        {
            [self zoomWithEvent:theEvent 
                           isIn: ((NSShiftKeyMask & [theEvent modifierFlags]) == 0)];
        }
        else
        {
            [self panWithEvent:theEvent];
        }
    }
}
    
- (void)panWithEvent:(NSEvent *)theEvent
{
    NSPoint mouse;
    NSPoint lastPoint;
    NSRect  rect = [self bounds];
    BOOL    keepOn = YES;
    BOOL    isInside = YES;
    float   xscale, yscale;
    NSSize  offset = NSMakeSize(0.0,0.0);

    if(scalesGraphToFit)
    {
        return;
    }

    xscale = rect.size.width / (AFWidth(graphWindow));
    yscale = rect.size.height / (AFHeight(graphWindow));

    mouse = [self convertPoint:[theEvent locationInWindow] toView:self];
    lastPoint = mouse;

    [self updateGraphBounds];

    while (keepOn) 
    {
        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |
                                                        NSLeftMouseDraggedMask];
        mouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];

        switch ([theEvent type]) 
        {
        case NSLeftMouseDragged:
                mouse = [self convertPoint:[theEvent locationInWindow] toView:self];
                offset.width = (mouse.x - lastPoint.x) /  xscale;
                offset.height = (mouse.y - lastPoint.y) / yscale;
                lastPoint = mouse;

                graphWindow = [graphWindow rectByTranslatingX:-offset.width
                                                            y:-offset.height];
                
                graphWindow = [graphWindow rectWithinBounds:graphBounds];
                [self setNeedsDisplay:YES];
                break;

        case NSLeftMouseUp:
                    keepOn = NO;
                    RETAIN(graphWindow);
                    break;
        default:
                    /* Ignore any other kind of event. */
                    break;
        }

    };

    return;
}

- (void)zoomWithEvent:(NSEvent *)theEvent isIn:(BOOL)isIn
{
    NSSize  zoom = NSMakeSize(0.0,0.0);
    NSRect  rect = [self bounds];
    NSRect  zoomRect;
    double xrange, yrange; 
    double xcenter, ycenter;
    double xmin,xmax,ymin,ymax;
    
    if(scalesGraphToFit)
    {
        return;
    }

    xrange = AFWidth(graphWindow);
    yrange = AFHeight(graphWindow);
    xcenter = xmin + xrange / 2.0;
    ycenter = ymin + yrange / 2.0;

    if(isIn)
    {
        xmin = xcenter - xrange / 4.0;
        ymin = ycenter - yrange / 4.0;
        xmax = xcenter + xrange / 4.0;
        ymax = ycenter + yrange / 4.0;
    }
    else
    {
        xmin = xcenter - xrange * 2.0;
        ymin = ycenter - yrange * 2.0;
        xmax = xcenter + xrange * 2.0;
        ymax = ycenter + yrange * 2.0;
    }
    
    graphWindow = [AFRect rectWithMinX:xmin minY:ymin maxX:xmax maxY:ymax];
    graphWindow = [graphWindow rectWithinBounds:graphBounds];
    RETAIN(graphWindow);
    
    [self setNeedsDisplay:YES];
}

- dragLegendFromPoint:(NSPoint)hitPoint
{
    NSEvent *event;
    NSPoint  point;
    NSPoint  offPoint;
    NSPoint  lastPoint = hitPoint;
    NSPoint  minMouse, maxMouse;
    NSDate  *future = [NSDate distantFuture];
    NSRect   rect = [self bounds];
    NSRect   frame;
    float    xoffset, yoffset;
    BOOL     keepOn = YES;
    BOOL     acceptsMouseMoved;
    BOOL     dragStarted;
    int      eventMask;
    int      type;

    offPoint = NSMakePoint(NSMaxX([self bounds]),NSMaxY([self bounds]));

    frame = [legendView frame];
    xoffset = hitPoint.x - frame.origin.x;
    yoffset = hitPoint.y - frame.origin.y;

    minMouse.x = rect.origin.x + xoffset;
    minMouse.y = rect.origin.x + yoffset;
    maxMouse.x = rect.origin.x + rect.size.width - frame.size.width + xoffset;
    maxMouse.y = rect.origin.y + rect.size.height - frame.size.height + yoffset;

    acceptsMouseMoved = [[self window] acceptsMouseMovedEvents];
    [[self window] setAcceptsMouseMovedEvents: YES];

    [self lockFocus];
    isDragging = YES;        

    [NSEvent startPeriodicEventsAfterDelay: 0.1 withPeriod: 0.01];
    eventMask = NSLeftMouseUpMask | NSLeftMouseDraggedMask
                | NSMouseMovedMask | NSPeriodicMask;
    event = [NSApp nextEventMatchingMask: eventMask
                               untilDate: future
                                  inMode: NSEventTrackingRunLoopMode
                                 dequeue: YES];

    type = [event type];
    while (type != NSLeftMouseUp)
    {
        if (type != NSPeriodic)
        {
            point = [self convertPoint: [event locationInWindow]
                              fromView: self];
        }
        else if (NSEqualPoints(point, lastPoint) == NO)
        {
            lastPoint = point;

            if (point.x < minMouse.x)
                point.x = minMouse.x;
            if (point.y < minMouse.y)
                point.y = minMouse.y;
            if (point.x > maxMouse.x)
                point.x = maxMouse.x;
            if (point.y > maxMouse.y)
                point.y = maxMouse.y;

            [[self window] disableFlushWindow];

            if (dragStarted == NO)
            {
                [self setNeedsDisplay: YES];
                dragStarted = YES;
            }

//                [legendView setFrameOrigin:offPoint];
//                [self display];

//                NSLog(@"-- Mouse %f %f", point.x, point.y);

            frame = [legendView frame];
            frame.origin.x = point.x - xoffset;
            frame.origin.y = point.y - yoffset;
            [legendView setFrame:frame];

            [legendView setNeedsDisplay: YES];

            [[self window] displayIfNeeded];
            [[self window] enableFlushWindow];
            [[self window] flushWindow];
        }

        event = [NSApp nextEventMatchingMask: eventMask
                                   untilDate: future
                                      inMode: NSEventTrackingRunLoopMode
                                     dequeue: YES];
        type = [event type];
    }

    isDragging = NO;
    [self setNeedsDisplay: YES];
    [NSEvent stopPeriodicEvents];
    [[self window] postEvent:event atStart: NO];
    [self unlockFocus];
    [[self window] setAcceptsMouseMovedEvents: acceptsMouseMoved];

    return;
}

/*=========================================================================
    Resizing
=========================================================================*/

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize;
{
    NSRect  bounds = [self bounds];;
    NSRect  oldBounds;
    NSRect  lframe;
    NSSize  size;
    float   xratio, yratio;
    
    size = [self bounds].size;
    lframe = [legendView frame];
    oldBounds.origin = bounds.origin;
    oldBounds.size =oldSize;

    if(legendView)
    {
        xratio = size.width / oldSize.width;
        yratio = size.height / oldSize.height;

        if(NSMaxX(lframe) > NSMaxX(oldBounds) - STICKY_MARGIN)
        {
            lframe.origin.x = lframe.origin.x + (size.width - oldSize.width);
        }
        else if(NSMinX(lframe) > oldBounds.origin.x + STICKY_MARGIN)
        {
            lframe.origin.x *= xratio;
        }

        if(NSMaxY(lframe) > NSMaxY(oldBounds) - STICKY_MARGIN)
        {
            lframe.origin.y = lframe.origin.y + (size.height - oldSize.height);
        }
        else if (NSMinY(lframe) > oldBounds.origin.y + STICKY_MARGIN)
        {
            lframe.origin.y *= yratio;
        }
        [legendView setFrameOrigin:lframe.origin];
    }    
}
#endif

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSFont *font;
    
    self = [super initWithCoder: aDecoder];
    
    [aDecoder decodeValueOfObjCType: @encode(id) at: &backgroundColor];
    [aDecoder decodeValueOfObjCType: @encode(id) at: &rulerColor];
    [aDecoder decodeValueOfObjCType: @encode(id) at: &gridColor];

    [aDecoder decodeValueOfObjCType: @encode(BOOL) at: &drawsBackground];
    [aDecoder decodeValueOfObjCType: @encode(BOOL) at: &drawsGrid];
    [aDecoder decodeValueOfObjCType: @encode(BOOL) at: &rulerVisible];

    [aDecoder decodeValueOfObjCType: @encode(id) at: &font];
    
    [self setRulerFont:font];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder: aCoder];
    
    [aCoder encodeObject:backgroundColor];
    [aCoder encodeObject:rulerColor];
    [aCoder encodeObject:gridColor];

    [aCoder encodeValueOfObjCType: @encode(BOOL) at: &drawsBackground];
    [aCoder encodeValueOfObjCType: @encode(BOOL) at: &drawsGrid];
    [aCoder encodeValueOfObjCType: @encode(BOOL) at: &rulerVisible];

    /* FIXME: encode graphWindow and graphBounds */

    [aCoder encodeObject:rulerFont];
}

@end
