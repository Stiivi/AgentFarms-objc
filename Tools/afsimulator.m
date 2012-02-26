/* 2003 Jun 14 */

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSConnection.h>
#import <Foundation/NSUserDefaults.h>

#import <AgentFarms/AFSimulator.h>
#import <Foundation/NSDistributedNotificationCenter.h>

const int MAX_SEQUENCES = 100; /* Maximal number of simulator sequence numbers */

@class NSAutoreleasePool;
@class AFModelBundle;

int main(int argc, const char **argv)
{	
    NSDistributedNotificationCenter *dnc;
    NSAutoreleasePool  *pool;
    NSUserDefaults     *defs;
    AFSimulator        *simulator;
    NSDictionary       *dict;
    NSConnection       *connection;
    NSString           *userIdentifier;
    NSString           *serverName;
    BOOL                isRegistered = NO;
    int                 sequence = 0;
    
    
    pool = [NSAutoreleasePool new];

    /* FIXME: make is missing framework linking */
    [AFModelBundle class];

    /* Get command line arguments */
    
    defs = [NSUserDefaults standardUserDefaults];
    userIdentifier = [defs objectForKey:@"AFUserIdentifier"];
    serverName = [defs objectForKey:@"AFServerName"];
    
    if([serverName isEqualtToString:@""])
    {
        serverName = nil;
    }

    /* Create simulator */
    
    simulator = [[AFSimulator alloc] init];
    
    /* Register simulator */
    
    connection = RETAIN([NSConnection defaultConnection]);
    [connection setRootObject:simulator];

    if(!serverName)
    {
        for(sequence = 0; sequence < MAX_SEQUENCES; sequence++)
        {
            serverName = [NSString stringWithFormat:@"AFSimulator%i", sequence];
            NSLog(@"Trying to register simulator with name '%@'", serverName);

            NS_DURING
                if([connection registerName:serverName])
                {
                    isRegistered = YES;
                }
            NS_HANDLER
                NSLog(@"WARNING: GNUstep is broken! Report this to bug-gnustep@gnu.org");
            NS_ENDHANDLER  
            if(isRegistered)
            {
                break;
            }              
        }
    }
    else
    {
        if([connection registerName:serverName])
        {
            isRegistered = YES;
        }
    }
    
    /* Finish */
    
    if(isRegistered)
    {
        NSLog(@"Registered with name '%@'", serverName);
        dnc = [NSDistributedNotificationCenter defaultCenter];

        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    serverName, @"AFDistantSimulatorName",
                                    nil, nil];
                                        
        [dnc postNotificationName:@"AFDistantSimulatorConnectNotification"
                           object:userIdentifier
                         userInfo:dict];
                         
        [[NSRunLoop currentRunLoop] run];
        NSLog(@"Terminating simulator server %@", serverName);
    }
    else
    {
        NSLog(@"Unable to register simulator.");
    }



    RELEASE(pool);

    return 0;
}



