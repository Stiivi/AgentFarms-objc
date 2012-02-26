#import <Foundation/NSThread.h>

@interface AFSimulationThread
{
    AFEnvironment *environment;
}
+ detachNewSimulationThreadToTarget:(AFSimulator *)simulator
                           forSteps:(int)steps;
- simulationEnvironment;
@end
