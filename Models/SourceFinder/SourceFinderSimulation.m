/*  EnergySourceFinderSimulation

    Written by: Stefan Urbanek
    Date: 2002 Oct 9
*/

#import "SourceFinderSimulation.h"

#import "NSDictionary+additions.h"
#import "NSDictionary+convenience.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSEnumerator.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>

#import <AgentFarms/AFLattice.h>
#import <AgentFarms/AFGrid.h>
#import <AgentFarms/AFAgentAction.h>
#import <AgentFarms/AFObjectPrototype.h>

#import "EnergySource.h"
#import "WalkingAgent.h"

/*
@protocol Dummy
- (id)sourceX;
- (id)sourceY;
@end
*/
@interface SourceFinderSimulation(private)
- (float)averageEnergy;
@end

@implementation SourceFinderSimulation
- (id)initWithPrototype:(AFObjectPrototype *)prototype
{
    AFObjectPrototype *agentPrototype;
    WalkingAgent *agent;
    int           width, height;
    int           count;

    width  = [[prototype gridWidth] intValue];
    height = [[prototype gridHeight] intValue];
    count  = [[prototype initialAgentCount] intValue];

    divideEnergy = [[prototype divideEnergy] intValue];
    moveEnergy = [[prototype divideEnergy] intValue];
    sourceDrain = [[prototype divideEnergy] intValue];

    grid = [[AFGrid alloc] initWithWidth:width height:height];

    [grid setWraps:YES];


    agents = [[NSMutableArray alloc] init];

    /* create agents */    
    agentPrototype = [[self environment] prototypeWithName:@"Agent"];

    for( ; count > 0 ; count --)
    {
        agent = [agentPrototype instantiate];
        [agents addObject:agent];
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"well, Kill'em on dealloc");

    RELEASE(grid);
    RELEASE(agents);
    RELEASE(source);
    [super dealloc];
}

- (void)awakeWithPrototype:(AFObjectPrototype *)prototype
{
    NSPoint point;

    point.x = [[prototype sourceX] intValue];
    point.y = [[prototype sourceY] intValue];

    if(!source)
    {
        NSLog(@"WARNING: No source!");
    }
    else
    {
        [grid putObject:source atLocation:point];
    }

    NSLog(@"-- AWAKE %@", self);
    NSLog(@"-- Grid    : %@", grid);
    NSLog(@"-- Agents  : %i", [agents count]);
    NSLog(@"-- Source X: %i", [self sourceX]);
    NSLog(@"-- Source Y: %i", [self sourceY]);
    
}

- (void)setSourceX:(int)x
{
    NSPoint point = [grid locationOfObject:source];
    point.x = x;
    [grid putObject:source atLocation:point];
}

- (void)setSourceY:(int)y
{
    NSPoint point = [grid locationOfObject:source];
    point.y = y;
    [grid putObject:source atLocation:point];
}

