/*2002 Oct 10*/

#import <Foundation/NSObject.h>

@interface EnergySource:NSObject
{
    int energy;
    int refill;
}
- (void)setEnergy:(int)value;
- (int)energy;
@end
