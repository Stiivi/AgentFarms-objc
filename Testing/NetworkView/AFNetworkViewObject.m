/* 2003 Jun 7 */

#import "AFNetworkViewObject.h"

#import <AppKit/NSBezierPath.h>
#import <AppKit/NSColor.h>
#import <Foundation/NSArray.h>
#include <Vector.h>

@implementation AFNetworkViewObject
- (void)dealloc
{
    [super dealloc];
}
- (void)animate
{
    location = Vector_sum(location, speed);
    speed.x *= 1- 0.02;
    speed.y *= 1- 0.02;
}
- (void)setLocation:(Vector)vector;
{
    location = vector;
} 
- (void)setSpeed:(Vector)vector;
{
    speed = vector;
}
- (void)addSpeed:(Vector)vector
{
    speed = Vector_sum(speed, vector);

}

- (Vector)location;
{
    return location;
}
- (Vector)speed;
{
    return speed;
}

- (BOOL)isSelected
{
    return isSelected;
}
- (void)setSelected:(BOOL)flag
{
    isSelected = flag;
}

- (BOOL)containsPoint:(NSPoint)point
{
    NSSize size = [self size];
    NSRect rect;
    
    rect.origin.x = location.x - size.width/2.0;
    rect.origin.y = location.y - size.height/2.0;
    rect.size = size;
    
    return NSMouseInRect(point, rect, 0);
}
- (NSSize)size
{
    return NSMakeSize(10,10);
}
@end