- (int)sourceX
{
    NSPoint point = [grid locationOfObject:source];
    return point.x;
}
- (int)sourceY
{
    NSPoint point = [grid locationOfObject:source];
    return point.y;
}
- (int)sourceEnergy
{
    return [source energy];
}
- (void)setSourceEnergy:(int)value
{
    [source setEnergy:value];
}
- (void)step
{
    AFAgentAction *action;
    WalkingAgent  *agent;
    WalkingAgent  *newAgent;
    NSEnumerator  *enumerator;
    NSMutableSet  *activeAgents;
    NSMutableSet  *survivors = [NSMutableSet set];
    NSMutableSet  *dead = [NSMutableSet set];
    NSPoint        sourcePoint = [grid locationOfObject:source];
    NSPoint        apoint;
    int            energy; 

    deadAgents = 0;
    /* Set agent to the space origin */
    enumerator = [agents objectEnumerator];

    averageTripLength = 0.0;
    
    while( (agent = [enumerator nextObject]) )
    {
        [agent beginTrip];
        [grid putObject:agent atLocation:NSMakePoint(0,0)];
    }
    
    activeAgents = [NSMutableSet setWithArray:agents];

    // [source setEnergy:[source energy] + sourceRefill];
    
    while( [activeAgents count] )
    {
        enumerator = [activeAgents objectEnumerator];
    
        while( (agent = [enumerator nextObject]) )
        {
            action = [agent action];
            
            if(action == AgentMoveUpAction)
            {
                [grid moveObject:agent direction:AFUpGridDirection];
            }
            else if(action == AgentMoveRightAction)
            {
                [grid moveObject:agent direction:AFRightGridDirection];
            }
            else
            {
                [NSException raise:@"SourceFinderSimulationException"
                             format:@"Unknown agent action %@", action];
            }
            
            [agent addEnergy: -1];
            
            apoint = [grid locationOfObject:agent];
            
            if(NSEqualPoints(apoint, sourcePoint))
            {
                energy = [source energy];
                
                if(energy)
                {
                    if(energy < sourceDrain)
                    {
                        [source setEnergy:0];
                    }
                    else
                    {
                        [source setEnergy:energy - sourceDrain];
                        energy = sourceDrain;
                    }

                    [agent addEnergy:energy];
                    [agent finishTrip];
                    [survivors addObject:agent];
                    [grid removeObject:agent];
                    averageTripLength += [[agent lastTrip] count];
                }
            }
            if( [agent energy] <= 0)
            {
                [dead addObject:agent];
                [grid removeObject:agent];
                deadAgents++;
            }
        }
        
        [activeAgents minusSet:survivors];
        [activeAgents minusSet:dead];
    }

    [agents setArray:[survivors allObjects]];
    
    enumerator = [survivors objectEnumerator];

    bornAgents = 0;

    while( (agent = [enumerator nextObject]) )
    {

        if( [agent energy] >= divideEnergy )
        {
            // NSLog(@"%3i * %@", [agent energy], [agent tripString]);
            newAgent = [agent divide];
            [agents addObject:AUTORELEASE(newAgent)];
            bornAgents++;
        }
        else
        {
            // NSLog(@"%3i   %@", [agent energy], [agent tripString]);
        }
    }

    averageTripLength = averageTripLength / (float)[survivors count];
}

- (NSArray *)randomPlanForAgent:(WalkingAgent *)agent
{
    WalkingAgent *donor = nil;
    
    if(!agent)
    {
        return nil;
    }
    
    while(donor == agent)
    {
        donor = [agents randomObject];
    }
    
    return [[donor memory] randomObject];
}
- (int)agentCount
{
    return [agents count];
}
- (float)averageEnergy
{
    NSEnumerator *enumerator;
    WalkingAgent *agent;
    int           sum = 0;
    
    if(![agents count])
    {
        return 0.0;
    }
    
    enumerator = [agents objectEnumerator];

    while( (agent = [enumerator nextObject]) )
    {
        sum += [agent energy];
    }
    
    return (float)sum / (float)[agents count];
}
- (float)averageMemoryLength
{
    NSEnumerator *enumerator;
    WalkingAgent *agent;
    int           sum = 0;
    
    if(![agents count])
    {
        return 0.0;
    }
    
    enumerator = [agents objectEnumerator];

    while( (agent = [enumerator nextObject]) )
    {
        sum += [[agent memory] count];
    }
    
    return (float)sum / (float)[agents count];
}

- (AFLattice *)worldLattice
{
    NSEnumerator *enumerator = [agents objectEnumerator];
    WalkingAgent *agent;
    AFLattice    *lattice;
    NSPoint       point;
    int           x,y;
    int           value;
    int           count;
    
    lattice = [[AFLattice alloc] initWithWidth:[grid width] height:[grid height]];
    
    while( (agent = [enumerator nextObject]) )
    {
        if([grid containsObject:agent])
        {
            point = [grid locationOfObject:agent];
            x = point.x;
            y = point.y;

            value = [lattice intAtX:x y:y];
            [lattice setInt:value + 1 atX:x y:y];
        }
    }
    
    count = [agents count];
    
    for(x = 0; x < [grid width]; x ++)
    {
        for(y = 0; y < [grid height]; y ++)
        {
            value = [lattice intAtX:x y:y];
            value = value / (count / 100.0);

            [lattice setInt:value atX:x y:y];
            
        }
    }

   point = [grid locationOfObject:source];
   x = point.x;
   y = point.y;

   [lattice setInt:99 atX:x y:y];
    return AUTORELEASE(lattice);
}
@end
