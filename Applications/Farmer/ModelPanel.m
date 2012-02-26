/** ModelPanel

    Copyright (c) 2002 Stefan Urbanek

    Written by: Stefan Urbanek
    Date: 2002 Oct 10
    
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

#import "ModelPanel.h"

#import <AppKit/NSApplication.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTextView.h>

#import <AgentFarms/AFModelBundle.h>
#import <AgentFarms/AFModel.h>

static ModelPanel *newFarmPanel = nil;

static NSString *ModelColumn = @"Model";

@implementation ModelPanel
+ sharedPanel
{
    if(!newFarmPanel)
    {
        newFarmPanel = [[ModelPanel alloc] init];
    }
    
    return newFarmPanel;
}

- init
{
    NSView *view;
    NSSize aSize;

    if(![NSBundle loadNibNamed:@"ModelPanel" owner:self])
    {
        NSLog(@"Could not load resources for model panel");
        [self dealloc];
        return nil;
    }
    self = [self initWithContentRect:[[(NSPanel *)panel contentView] frame]
                           styleMask:NSTitledWindowMask 
                                     | NSClosableWindowMask 
                                     | NSResizableWindowMask
                             backing:NSBackingStoreRetained
                               defer:NO];

    [self setTitle:@"New Simulation"];
    [self setFrame:[panel frame] display:NO];
    view = RETAIN([panel contentView]);
    [panel setContentView:nil];
    [self setContentView:AUTORELEASE(view)];

    [table autoresizesAllColumnsToFit];
    [table sizeLastColumnToFit];
    [table setTarget:self];
    [table setDoubleAction:@selector(create:)];

    aSize = [[NSFont systemFontOfSize: 0.0] maximumAdvancement];
    [table setRowHeight: (aSize.height * 1) + 2];

    // descriptionText = [[descriptionText contentView] documentView];
    RELEASE(panel);

    return self;
}

-(BOOL)run
{
    NSMutableArray *array;
    
    RELEASE(models);
    RELEASE(modelName);
    modelName = nil;
    
    array = [NSMutableArray array];
    
    models = RETAIN([AFModelBundle knownModelBundles]);

    [table reloadData];

    [NSApp runModalForWindow:self];

    if(modelName)
    {
        return YES;
    }
    return NO;
}

- (NSString *)modelName
{
    return modelName;
}

- (void) create: (id)sender
{
    [NSApp stopModal];
    [self close];
}


- (void) cancel: (id)sender
{
    [NSApp stopModal];
    [self close];

    RELEASE(modelName);
    modelName = nil;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSLog(@"Number %i", [models count]);
    /* FIME: */
    return [models count];
}

- (id)              tableView:(NSTableView *)tableView
    objectValueForTableColumn:(NSTableColumn *)column
                          row:(int)row
{
    NSLog(@"row %i",row);
    if( [[column identifier] isEqualToString:ModelColumn] )
    {
        return [models objectAtIndex:row];
    }

    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notif
{
    int row = [table selectedRow];
    modelName = RETAIN([models objectAtIndex:row]);
    [descriptionText setString:@"No description."];
}
@end
