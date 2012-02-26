/* 2003 Jun 13 */

#import <Foundation/NSObject.h>
#import <AgentFarms/AFSimulator.h>

@class NSTask;
@class NSDate;
@class NSDistantObject;

extern NSString *AFDistantSimulatorConnectedNotification;
extern NSString *AFDistantSimulatorDisconnectedNotification;

@interface AFDistantSimulator:NSObject<AFSimulator>
{
    NSDistantObject <AFSimulator> *simulator;    /* The simulator object (distand object) */
    NSTask                 *serverTask;   /* Task holding simulator object */

    NSString               *identifier;   /* Unique identifier used for connection */
    
    NSDate                 *checkTime;    /* Measurement of connection time */

}
+ distantSimulator;
- (oneway void)connectNew;
- (oneway void)connectNewInDebugger;
- (void)terminate;
- (void)debug;
@end
