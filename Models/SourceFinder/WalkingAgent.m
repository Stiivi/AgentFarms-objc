/* 2002 Oct 10 */

#import "WalkingAgent.h"

#import <Foundation/NSArray.h>

#import <AgentFarms/AFAgentAction.h>

AFAgentAction *AgentMoveUpAction = nil;
AFAgentAction *AgentMoveRightAction = nil;

@implementation WalkingAgent
+ (void) initialize
{
    AgentMoveUpAction = [[AFAgentAction alloc] init];
    [AgentMoveUpAction setDescription:@"Move Up"];
    AgentMoveRightAction = [[AFAgentAction alloc] init];
    [AgentMoveRightAction setDescription:@"Move Right"];
}
- initWithMemorySize:(int)size
{
    self = [super init];
    
    paths = [[NSMutableArray alloc] initWithCapacity:size];
    memorySize = size;

    steps = [[NSMutableArray alloc] init];
        
    return self;
}
- (void)dealloc
{
    RELEASE(steps);
    RELEASE(plan);
    RELEASE(paths);
    [super dealloc];
}
- (void)setEnvironment:(id)env
{
    environment = env;
}
- (id)environment
{
    return environment;
}
- (void)setEnergy:(int)value
{
    energy = value;
}
- (void)addEnergy:(int)value
{
    energy += value;
}
- (int)energy
{
    return energy;
}
- (NSArray *)paths
{
    return paths;
}
- (void)beginTrip
{
    BOOL planType = rand() % 2;

    NSArray *newPlan = nil;
    
    switch(planType)
    {
    case 0: break;
    case 1: newPlan = [paths randomObject]; break;
//    case 2: newPlan = [environment randomPlanForAgent:self];
    default: [NSException raise:@"WalkingAgendException"
                          format:@"Alas! Wrong plan type %i", planType];
    }

    [plan setArray:newPlan];
    [steps removeAllObjects];
}
- (NSArray *)memory
{
    return paths;
}
- (AFAgentAction *)action
{
    AFAgentAction *action;
    
    if(plan && [plan count] > 0)
    {
        action = [plan objectAtIndex:0];
        [plan removeObjectAtIndex:0];
    }
    else
    {
        if(rand() % 2)
        {
            action = AgentMoveUpAction;
        }
        else
        {
            action = AgentMoveRightAction;
        }
    }

    [steps addObject:action];

    return action;
}

- (void)finishTrip
{
    [paths addObject:[NSArray arrayWithArray:steps]];

    while([paths count] > memorySize)
    {
        [paths removeObjectAtIndex:0];
    }
}
- (NSArray *)lastTrip
{
    return steps;
}
- (int)tripLength
{
    return [steps count];
}
- (void)setMemory:(NSArray *)array
{
    RELEASE(paths);
    paths = [[NSMutableArray alloc] initWithArray:array];
}

- (WalkingAgent *)divide
{
    WalkingAgent *child;
    NSArray      *memory;
    int           childEnergy = energy / 2;
        
    child = [[WalkingAgent alloc] initWithMemorySize:memorySize];
    [child setMemory:paths];
    [child setEnvironment:environment];
    [child setEnergy:childEnergy];
    energy -= childEnergy;

    return child;
}

- (NSString *)tripString
{
    NSMutableString *str = [NSMutableString string] ;
    NSEnumerator    *enumerator;
    AFAgentAction   *action;
    
    enumerator = [steps objectEnumerator];
    
    while( (action = [enumerator nextObject]))
    {
        if(action == AgentMoveUpAction)
        {
            [str appendString:@"^"];
        }
        else if(action == AgentMoveRightAction)
        {
            [str appendString:@">"];
        }
    }
    return str;
}
@end
