#import "AFObjectPresenter.h"

#import <AppKit/NSBezierPath.h>
#import <AppKit/NSStringDrawing.h>
#import <Foundation/NSDictionary.h>

@implementation AFObjectPresenter
- (void)dealloc
{
    RELEASE(presentedObject);
    [super dealloc];
}
- (id)presentedObject
{
    return presentedObject;
}
- (void)setPresentedObject:(id)anObject
{
    ASSIGN(presentedObject, anObject);
}
- (NSSize)size
{
    return NSMakeSize(0.0,0.0);
}
/** Dravs presented object in rect given by rect */
- (void)drawAtPoint:(NSPoint)aPoint inRect:(NSRect)aRect
{
    NSAttributedString *label;
    NSBezierPath       *path = [NSBezierPath bezierPath];
    NSDictionary       *attr;
    NSRect              rect;
    NSSize              size;
    
    attr = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSFont userFontOfSize:0],NSFontAttributeName,
                                     nil,nil];

    label = [[NSAttributedString alloc] initWithString:[presentedObject className]
                                            attributes:AUTORELEASE(attr)];
    size = [label size];
 
    rect.origin.x = aPoint.x - 4;
    rect.origin.y = aPoint.y - 4 - size.height;
    rect.size.width = size.width + 4*2.0;
    rect.size.height = size.height + 4*2.0;

    [path appendBezierPathWithRect:rect];
 
    if(isSelected)
    {
        [[NSColor redColor] set];
        [path setLineWidth:6.0];
    }
    else
    {
        [[NSColor blackColor] set];
        [path setLineWidth:1.0];
    }
    [path stroke];
    
    [label drawAtPoint:aPoint withAttributes:attr];
    RELEASE(label);
}
@end
