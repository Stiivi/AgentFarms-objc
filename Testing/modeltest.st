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
    
    bundle load.
    
    source := prototype instantiate.
    Transcript showLine:(source description).

    ^self    
]
