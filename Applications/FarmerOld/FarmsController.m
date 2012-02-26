/** FarmsController
 
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Feb 10
    
    This file is part of the Farmer application.
 
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.
 
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
*/

#import "FarmsController.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSUserDefaults.h>
#import <Foundation/NSString.h>

#import <AppKit/NSApplication.h>

#import <AgentFarms/AFModel.h>
#import <AgentFarms/AFModelBundle.h>
#import "AFFarm.h"

#import "ModelPanel.h"

extern id NSApp;

FarmsController *sharedManager = nil;

NSMutableArray *observers;

@implementation FarmsController
+ sharedController
{
    if(!sharedManager)
    {
        sharedManager = [[FarmsController alloc] init];
    }
    return sharedManager;
}
- init
{
    [super init];

    if(!sharedManager)
    {
        sharedManager = RETAIN(self);
    }
  
    farms = [[NSMutableArray alloc] init];
  
    return self;
}
- (void)dealloc
{
    NSLog(@"FarmsController dellocated.");
    
    RELEASE(farms);
    RELEASE(storesDirectory);
    [super dealloc];
}
- (void)applicationDidFinishLaunching:(id)notif
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(farmDidClose:)
               name:AFFarmDidCloseNotification
             object:nil];

    // [[NSApplication sharedApplication] orderFrontSharedMemoryPanel:nil];
}

- (void)new:(id)sender
{
    ModelPanel *panel = [ModelPanel sharedPanel];
    AFFarm     *farm;

    [panel run];

    farm = [[AFFarm alloc] initWithModelName:[panel modelName]];

    if(farm)
    {
        [farms addObject:AUTORELEASE(farm)];
    }
}

- (AFFarm *)currentFarm
{
    return currentFarm;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    [self openFile:filename];
    return YES;
}

- (void)openFile:(NSString *)filename
{
    NSString *pathExtension = [filename pathExtension];
    AFFarm   *farm;
    
    if([pathExtension isEqualToString:@"afmodel"])
    {
        AFModelBundle *bundle;

        bundle = [AFModelBundle bundleWithPath:filename];
        if(!bundle)
        {
            NSRunAlertPanel(@"Unable to open model",
                        @"No model bundle at path '%@'.",
                        @"Cancel", nil, nil, filename);
            return;
        
        }
        farm = [[AFFarm alloc] initWithModelPath:filename];

        if(!farm)
        {
            NSRunAlertPanel(@"Unable to open model",
                        @"It was not possible to create a farm from bundle at path '%@'.",
                        @"Cancel", nil, nil, filename);
            return;
        
        }
    }
    else
    {
        NSLog(@"Unknown file type '%@'", pathExtension);
    }

    if(farm)
    {
        [farms addObject:AUTORELEASE(farm)];
    }
}
- (void)farmDidClose:(NSNotification *)notif
{
    AFFarm *farm = [notif object];
    
    NSLog(@"REMOVING CLOSED FARM %@ (%i)", farm, [farm retainCount]);
    [farms removeObject:farm];
}
- (void)openDocument:(id)sender
{
    [self notImplemented:_cmd];
}
- (void)makeCurrentFarm:(AFFarm *)farm
{
    currentFarm = farm;
}
- (NSString *)storesDirectory
{
    if(!storesDirectory)
    {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSString       *dir = [defs objectForKey:@"AFFarmStoresPath"];
        
        if(!dir || [dir isEqualToString:@""])
        {
            dir = NSHomeDirectory();
        }
        
        storesDirectory = RETAIN(dir);
    }
    
    return storesDirectory;
}
- (void)setStoresDirectory:(NSString *)dir
{
    ASSIGN(storesDirectory,dir);
}
@end
