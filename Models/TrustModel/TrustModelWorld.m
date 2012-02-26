/* TrustModelWorld

    Written by: @@AUTHOR@@
    Date: @@DATE@@
    
 */

#import "TrustModelWorld.h"

#import <AgentFarms/AFObjectPrototype.h>
#import <AgentFarms/AFLattice.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSEnumerator.h>

#import "TrustAgent.h"
#import "TrustCouple.h"
#import "TrustRelationship.h"
#import "Actions.h"

extern double round(double d);

AFAgentAction *CooperateAction;
AFAgentAction *DefectAction;

@implementation TrustModelWorld
+ (void)initialize
{
    CooperateAction = [[AFAgentAction alloc] init];
    DefectAction = [[AFAgentAction alloc] init];

}

- (id)initWithPrototype:(AFObjectPrototype *)prototype
{
    AFObjectPrototype *agentPrototype;
    TrustCouple         *link;
    int                count;
    int                i,j;
    
    agentPrototype = [[self environment] prototypeWithName:@"Agent"];
    
    count = [[prototype initialAgentCount] intValue];

    /* Create agents */
    agents = [[NSMutableArray alloc] initWithObjectsFromPrototype:agentPrototype
                                            count:count];
    
    /* Create links */
    links = [[NSMutableArray alloc] init];

    for(i = 0; i < [agents count]; i++)
    {
        for(j = i + 1; j < [agents count]; j++)
        {
            if(rand() % 10 < 8)
            {
            link = [[TrustCouple alloc] initWithLeftAgent:[agents objectAtIndex:i]
                                            rightAgent:[agents objectAtIndex:j]];
            [links addObject:AUTORELEASE(link)];
            }
        }
    }

    suckersPayoff = [[prototype suckersPayoff] intValue];
    temptationPayoff = [[prototype temptationPayoff] intValue];
    rewardPayoff = [[prototype rewardPayoff] intValue];
    punishmentPayoff = [[prototype punishmentPayoff] intValue];
    interactionCost = [[prototype interactionCost] intValue];
    
    cooperativeness = 0.5;
    
    return self;
}

/** Awake object from prototype after connections between objects are made */
- (void)awakeWithPrototype:(AFObjectPrototype *)prototype
{
}

- (void)dealloc
{
    RELEASE(agents);
    RELEASE(links);

    [super dealloc];
}

/* ---------------------------------------------------------------------
    Step
------------------------------------------------------------------------ */

/* Simulation step code goes here */

- (void)step
{
    NSEnumerator *enumerator;
    TrustCouple    *link;
    TrustAgent   *leftAgent;
    TrustAgent   *rightAgent;
    TrustRelationship *leftShip;
    TrustRelationship *rightShip;
    AFAgentAction *leftAction;
    AFAgentAction *rightAction;
    int            cooperateCount = 0;
    int            interactionCount = 0; 
    
    enumerator = [links objectEnumerator];
    
    while( (link = [enumerator nextLiveObject]) )
    {
        leftShip = [link leftRelationship];
        rightShip = [link rightRelationship];
        leftAgent = [link leftAgent];
        rightAgent = [link rightAgent];
        leftAction = [leftAgent actionInRelationship:leftShip];
        rightAction = [rightAgent actionInRelationship:rightShip];

        [leftAgent addPayoff:-interactionCost];
        [rightAgent addPayoff:-interactionCost];

        // NSLog(@"-- LEFT : %@ %@ %@", leftShip, leftAgent, leftAction);
        // NSLog(@"-- RIGHT: %@ %@ %@", rightShip, rightAgent, rightAction);

        /* Do the Prisoner's dilemma game */

        if(leftAction == CooperateAction)
        {
            if(rightAction == CooperateAction)
            {
                [leftAgent addPayoff:rewardPayoff];
                [rightAgent addPayoff:rewardPayoff];

                cooperateCount = cooperateCount + 2;
            }
            else if(rightAction = DefectAction)
            {
                [leftAgent addPayoff:suckersPayoff];
                [rightAgent addPayoff:temptationPayoff];

                cooperateCount = cooperateCount + 1;
            }
            else
            {
                [NSException raise:@"ModelException"
                             format:@"Invalid right action %@", rightAction];
            }
        }
        else if(leftAction == DefectAction)
        {
            if(rightAction == CooperateAction)
            {
                [leftAgent addPayoff:temptationPayoff];
                [rightAgent addPayoff:suckersPayoff];

                cooperateCount = cooperateCount + 1;
            }
            else if(rightAction = DefectAction)
            {
                [leftAgent addPayoff:punishmentPayoff];
                [rightAgent addPayoff:punishmentPayoff];
            }
            else
            {
                [NSException raise:@"ModelException"
                             format:@"Invalid right action %@", rightAction];
            }
        }
        else
        {
            [NSException raise:@"ModelException"
                         format:@"Invalid left action %@", leftAction];
        }
        
        [link rememberLeftAction:leftAction rightAction:rightAction];
        interactionCount++;
    }

    brokenCouples = [links removeDeadObjects];
    deadAgents = [agents removeDeadObjects];
    
    cooperativeness = (double)cooperateCount/(double)interactionCount;
}

