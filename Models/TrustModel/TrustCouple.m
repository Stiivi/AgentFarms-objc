/* TrustModelWorld

    Written by: @@AUTHOR@@
    Date: 2003 Oct 5
    
 */

#import "TrustCouple.h"

#import "TrustAgent.h"
#import "TrustRelationship.h"
#import "Memory.h"

@implementation TrustCouple
- initWithLeftAgent:(TrustAgent *)lAgent rightAgent:(TrustAgent *)rAgent
{
    Memory *leftMem;
    Memory *rightMem;
    
    /* FIXME: memory size */
    leftMem = [Memory memoryWithCapacity:[lAgent memorySize]];
    rightMem = [Memory memoryWithCapacity:[lAgent memorySize]];
    
    /* Mirror memories */
    leftRelationship = [[TrustRelationship alloc] initWithSelfMemory:leftMem
                                                         otherMemory:rightMem];
    rightRelationship = [[TrustRelationship alloc] initWithSelfMemory:rightMem
                                                          otherMemory:leftMem];

    leftAgent = RETAIN(lAgent);
    rightAgent = RETAIN(rAgent);
    
    return self;
}
- (void)dealloc
{
    RELEASE(leftAgent);
    RELEASE(rightAgent);
    RELEASE(leftRelationship);
    RELEASE(rightRelationship);
    
    [super dealloc];
}
- leftRelationship
{
    return leftRelationship;
}
- rightRelationship
{
    return rightRelationship;
}
- leftAgent
{
    return leftAgent;
}
- rightAgent
{
    return rightAgent;
}
- (void)rememberLeftAction:(AFAgentAction *)leftAction 
               rightAction:(AFAgentAction *)rightAction
{
    /* NOTE: it does not matter which one we take, both relationships
             share same memories. */
    [leftRelationship rememberSelfAction:leftAction otherAction:rightAction];
}
- (BOOL)isLive
{
    return ([leftAgent isLive] && [rightAgent isLive]);
}
@end
