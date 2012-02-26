/* TrustModelWorld

    Written by: @@AUTHOR@@
    Date: @@DATE@@
    
 */

#import <AgentFarms/AgentFarms.h>

@interface TrustModelWorld:NSObject
{
    /* Put your variables here */
    NSArray *agents;
    NSArray *links;

    int rewardPayoff;
    int suckersPayoff;
    int temptationPayoff;
    int punishmentPayoff;
    int interactionCost;
    
    double cooperativeness;
    int brokenCouples;
    int deadAgents;
}
@end
