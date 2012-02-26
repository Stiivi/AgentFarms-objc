/* 2003 Jul 17 */

#import "AFAssistantInfo.h"

#import <Foundation/NSBundle.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>

#import <AppKit/NSImage.h>

@implementation AFAssistantInfo
- initWithDictionary:(NSDictionary *)dict 
              bundle:(NSBundle *)aBundle
{
    self = [super init];
    
    name = RETAIN([dict objectForKey:@"name"]);
    iconName = RETAIN([dict objectForKey:@"icon"]);
    className = RETAIN([dict objectForKey:@"class"]);
    bundle = RETAIN(aBundle);
    notifications = RETAIN([dict objectForKey:@"observedNotifications"]);

    visibleAtLaunchTime = [[dict objectForKey:@"visibleAtLaunchTime"] boolValue];
    instantiateOnCreate = [[dict objectForKey:@"instantiate"] boolValue];
    if( [dict objectForKey:@"rank"] )
    {
        rank = [[dict objectForKey:@"rank"] intValue];
    }
    else
    {
        rank = 50;
    }

    NSDebugLLog(@"AFFarmerModule",@"Loaded module '%@'", name);
    
    return self;
}
- (void)dealloc
{
    RELEASE(name);
    RELEASE(icon);
    RELEASE(iconName);
    RELEASE(className);
    RELEASE(bundle);
    
    [super dealloc];
}
- (NSString *)name
{
    return name;
}
- (NSImage *)icon
{
    NSString *file;

    if(!icon)
    {
        file = [bundle pathForImageResource:iconName];
        icon = [[NSImage alloc] initByReferencingFile:file];
    }

    return icon;
}

- (NSString *)className
{
    return className;
}
- (Class)assistantClass
{
    if(!controllerClass)
    {
        controllerClass = [bundle classNamed:className];
        if(!controllerClass)
        {
            [NSException raise: @"AFFarmerModuleException"
                        format: @"Unable to get controller class '%@' for assistant '%@'.",
                        className, name];
            return nil;
        }
    }
    return controllerClass;
}
- (NSArray *)observedNotifications
{
    return notifications;
}
- (BOOL)visibleAtLaunchTime
{
    return visibleAtLaunchTime; 
}
- (BOOL)instantiateOnCreate
{
    return instantiateOnCreate; 

}
- (int)rank
{
    return rank;
}

- (NSComparisonResult) compareByRank:(AFAssistantInfo *)otherInfo
{
    if([otherInfo rank] == rank)
    {
        return NSOrderedSame;
    }
    else if([otherInfo rank] > rank)
    {
        return NSOrderedAscending;
    }
    else
    {
        return NSOrderedDescending;
    }
}
@end
