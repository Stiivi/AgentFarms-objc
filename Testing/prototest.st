" 2003 Jun 14 "
[|

main
    Environment includeFramework:'AgentFarms'.

    Environment includeFramework:'AFModel'.

    path := '/home/me/Developer/Projects/AgentFarms2/Models/SourceFinder/SourceFinder.afmodel'.
    
    bundle := AFModelBundle bundleWithPath: path.
    model := bundle model. 
    Transcript showLine:'Model: ', (model name).

    prototype := model prototypeWithName:'Simulation'.
    Transcript showLine:(prototype description).
    
    Transcript showLine:'-- Loading bundle.'.
    bundle load.
    Transcript showLine:'-- Bundle loaded.'.
    prototype test.
    Transcript showLine:(source description).

    ^self    
]
