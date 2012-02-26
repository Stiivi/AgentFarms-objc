/** AFFarmController
 
    Copyright (c) 2004 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2004 Feb 4
    
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


#import "AFFarmController.h"

#import <Foundation/NSString.h>
#import <AppKit/NSWindow.h>

NSString *AFFarmDidLaunchNotification = @"AFFarmDidLaunchNotification";
NSString *AFFarmDestroyedNotification = @"AFFarmDestroyedNotification";
NSString *AFFarmWillCloseNotification = @"AFFarmWillCloseNotification";
NSString *AFFarmDidCloseNotification  = @"AFFarmDidCloseNotification";

NSString *AFFarmCreatedNotification  = @"AFFarmCreatedNotification";
NSString *AFFarmStateChangedNotification = @"AFFarmStateChangedNotification";
NSString *AFFarmDidStopNotification      = @"AFFarmDidStopNotification";
NSString *AFFarmTimeAdvancedNotification = @"AFFarmTimeAdvancedNotification";


@implementation AFFarmController
- initWithMaster:(AFFarmController *)controller
{
    NSString *windowNibName = [self windowNibName];
    self = [super init];

    if(windowNibName)
    {
        [super initWithWindowNibName:windowNibName];
        [self setShouldCascadeWindows:NO];
    }

    master = controller;

    return self;
}
- (void)dealloc
{
    NSLog(@"Deallocating %@", self);
    [super dealloc];
}
- (void)windowDidLoad
{
    NSLog(@"windowDidLoad: setting window controller of %@", self);
    [[self window] setWindowController:self];
}
- (AFFarmController *)master
{
    return master;
}

- (AFFarm *)farm
{
    return [master farm];
}

- (AFModel *)model
{
    return [master model];
}

- (id <AFSimulator>)simulator
{
    return [master simulator];
}

- (int)farmState;
{
    return [master farmState];
}

- (BOOL)isLaunched
{
    return [master isLaunched];
}
/***************************************************************************
    Actions
****************************************************************************/
- (void)restart:(id)sender
{
    [master restart:sender];
}

- (void)run: (id)sender
{
    [master run:sender];
}

- (void)watch:(id)sender
{
    [master watch:sender];
}

- (BOOL)close
{
    NSLog(@"Closing %@", self);
    
    [self _unregisterNotifications];
}

/***************************************************************************
    Logging
****************************************************************************/
- (id <AFLog>)log
{
    return [master log];
}

- (void)log:(NSString*)format,...
{
    va_list             args;

    va_start(args, format);
    
    [[self log] log:format arguments:args];
}

- (void)logError:(NSString*)format,...
{
    va_list             args;

    va_start(args, format);
    
    [[self log] logError:format arguments:args];
}
- (void)logWarning:(NSString*)format,...
{
    va_list             args;

    va_start(args, format);
    
    [[self log] logWarning:format arguments:args];
}
@end
