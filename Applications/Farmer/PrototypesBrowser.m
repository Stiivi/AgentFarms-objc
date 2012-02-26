/* 2003 Jul 3 */

#import "PrototypesBrowser.h"

#import <AppKit/NSWindow.h>

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSWindow.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>

#import <AgentFarms/AFModel.h>
#import <AgentFarms/AFAttributeDescription.h>
#import <AgentFarms/AFObjectPrototype.h>
#import <AgentFarms/AFClassDescription.h>

#import <AgentFarms/AFSimulator.h>
#import "NSTableView+additions.h"
#import "AFFarm.h"

@interface PrototypesBrowser(AFPrivate)
- (void)prototypeSelected:(id)sender;
@end

@implementation PrototypesBrowser
- (NSString *)windowNibName
{
    return @"PrototypesBrowser";
}

- (void)windowDidLoad
{
    NSString *title;
    
    [tableView setAutoresizesAllColumnsToFit:YES];
    [tableView sizeToFit];
    [tableView setNeedsDisplay:YES];

    [tableView autosizeRowHeight];
    [browser setMaxVisibleColumns:1];
    [browser setDelegate:self];
    
    title = [NSString stringWithFormat:@"Prototypes - %@", [[self farm] name]];
    [[self window] setTitle:title];
    
    [self refresh:nil];
}
- (void)farmModelLoaded:(id)notif
{
    [self refresh:nil];
}
- (void)refresh:(id)sender
{
    int selectedRow = [browser selectedRowInColumn:0];
    
    ASSIGN(prototypeNames, [[[self farm] model] prototypeNames]);

    [browser loadColumnZero];
    [browser selectRow:selectedRow inColumn:0];
    [self prototypeSelected:nil];

    [tableView reloadData];
}

- (int)browser:(NSBrowser *)browser numberOfRowsInColumn:(int)col
{
    return [prototypeNames count];
}
- (void)    browser:(NSBrowser *)sender 
    willDisplayCell:(NSBrowserCell *)cell 
              atRow:(int)row 
             column:(int)column
{
    [cell setTitle:[prototypeNames objectAtIndex:row]];
    [cell setLeaf:YES];
}
- (void)prototypeSelected:(id)sender
{
    ASSIGN(prototype, [[[self farm] model] prototypeWithName:[[browser selectedCell] title]]);
    ASSIGN(classDescription, [[[self farm] model] descriptionForClassWithName:[prototype objectClassName]]);
    [tableView reloadData];
}
/**************************************************************************
    Table data source
**************************************************************************/
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(!prototype)
    {
        return 0;
    }
    else
    {
        return [classDescription numberOfCreationAttributes];
    }
}

- (id)              tableView:(NSTableView *)view
    objectValueForTableColumn:(NSTableColumn *)column
                          row:(int)row
{
    AFAttributeDescription *desc;
    NSString               *key;
    NSArray                *array;
    
    array = [classDescription creationPropertyKeys];
    key = [array objectAtIndex:row];
    desc = [classDescription creationAttributeWithIdentifier:key];

    if(tableView == tableView)
    {
        if( [[column identifier] isEqualToString: @"Attribute"] )
        {
            return [desc name];
        }
        else if( [[column identifier] isEqualToString: @"Value"] )
        {
            return [prototype valueForPropertyKey:key];
        }
    }
    return nil;
}
- (BOOL)tableView: (NSTableView *)view
shouldEditTableColumn: (NSTableColumn *)column
              row: (int)row
{
    if(tableView == view 
        && [[column identifier] isEqualToString: @"Value"])
    {
        return YES;
    }

    return NO;
}
- (void)       tableView:(NSTableView *)view
          setObjectValue:(id) object
          forTableColumn:(NSTableColumn *)column
                     row:(int)row
{
    NSString               *key;
    NSArray                *array;
    
    array = [classDescription creationPropertyKeys];
    key = [array objectAtIndex:row];

    if(tableView == view)
    {
        [prototype setValue: object forPropertyKey: key];
        NSLog(@"Set attribute '%@' to '%@'.", key, object);
    }
}
- (void)close
{
    NSLog(@"closing prototypes browser");
    DESTROY(prototypeNames);
    DESTROY(prototype);
    DESTROY(classDescription);
    [super close];
}
@end
