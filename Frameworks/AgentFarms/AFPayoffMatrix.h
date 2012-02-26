@protocol AFGameAgent
- addPayoff:(double)payoff inContext:(id)anObject;
@end


@interface AFGame:NSObject
{
    NSArray        *leftActions;
    NSArray        *rightActions;
    AFPayoffMatrix *payoffMatrix;
}
- setPayoffMatrix:(AFPayoffMatrix *)matrix;
- playWithLeftAgent:(id<AFGameAgent>)lAgent 
             rightAgent:(id <AFGameAgent>)rAgent

- payoffLeftAgent:(id<AFGameAgent>)lAgent 
                  

@end

@implementation AFGame
- playWithLeftAgent:(id<AFGameAgent>)leftAgent 
         rightAgent:(id <AFGameAgent>)rightAgent
        inSituation:(id)aSituation
{
    AFAgentAction *al;
    AFAgentAction *ar;
    
    al = [leftAgent actionForGame:self inSituation:aSituation];
    ar = [rightAgent actionForGame:self inSituation:aSituation];

    

    [leftAgent addPayoff:[matrix payoffForLeftAction:al rightAction:ar]];
}
@end


@interface AFPayoffMatrix:NSObject
{
    double *matrix;
}
- (double)payoffForLeftAction:(int)laction rightAction:(int)raction
{
    leftActions = [leftActions count];
    offset = l * leftActions + r;
}

@end

- step
{
    leftAgent
    rightAgent
    trustGame
    
    [trustGame playWithLeftAgent:leftAgent 
                      rightAgent:rightAgent
                       situation:relationship];
    
    
    
}
