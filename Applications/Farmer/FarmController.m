/** AFFarm
 
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 6
    
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

#import "FarmController.h"

@implementation FarmController
- initWithModelBundle:(AFModelBundle *)aBundle
{
    self = [super init];

    if(!aBundle)
    {
        [NSException raise:@"AFFarmException"
                     format:@"No model bundle specified."];
        [self dealloc];
        return nil;
    }
    

    if(![self loadMyNibNamed:@"Farm"])
    {
        [NSException raise:@"AFFarmException"
                     format:@"Unable to load Farm window resources"];
        [self dealloc];
        return nil;
    }

    farm = [[AFFarm alloc] initWithModelBundle:aBundle];

    [self _loadFarmAssistants];
    
    [self _postNotificationName:AFFarmCreatedNotification];

    /* Simulator */
    simulator = [[AFDistantSimulator alloc] init];
    
    /* Create farm window */
    [farmWindow setMinSize:NSMakeSize([farmWindow minSize].width,[farmWindow frame].size.height)];
    [farmWindow setMaxSize:NSMakeSize([farmWindow maxSize].width,[farmWindow frame].size.height)];
    [farmWindow makeKeyAndOrderFront:nil];
    [stepCountField setIntValue:[model defaultStepCount]];
    [self stepCountChanged:stepCountField];
    
    [self setFarmState:AFFarmDisconnectedState];

    [self log:@"Welcome to farm '%@'", [[farm model] modelName];


    /* Register as observer */

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(simulatorDidConnect:)
               name:AFDistantSimulatorConnectedNotification
             object:simulator];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(simulatorDidDisconnect:)
               name:AFDistantSimulatorDisconnectedNotification
             object:simulator];
    
    [self connectToSimulator];

    return self;
}

- (void)connectToSimulator
{
    NSLog(@"Connecting to simulator...");
    if(farmState != AFFarmDisconnectedState)
    {
        [NSException raise:@"AFFarmException"
                     format:@"Farm is not disconnected"];
        return;
    }
    
    [timeField setIntValue:0];
    [self setFarmState: AFFarmConnectingState];

    [simulator connectNew];
}

- (void)simulatorDidConnect:(NSNotification *)notif
{
    NSLog(@"Simulator did connect.");

    if(farmState != AFFarmConnectingState)
    {
        [NSException raise:@"AFFarmException"
                     format:@"Simulator did connect while not in Connecting state"];
        return;
    }

    [self log:@"Simulator created."];

    if(![simulator setBundlePath:modelPath])
    {
        [NSException raise:@"AFFarmException"
                     format:@"Unable to load model '%@'", modelPath];
        return;
    }
    
    [simulator setObserver:self];
    
    [self setFarmState: AFFarmEmptyState];
}


/* Actions */

@end
