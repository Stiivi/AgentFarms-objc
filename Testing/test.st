[|

main
    simulator := AFSimulator simulator.
    

    bundle := AFSimulationBundle bundleWithName:'Test'.
    
    class := bundle simulationClass.
    
    simulation = class alloc init.
    
    simulator setSimulation:simulation.
    
]
