/* 2003 Jun 7 */

#import <Foundation/NSObject.h>
#import <Foundation/NSGeometry.h>

#include <Vector.h>

@class NSMutableArray;

@interface AFNetworkViewObject:NSObject
{
    Vector location;
    Vector speed;

    BOOL isSelected;
}
- (void)setLocation:(Vector)vector;
- (void)setSpeed:(Vector)vector;
- (void)addSpeed:(Vector)vector;
- (Vector)location;
- (Vector)speed;

- (BOOL)isSelected;
- (void)setSelected:(BOOL)flag;

- (BOOL)containsPoint:(NSPoint)point;
- (NSSize)size;
@end
