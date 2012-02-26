/* 2003 Jul 3 */

#import "ViewBrowser.h"

#import <AppKit/NSWindow.h>

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSWindow.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSValue.h>

#import <AgentFarms/AFModel.h>
#import <AgentFarms/AFLattice.h>
#import <FarmingKit/AFLatticeView.h>

#import <AgentFarms/AFSimulator.h>

#import "AFFarm.h"
#import "NSTableView+additions.h"

@implementation ViewBrowser
+ (void)initialize
{
    /* Link data framework */
    [AFLattice class];
}
- (NSString *)windowNibName
{
    return @"LatticeBrowser";
}

- (void)windowDidLoad
{
    NSString *title;

    [tableView setAutoresizesAllColumnsToFit:YES];
    [tableView sizeToFit];
    [tableView setNeedsDisplay:YES];
    [tableView autosizeRowHeight];

    title = [NSString stringWithFormat:@"Views - %@", [[self farm] name]];
    [[self window] setTitle:title];

    [self refresh:nil];
}

- (void)updateIfNeeded:(id)notif
{
    if([[self window] isVisible])
    {
        [self refresh:nil];
    }
    else
    {
        refreshOnFocus = YES;
    }
}

- (void)refresh:(id)sender
{
    if(![self isLaunched])
    {
        RELEASE(lattices);
        lattices = nil;
        [tableView reloadData];
        [tableView setNeedsDisplay:YES];
        return;
    }

    ASSIGN(lattices, [[[self farm] model] views]);

    [tableView reloadData];
    [tableView setNeedsDisplay:YES];

    [self tableViewSelectionDidChange:nil];
}

/**************************************************************************
    Table data source
**************************************************************************/
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [lattices count];
}

- (id)              tableView:(NSTableView *)view
    objectValueForTableColumn:(NSTableColumn *)column
                          row:(int)row
{


    NSDictionary *desc = [lattices objectAtIndex:row];
    NSString             *name = nil;

    if(tableView == tableView)
    {
        if( [[column identifier] isEqualToString: @"View"] )
        {
            return [desc objectForKey:@"Name"];
        }
        else if( [[column identifier] isEqualToString: @"Target"] )
        {
            return [desc objectForKey:@"Target"];
        }
    }
    
    return @"Nothing";
}
- (NSDictionary *)selectedLattice
{
    int row = [tableView selectedRow];

    if(row >= 0)
    {        
        return [lattices objectAtIndex:row];
    }
    else
    {
        return nil;
    }
    
}
- (void)windowDidBecomeKey:(id)notif
{
    if(refreshOnFocus)
    {
        refreshOnFocus = NO;
        [self refresh:nil];
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSDictionary *info = [self selectedLattice];
    
    AFLattice *lattice;
    id         object;
    
    /* FIXME: change it to generic views (use preview box) */
    
    lattice = [[self simulator] objectForView:info];

    if([lattice isProxy])
    {
        [NSException raise:@"ViewBrowserException"
                    format:@"View object '%@' is a proxy. "
                           @"It should be passed by copy.",
                           [info objectForKey:@"Name"]];
        return;
    }
    [latticeView setLattice:lattice];
    [latticeView setNeedsDisplay:YES];
}
@end
