/** WindowController
 
    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 26
    
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

#import "WindowController.h"

#import <Foundation/NSNotification.h>
#import <Foundation/NSString.h>

#import <AppKit/NSWindow.h>

@implementation WindowController
- initWithFarm:(AFFarm *)aFarm
{
    [super initWithWindowNibName:[self resourceName]];
    [self setFarm:aFarm];
    [self setShouldCascadeWindows:NO];
    return self;
}
- (void)dealloc
{
    NSLog(@"Deallocating %@", self);
    RELEASE(farm);
    [super dealloc];
}
- (NSString *)resourceName
{
    return @"None";
}
- (void)windowDidLoad
{
    [[self window] setWindowController:self];
}
- (AFFarm *)farm
{
    return farm;
}
- (void)setFarm:(AFFarm *)aFarm
{
    ASSIGN(farm,aFarm);
}
- (void)windowDidBecomeKey:(NSNotification *)notif
{
    NSLog(@"Window did become key %@", [notif object]);
}
- (void)run:(id)sender
{
    [farm run:sender];
}
- (void)close
{
    // [[self window] setReleasedWhenClosed:YES];
    // [[self window] close];

    DESTROY(farm);
    [super close];
}
@end
