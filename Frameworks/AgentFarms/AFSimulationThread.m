#import <Foundation/NSThread.h>

@implementation AFSimulationThread
+ detachNewSimulationThreadToTarget:(AFSimulator *)simulator
                           forSteps:(int)steps
{
    [NSThread detachNewThreadSelector:@selector(_runSimulationForSteps:)
                             toTarget:self
                           withObject:[NSNumber numberWithInt:count]];

}
- (void)_runSimulationForSteps:(NSNumber *)countObj
{
    [self _runSimulationForSteps:[countObj intValue] animate:NO];
}

- simulationEnvironment;
@end
