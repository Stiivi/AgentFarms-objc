
#import "TrustAgent.h"
#import "TrustRelationship.h"
#import "Actions.h"

@implementation TrustAgent
- (void)setMemorySize:(int)size
{
    if(memorySize)
    {
        [NSException raise:@"TrustAgent"
                     format:@"Memory size is already set."];
        return;
    }
    memorySize = size;
}
- (int)memorySize
{
    return memorySize;
}
- (AFAgentAction *)actionInRelationship:(TrustRelationship *)relationship
{
    double trustToOther;
    double trustFromOther;
    double random;
    double trust;
    
    if( [relationship isNew] )
    {
        /* This is new relationship, so get random action */
        random = rand() % 2;
        trust = random;
    }
    else
    {
        /* Compute action from previous experience */
        
        trustToOther = [relationship trustToOther];
        trustFromOther = [relationship trustFromOther];

        random = rand() % 2;

        // trust = random * round(trustToOther) * round(trustFromOther);
        trust = round(random * trustToOther * trustFromOther);
    }

    if(trust >= 0.5)
    {
        return CooperateAction;
    }
    else
    {
        return DefectAction;
    }
}
- (void)addPayoff:(double)value
{
    energy = energy + value;
}
- (double)energy
{
    return energy;
}
- (BOOL)isLive
{
    return energy > 0;
}
@end;
