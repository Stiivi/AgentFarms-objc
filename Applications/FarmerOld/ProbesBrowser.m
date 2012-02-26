/* 2003 Jul 3 */

#import "ProbesBrowser.h"

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
#import <AgentFarms/AFObjectPrototype.h>
#import <AgentFarms/AFClassDescription.h>
#import <AgentFarms/AFProbeSpecification.h>

#import <FarmingKit/AFGraphView.h>
#import <FarmingKit/AFSequenceGraphElement.h>

#import <AgentFarms/AFSimulator.h>

#import "AFFarm.h"
#import "NSTableView+additions.h"

@implementation ProbesBrowser
+ (void)initialize
{
    /* Link data framework */
    [AFNumberCollection class];
}
- (NSString *)resourceName
{
    return @"ProbesBrowser";
}

- (void)windowDidLoad
{
    NSString *title;

    [tableView setAutoresizesAllColumnsToFit:YES];
    [tableView sizeToFit];
    [tableView setNeedsDisplay:YES];
    [tableView autosizeRowHeight];

    [previewSwitch setState:NSOnState];

    [graphView setDrawsGrid:YES];
    // FIXME: use this when gnustep is unb0rken
    //    [tableView setTarget:self];
    //    [tableView setAction:@selector(probeSelected:)];
    
    title = [NSString stringWithFormat:@"Collections - %@", [[self farm] name]];
    [[self window] setTitle:title];
}
- (void)farmStateChanged:(id)notif
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
    if(![farm isLaunched])
    {
        RELEASE(probes);
        probes = nil;
        [tableView reloadData];
        [tableView setNeedsDisplay:YES];
        return;
    }

    ASSIGN(probes, [[farm simulator] probeDescriptions]);

    [tableView reloadData];
    [tableView setNeedsDisplay:YES];

    if([self previewEnabled])
    {
        [self previewSelectedProbes];
    }
}
- (void)simulatorProbesChanged:(id)notif
{
    [self refresh:nil];
}

- (void)createPlotGraph:(id)sender
{
    /*
    AFAttributeDescription *desc;
    ObjectBrowserCell      *cell;
    NSEnumerator           *enumerator;
    NSString               *attrIdentifier;
    NSNumber               *num;
    int                     row = [tableView selectedRow];
        
    cell = [browser selectedCell];
    
    enumerator = [tableView selectedRowEnumerator];
    
    while( (num = [enumerator nextObject]) )
    {
        row = [num intValue];
        desc = [classDescription attributeAtIndex:row];
        attrIdentifier = [desc identifier];
        NSLog(@"Collect %i:%@", [cell objectReference], attrIdentifier);
    }
    */
}
- (void)probeSelected:(id)sender
{
    NSLog(@"Probe selected!");
}
- (BOOL)previewEnabled
{
    return ([previewSwitch state] == NSOnState);
}

- (void)previewSwitchChanged:(id)sender
{
    NSLog(@"Preview %i", [self previewEnabled]);
    if(![self previewEnabled])
    {
        [graphView removeAllElements];
        [graphView setNeedsDisplay:YES];
    }
    else
    {
        [self previewSelectedProbes];
    }
}
- (void)scaleSwitchChanged:(id)sender
{
    if([scaleSwitch state] == NSOnState)
    {
        [graphView setRelativeScale:YES]; 
    }
    else
    {
        [graphView setRelativeScale:NO]; 
    }
    [graphView setNeedsDisplay:YES];
}

/**************************************************************************
    Table data source
**************************************************************************/
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [probes count];
}

- (id)              tableView:(NSTableView *)view
    objectValueForTableColumn:(NSTableColumn *)column
                          row:(int)row
{
    AFProbeSpecification *probe = [probes objectAtIndex:row];
    AFObjectDescription  *objDesc;
    AFClassDescription   *classDesc;
    AFAttributeDescription *attrDesc;
    NSString             *name = nil;

    objDesc = [[farm simulator] descriptionForObjectWithReference:[probe objectReference]];
    
    classDesc = [[farm model] descriptionForClassWithName:[objDesc objectClassName]];

    /* FIXME: make it faster, do not query simulator for class description */
    attrDesc = [classDesc attributeWithIdentifier:[probe propertyIdentifier]];
    // NSLog(@"%@ %@", classDesc, attrDesc);
    
    if(tableView == tableView)
    {
        if( [[column identifier] isEqualToString: @"Attribute"] )
        {
            return [attrDesc name];
        }
        else if( [[column identifier] isEqualToString: @"Object"] )
        {
            name = [[farm simulator] nameForObjectWithReference:[probe objectReference]];
            if(!name)
            {
                name = [[probe objectReference] description];
            }

            return name;
        }
    }
    return @"Nothing";
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
    if([self previewEnabled])
    {
        [self previewSelectedProbes];
    }        
}
- (void)previewSelectedProbes
{
    AFSequenceGraphElement *element;  
    AFProbeSpecification *spec;
    AFNumberCollection   *collection;
    NSEnumerator         *enumerator = [tableView selectedRowEnumerator];
    NSNumber             *num;
    int                   row;

    [graphView removeAllElements];
 
    while( (num = [enumerator nextObject]) )
    {
        row = [num intValue];
        spec = [probes objectAtIndex:row];
        collection = [[farm simulator] collectionForProbeWithSpecification:spec]; 
        //  NSLog(@"Collection %@ %i", collection, [collection isProxy]);

        element = [AFSequenceGraphElement elementWithCollection:collection];
        [element setColor:[NSColor blueColor]];
        [graphView addElement:element];
    }
    [graphView setNeedsDisplay:YES];
}
- (void)close
{
    NSLog(@"closing probes browser");
    DESTROY(probes);
    [super close];
}

@end
