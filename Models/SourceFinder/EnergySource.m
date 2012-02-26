/*2002 Oct 10*/

#import "EnergySource.h"

@implementation EnergySource
- (void)setEnergy:(int)value
{
    energy = value;
}
- (int)energy
{
    return energy;
}

- (void)step
{
    energy += refill;
}
@end