/* --------------------------------------------------------------------- */

- (void)removeAgent:(TrustAgent *)deadAgent
{
    NSEnumerator   *enumerator = [links objectEnumerator];
    NSMutableArray *array = [NSMutableArray array];
    TrustCouple      *link;
    NSLog(@"!!-!! Remove agent %@", deadAgent);
    [agents removeObject:deadAgent];
    
    while( (link = [enumerator nextObject]) )
    {
        if([link leftAgent] == deadAgent)
        {
            [array addObject:link];
        }
        else if([link rightAgent] == deadAgent)
        {
            [array addObject:link];
        }
    }
    
    [links removeObjectsInArray:array];
}

- (int)agentCount
{
    return [agents count];
}

- (int) deadAgents
{
    return 0;
}
- (int) bornAgents
{
    return 0;
}
- (double) averageEnergy
{
    NSEnumerator *enumerator = [agents objectEnumerator];
    TrustAgent   *agent;
    double        sum = 0;
    
    while( (agent = [enumerator nextObject]) )
    {
        sum += [agent energy];
    }
    
    return sum / (double)[agents count];
}
- (AFLattice *)strategyDistributionLattice
{

    NSEnumerator *enumerator = [links objectEnumerator];
    AFLattice    *lattice;
    TrustCouple    *link;
    double        leftTrust;
    double        rightTrust;
    int           steps = 20;
    int           x,y;
    int           value, max = 0;
    
    lattice = [[AFLattice alloc] initWithWidth:steps height:steps];
    
    /* x = count of steps * trust 
    
       where trust is from 0.0 to 1.0
    */
    
    while( (link = [enumerator nextObject]) )
    {
        leftTrust = [[link leftRelationship] trustToOther];
        x = (signed int)round(((steps - 1) * leftTrust));

        rightTrust = [[link rightRelationship] trustToOther];
        y = (signed int)round(((steps - 1) * rightTrust));
        // NSLog(@"%i %i %i %f %f", steps, x, y, leftTrust, rightTrust);

        value = [lattice intAtX:x y:y];
        [lattice setInt:value + 1 atX:x y:y];
        value = [lattice intAtX:y y:x];
        [lattice setInt:value + 1 atX:y y:x];
        if(value > max)
        {
            max = value;
        }
    }
    
    for(x = 0; x < steps; x++)
    {
        for(y = 0; y < steps; y++)
        {
            value = [lattice intAtX:x y:y];
            value = (value*100) / (max + 1);
            // NSLog(@"%i %i: %i %i", x, y, max, value);
            [lattice setInt:value atX:x y:y];
            
        }
    }
    
    return AUTORELEASE(lattice);
}
- (AFLattice *)equalityDistributionLattice
{

    NSEnumerator *enumerator = [links objectEnumerator];
    AFLattice    *lattice;
    TrustCouple    *link;
    double        leftTrust;
    double        rightTrust;
    double        difference;
    int           steps = 20;
    int           x,y;
    int           value, max = 0;
    
    lattice = [[AFLattice alloc] initWithWidth:steps height:steps];
    
    /* x = count of steps * trust 
    
       where trust is from 0.0 to 1.0
    */
    
    while( (link = [enumerator nextObject]) )
    {
        leftTrust = [[link leftRelationship] trustToOther];
        rightTrust = [[link rightRelationship] trustToOther];
        difference = fabs(leftTrust - rightTrust);
        
        x = (signed int)round(((steps - 1) * difference));
        y = (signed int)round(((steps - 1) * ((leftTrust + rightTrust) / 2)));
        //y = 0;
        // NSLog(@"%i %i %i %f %f", steps, x, y, leftTrust, rightTrust);

        value = [lattice intAtX:x y:y];
        [lattice setInt:value + 1 atX:x y:y];
        if(value > max)
        {
            max = value;
        }
    }
    
    for(x = 0; x < steps; x++)
    {
        for(y = 0; y < steps; y++)
        {
            value = [lattice intAtX:x y:y];
            value = (value*100) / (max + 1);
            [lattice setInt:value atX:x y:y];
            
        }
    }
    
    return AUTORELEASE(lattice);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    /*
    [aCoder encodeValueOfObjCType: @encode(int) at: &value];
    [aCoder encodeObject:anObject];
    */
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    /*
    [aDecoder decodeValueOfObjCType: @encode(int) at: &value];
    [aDecoder decodeValueOfObjCType: @encode(id) at: &anObject];
    */
    
    /* Do initialization here ... */

    return self;
}
@end
