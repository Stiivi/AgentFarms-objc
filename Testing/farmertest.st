" 2003 Jun 14 "
[|

main

    Environment includeFramework:'FarmsFarmer'.
    
    simulator := AFDistantSimulator alloc init. 

    simulator connectNew.
    "simulator connectNewInDebugger."

    [simulator isConnected] whileFalse:
        [
            Transcript showLine:'Connecting...'.
            NSRunLoop currentRunLoop 
                        runUntilDate: (NSDate dateWithTimeIntervalSinceNow:0.3).
        ].

    " Now we have connected simulator "
    " Open model and launch simulation "

    simulator loadModelWithBundlePath:'/home/me/Developer/Projects/AgentFarms2/Models/SourceFinder/SourceFinder.afmodel'.

    simulator createSimulation.

    simulator runTimeUnits:5.
    NSRunLoop currentRunLoop run. 
    ^self    
]
