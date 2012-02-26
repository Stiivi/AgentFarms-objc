/* 2002 Oct 10 */

#import <Foundation/NSObject.h>

@class NSArray;
@class NSMutableArray;

@class AFAgentAction;

extern AFAgentAction *AgentMoveUpAction;
extern AFAgentAction *AgentMoveRightAction;

@interface WalkingAgent:NSObject
{
    id              environment;
    NSMutableArray *paths;
    int             memorySize;
    int             energy;
    
    NSArray        *plan;
    NSMutableArray *steps;
}
- initWithMemorySize:(int)size;
- (void)setEnergy:(int)value;
- (int)energy;
- (void)addEnergy:(int)value;

- (void)beginTrip;
- (AFAgentAction *)action;
- (void)finishTrip;

- (WalkingAgent *)divide;
@end
