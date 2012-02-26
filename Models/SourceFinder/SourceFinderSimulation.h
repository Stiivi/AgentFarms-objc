/*  SourceFinderSimulation

    Written by: Stefan Urbanek
    Date: 2002 Oct 9
*/

#import <Foundation/NSObject.h>

@class AFGrid;
@class NSMutableArray;
@class EnergySource;

@interface SourceFinderSimulation:NSObject
{
    AFGrid         *grid;
    EnergySource   *source;
    NSMutableArray *agents;
    
    int moveEnergy;
    int sourceDrain;
    int divideEnergy;
    int bornAgents;
    int deadAgents;
    float averageTripLength;
}
- (int)agentCount;
@end
