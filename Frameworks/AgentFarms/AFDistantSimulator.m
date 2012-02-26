/* 2003 Jun 13 */

#import "AFDistantSimulator.h"

#import <Foundation/NSConnection.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDistantObject.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSProcessInfo.h>
#import <Foundation/NSTask.h>

@protocol Terminal
-(BOOL) terminalRunProgram: (NSString *)path
	withArguments: (NSArray *)args
	inDirectory: (NSString *)directory
	properties: (NSDictionary *)properties;
@end

const NSString *simulatorToolName = @"afsimulator";

NSString *AFDistantSimulatorConnectedNotification = @"AFDistantSimulatorConnectedNotification";
NSString *AFDistantSimulatorDisconnectedNotification = @"AFDistantSimulatorDisconnectedNotification";

@interface AFDistantSimulator(Private)
- (void)_launchAndConnect;
- (void)_connectToServerWithName:(NSString *)serverName;
@end


@implementation AFDistantSimulator
/** Returns new distant simulator that needs to be connected. */
    
+ distantSimulator
{
    return AUTORELEASE([[self alloc] init]);
}
- init
{
    [super init];
    identifier = RETAIN([[NSProcessInfo processInfo] globallyUniqueString]);
    return self;
}

- (void)dealloc
{
    RELEASE(simulator);
    RELEASE(serverTask);
    RELEASE(identifier);
    [super dealloc];
}
/** Launches simulator process with simulator object and creates a connection
    to it. Raises AFDistantSimulatorDidConnectNotification with object is
    distant simulator.
*/
- (oneway void)connectNew
{
    NSArray *args;
  
    if(simulator)
    {
        [NSException raise:@"AFDistantSimulatorException"
                    format:@"Simulator is already connected"];
        return;
    }
    
    if(serverTask)
    {
        /* Just in case, terminate the server task */
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                       name:NSTaskDidTerminateNotification
                     object:serverTask];

        [serverTask terminate];
        RELEASE(serverTask);
        serverTask = nil;
    }
    
    ASSIGN(checkTime,[NSDate date]);
    
    args = [NSArray arrayWithObjects:
                        @"-AFUserIdentifier",
//                        @"--GNU-Debug=NSMessagePort", /* FIXME: remove */
                        identifier,
                        nil];

    serverTask = [[NSTask alloc] init];
    [serverTask setLaunchPath:@"afsimulator"];
    [serverTask setArguments:args];
    
    [[NSDistributedNotificationCenter defaultCenter]
         addObserver:self 
            selector:@selector(_connectSimulator:)
                name:@"AFDistantSimulatorConnectNotification"
              object:identifier];

    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(_taskTerminated:)
                   name:NSTaskDidTerminateNotification
                 object:serverTask];

    [serverTask launch];
    NSLog(@"%@", serverTask);
}

- (void)debug
{
    NSString *simulatorPath;
    NSString *gdbPath;
    NSArray  *args;
    NSTask   *task;
    NSDistantObject <Terminal>*terminal;

    int pid;
    
    if(!serverTask)
    {
        NSLog(@"No simulation server to debug");
        return;
    }
    
    pid = [serverTask processIdentifier];

    /* Get the Terminal application */
    terminal = (NSDistantObject<Terminal> *)[NSConnection rootProxyForConnectionWithRegisteredName:@"Terminal" host:nil];

    task = [[NSTask alloc] init];
    [task setLaunchPath:@"gdb"];
    gdbPath = RETAIN([task validatedLaunchPath]);
    RELEASE(task);

    task = [[NSTask alloc] init];
    [task setLaunchPath:@"afsimulator"];
    simulatorPath = RETAIN([task validatedLaunchPath]);
    RELEASE(task);

    args = [NSArray arrayWithObjects:
                        [NSString stringWithFormat:@"--pid=%i", pid],
                        [NSString stringWithFormat:@"--exec=%@", AUTORELEASE(simulatorPath)],
                        simulatorPath,
                        nil];

    /* Launch gdb in the Terminal */

    [terminal terminalRunProgram: AUTORELEASE(gdbPath)
	               withArguments: args
	                 inDirectory: nil
	                  properties: nil];

    NSLog(@"Launched gdb in Terminal.app");
}

