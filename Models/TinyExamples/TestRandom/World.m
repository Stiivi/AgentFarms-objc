/* World

    Written by: @@AUTHOR@@
    Date: @@DATE@@
    
 */

#import "World.h"

#import <AgentFarms/AgentFarms.h>

#import <Foundation/NSCoder.h>

@implementation World
/** Do necessary initialization here, raise an exception on error */
- (id)initWithPrototype:(AFObjectPrototype *)prototype
{
    agentCount = [[prototype initialAgentCount] intValue];

    return self;
}

/** Awake object from prototype after connections between objects are made */
- (void)awakeWithPrototype:(AFObjectPrototype *)prototype
{
}

- (void)dealloc
{
    [super dealloc];
}

- (void)step
{
    agentCount += (rand() % 3 - 1);
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeValueOfObjCType: @encode(int) at: &agentCount];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [aDecoder decodeValueOfObjCType: @encode(int) at: &agentCount];

    return self;
}
@end
