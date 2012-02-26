/* 2003 Jul 17 */

#import "AFFarmerModule.h"

#import <Foundation/NSBundle.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSDebug.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>

#import <AppKit/NSImage.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSWindowController.h>
#import "WindowController.h"

@interface AFFarmerModule(AFPrivate)
- (void)_registerNotifications;
@end

@implementation AFFarmerModule
- initWithFarm:(AFFarm *)aFarm
    dictionary:(NSDictionary *)dict 
        bundle:(NSBundle *)aBundle
{
    self = [super init];
    
    farm = aFarm;
    
    name = RETAIN([dict objectForKey:@"Name"]);
    iconName = RETAIN([dict objectForKey:@"Icon"]);
    className = RETAIN([dict objectForKey:@"Class"]);
    bundle = RETAIN(aBundle);
    notifications = RETAIN([dict objectForKey:@"ObservedNotifications"]);

    /*
    if([[dict objectForKey:@"Instantiate"] boolValue] == YES)
    {
        [self controller];
    }
    */

    /* Instantiate */
    [self controller];

    if([[dict objectForKey:@"VisibleAtLaunchTime"] boolValue] == YES)
    {
        [[(NSWindowController *)[self controller] window] makeKeyAndOrderFront:nil];
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
- (Class)controllerClass
{
    if(!controllerClass)
    {
        controllerClass = [bundle classNamed:className];
        if(!controllerClass)
        {
            [NSException raise: @"AFFarmerModuleException"
                        format: @"Unable to get controller class '%@' for module '%@'.",
                        className, name];
            return nil;
        }
    }
    return controllerClass;
}
- (id)controller
{
    if(!controller)
    {
        NSDebugLLog(@"AFFarmerModule",@"Instantiating module '%@'", name);
        controller = [(WindowController *)[[self controllerClass] alloc] initWithFarm:farm];
        if(!controller)
        {
            [NSException raise: @"AFFarmerModuleException"
                format: @"Unable to instantiate controller for module '%@'.",
                name];
            return nil;
        }
        [self _registerNotifications];
    }
    return controller;
}
- (void)_registerNotifications
{
    NSEnumerator *enumerator;
    NSDictionary *dict;
    SEL           sel;
    
    enumerator = [notifications objectEnumerator];
    
    while( (dict = [enumerator nextObject]) )
    {
        sel = NSSelectorFromString([dict objectForKey:@"Selector"]);

        if(!sel)
        {
            [NSException raise: @"AFFarmerModuleException"
                        format: @"Unable to register notification '%@' for module '%@'. "
                  @"Unknown selector %@.", [dict objectForKey:@"Name"], 
                                            name, [dict objectForKey:@"Selector"]];
            continue;
        }
        NSDebugLLog(@"AFFarmerModule",@"Register %@",[dict objectForKey:@"Name"]);
        [[NSNotificationCenter defaultCenter]
            addObserver:controller
               selector:sel
                   name:[dict objectForKey:@"Name"]
                 object:farm];
    }
}
- (void)_unregisterNotifications
{
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
               name:nil
             object:nil];
}
- (AFFarm *)farm
{
    return farm;
}
@end