- (oneway void)connectNewInDebugger
{
    NSString *simulatorPath;
    NSString *gdbPath;
    NSArray  *args;
    NSTask   *task;
    NSDistantObject <Terminal>*terminal;
    
    if(simulator)
    {
        [NSException raise:@"AFDistantSimulatorException"
                    format:@"Simulator is already connected"];
        return;
    }
    
    if(serverTask)
    {
        /* Just in case, terminate the server task */
        [[NSNotificationCenter defaultCenter]
                removeObserver:self
                       name:NSTaskDidTerminateNotification
                     object:serverTask];

        [serverTask terminate];
        RELEASE(serverTask);
        serverTask = nil;
    }
    
    ASSIGN(checkTime,[NSDate date]);
    
    /* Get the Terminal application */
    terminal = (NSDistantObject<Terminal> *)[NSConnection rootProxyForConnectionWithRegisteredName:@"Terminal" host:nil];

    /* Prepare tasks */
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"afsimulator"];
    simulatorPath = [task validatedLaunchPath];
    RELEASE(task);
    
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"gdb"];
    gdbPath = [task validatedLaunchPath];
    RELEASE(task);

    args = [NSArray arrayWithObjects:
                        gdbPath,
                        @"--args",
                        AUTORELEASE(simulatorPath),
                        @"-AFUserIdentifier",
                        identifier,
                        nil];

    /* Register for notifications */

    [[NSDistributedNotificationCenter defaultCenter]
         addObserver:self 
            selector:@selector(_connectSimulator:)
                name:@"AFDistantSimulatorConnectNotification"
              object:identifier];

    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(_taskTerminated:)
                   name:NSTaskDidTerminateNotification
                 object:serverTask];

    /* Launch gdb in the Terminal */

    [terminal terminalRunProgram: AUTORELEASE(gdbPath)
	               withArguments: args
	                 inDirectory: nil
	                  properties: nil];
    NSLog(@"Launched gdb in Terminal.app");
}

- (void)_connectSimulator:(NSNotification *)notif
{
    NSDictionary *dict = [notif userInfo];
    NSString     *serverName;

    serverName = [dict objectForKey:@"AFDistantSimulatorName"];

    /* We have received desired notification, therefore we should 
       unregister ourselves */
    [[NSDistributedNotificationCenter defaultCenter]
        removeObserver:self];

    NSLog(@"Connection requested to %@", serverName);

    [self _connectToServerWithName:serverName];
}
- (void)_connectToServerWithName:(NSString *)serverName
{
    simulator = (NSDistantObject <AFSimulator> *)[NSConnection rootProxyForConnectionWithRegisteredName:serverName
                                                                  host:nil];
    if(!simulator)
    {
        [NSException  raise:@"AFDistantSimulatorException"
                     format:@"Unable to get distant simulator object from server '%@'", serverName];
        return;
    }

    RETAIN(simulator);
    [(NSDistantObject *)simulator setProtocolForProxy:@protocol(AFSimulator)];

    NSLog(@"Found simulator. Class: %@.", [(NSObject *)simulator className]);

    [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(_connectionDidDie:)
            name:NSConnectionDidDieNotification
            object:[simulator connectionForProxy]];

    
    NSLog(@"Connection time: %f", -[checkTime timeIntervalSinceNow]);

    [[NSNotificationCenter defaultCenter]
            postNotificationName:AFDistantSimulatorConnectedNotification
            object:self];
}

/** Returns YES if distant simulato is present and connected. */
- (BOOL)isConnected
{
    return (simulator != nil);
}
/** Terminates simulator task and disconnects */
- (void)terminate
{
    [[NSNotificationCenter defaultCenter]
            removeObserver:self
                   name:NSConnectionDidDieNotification
                 object:nil];

    DESTROY(simulator);
    [serverTask terminate];
    DESTROY(serverTask);
}

- (void)_taskTerminated:(NSNotification *)notif
{
    NSLog(@"Task terminated with status %i", [serverTask terminationStatus]);

    RELEASE(serverTask);
    serverTask = nil;
    simulator = nil;

    [[NSNotificationCenter defaultCenter]
            removeObserver:self
                   name:NSTaskDidTerminateNotification
                 object:[notif object]];
}

- (void)_connectionDidDie:(NSNotification *)notif
{
    NSLog(@"Distant dimulator connection did die");
    simulator = nil;

    [[NSNotificationCenter defaultCenter]
            removeObserver:self
                   name:nil
                 object:[notif object]];

    [[NSNotificationCenter defaultCenter]
            postNotificationName:AFDistantSimulatorDisconnectedNotification
            object:self];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if(!simulator)
    {
        id dummy = nil;

        [NSException raise:@"AFDistantSimulatorException"
                     format:@"Trying to send '%@', but distant simulator is not connected.",
                     NSStringFromSelector([invocation selector])];
        [invocation setReturnValue:&dummy];
        return;
    }

    NSDebugLog(@"Forwarding to simulator '%@'", NSStringFromSelector([invocation selector]));

    [invocation setTarget:simulator];
    [invocation invoke];
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig;

    sig = [super methodSignatureForSelector:aSelector];

    if(!sig)
    {
        sig = [simulator methodSignatureForSelector:aSelector];
    }

    return sig;
}
@end
