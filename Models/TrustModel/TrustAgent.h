/* TrustModelWorld

    Written by: @@AUTHOR@@
    Date: @@DATE@@
    
 */

#import <AgentFarms/AgentFarms.h>

@class AFAgentAction;
@class TrustRelationship;

@interface TrustAgent:NSObject
{
    int memorySize;
    double energy;
}
- (void)addPayoff:(double)value;
- (AFAgentAction *)actionInRelationship:(TrustRelationship *)relationship;
- (double)energy;
@end;
