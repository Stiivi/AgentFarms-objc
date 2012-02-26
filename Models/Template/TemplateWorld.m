/* TemplateWorld

    Written by: @@AUTHOR@@
    Date: @@DATE@@
    
 */

#import "TemplateWorld.h"

#import <AgentFarms/AgentFarms.h>

#import <Foundation/NSCoder.h>

@implementation TemplateWorld
/** Do necessary initialization here, raise an exception on error */
- (id)initWithPrototype:(AFObjectPrototype *)prototype
{
    /* Example: */
    // initialAgentCount = [[prototype initialAgentCount] intValue];

    someVariable = [[prototype someVariable] intValue];
    
    /* Do some initialisation here ... */

    /* Call super (this is necessary) */

    /* Do postinitialization */
    return self;
}

/** Awake object from prototype after connections between objects are made */
- (void)awakeWithPrototype:(AFObjectPrototype *)prototype
{
    /* Awake object here.
    
    This method is called:
        - after all connections between objects are made during simulation
          creation. 
        - after object is created from prototype later in simulation
    */
}

- (void)dealloc
{
    /* Release all retained objects here */

    // RELEASE(agents);

    [super dealloc];
}

- (void)step
{
    /* Simulation step code goes here */
    someVariable += (rand() % 3 - 1);
}
- (int)agentCount
{
    return 0;
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
