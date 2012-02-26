#import "AFAssistantManager.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>

static AFAssistantManager *sharedManager = nil;

@implementation AFAssistantManager
+ sharedManager
{
    if(!sharedManager)
    {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}
- (void)dealloc
{
    RELEASE(assistants);
    [super dealloc];
}

- (NSArray *)availableAssistants
{
    NSArray *array;
    
    if(!assistants)
    {
        [self findAssistants];
    }

    array = [assistants allValues];
    array = [array sortedArrayUsingSelector:@selector(compareByRank:)];
    array = [array valueForKey:@"name"];

    return array;
}

- (void)findAssistants
{
    NSBundle       *bundle;

    DESTROY(assistants);
    
    /* FIXME: find assistants in other budnles also */
    bundle = [NSBundle mainBundle];
    
    assistants = [[NSMutableDictionary alloc] init];
    [assistants addEntriesFromDictionary:[self findAssistantsInBundle:bundle]];
}
    
- (NSDictionary *)findAssistantsInBundle:(NSBundle *)bundle
{
    NSMutableDictionary  *assdict = [NSMutableDictionary dictionary];
    NSDictionary    *dict;
    NSEnumerator    *enumerator;
    AFAssistantInfo *info;
    
    enumerator = [[[bundle infoDictionary] objectForKey:@"AFFarmAssistants"]
                                                            objectEnumerator];

    while( (dict = [enumerator nextObject]) )
    {
        info = [[AFAssistantInfo alloc] initWithDictionary:dict 
                                                    bundle:bundle];
        NSLog(@"Found assistant: %@", [info name]);
        if([assdict objectForKey:[info name]])
        {
            NSLog(@"Warning: replacing assistant %@", [info name]);
        }
        [assdict setObject:info forKey:[info name]];
    }
    
    return [NSDictionary dictionaryWithDictionary:assdict];
}
- infoForAssistant:(NSString *)name
{
    return [assistants objectForKey:name];
}
/** Factory method */
- (id)createAssistant:(NSString *)name forMaster:(AFFarmMaster *)master
{
    NSEnumerator *enumerator;
    NSDictionary *dict;
    SEL           sel;
    AFAssistantInfo *info;
    Class           *class;
    id               assistant;

    info = [assistants objectForKey:name];
    
    if(!info)
    {
        [NSException raise:@"AFAssistantManagerException"
                     format:@"Unable to find assistant with name '%@'", name];
        return nil;
    }

    class = [info assistantClass];
    
    assistant = [[class alloc] initWithMaster:master];

    /* register for notifications */
    
    enumerator = [[info observedNotifications] objectEnumerator];
    
    while( (dict = [enumerator nextObject]) )
    {
        sel = NSSelectorFromString([dict objectForKey:@"selector"]);

        if(!sel)
        {
            [NSException raise: @"AFAssistantException"
                        format: @"Unable to register notification '%@' for assistant '%@'. "
                  @"Unknown selector %@.", [dict objectForKey:@"name"], 
                                            name, [dict objectForKey:@"selector"]];
            continue;
        }
        NSLog(@"-- Observe %@:%@",name, [dict objectForKey:@"name"]);

        [[NSNotificationCenter defaultCenter]
            addObserver:assistant
               selector:sel
                   name:[dict objectForKey:@"name"]
                 object:master];
    }

    return assistant;
}
@end
