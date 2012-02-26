#import <Foundation/NSObject.h>

@interface FarmMaster
{
    AFFarm             *farm;
    
    AFDistantSimulator *simulator;
}
@end



@interface FarmController
{
    AFFarm     *farm;
    NSWindow   *window;
    
    FarmMaster *master;
}
@end

