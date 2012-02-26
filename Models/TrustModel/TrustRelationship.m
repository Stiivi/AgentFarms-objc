#import "TrustRelationship.h"

#import "Memory.h"

@implementation TrustRelationship
- initWithSelfMemory:(Memory *)smem
         otherMemory:(Memory *)omem
{
    self = [super init];
    
    selfMemory = RETAIN(smem);
    otherMemory = RETAIN(omem);

    isNew = YES;
    
    return self;
}
- (void)dealloc
{
    RELEASE(selfMemory);
    RELEASE(otherMemory);
    [super dealloc];
}
- (double)trustToOther
{
    return [selfMemory averageTrust];
}
- (double)trustFromOther
{
    return [otherMemory averageTrust];
}
- (void)rememberSelfAction:(AFAgentAction *)saction 
               otherAction:(AFAgentAction *)oaction
{
    [selfMemory rememberAction:saction];
    [otherMemory rememberAction:oaction];
    isNew = NO;
}
- (BOOL)isNew
{
    return isNew;
}
@end
