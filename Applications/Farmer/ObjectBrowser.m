/* 2003 Jul 3 */

#import "ObjectBrowser.h"

#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSNotification.h>
#import <Foundation/NSValue.h>

#import <AppKit/NSAttributedString.h>
#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSMatrix.h>
#import <AppKit/NSTableColumn.h>
#import <AppKit/NSTableView.h>
#import <AppKit/NSWindow.h>

#import <AgentFarms/AFAttributeDescription.h>
#import <AgentFarms/AFClassDescription.h>
#import <AgentFarms/AFModel.h>
#import <AgentFarms/AFObjectPrototype.h>
#import <AgentFarms/AFProbeSpecification.h>
#import <AgentFarms/AFSimulator.h>

#import "AFFarm.h"
#import "NSTableView+additions.h"

@interface ObjectBrowserCell:NSBrowserCell
{
    ObjectBrowserCell   *parentCell;
	NSImage             *image;
    NSString            *identifier;

    id                   objectReference;
    AFObjectDescription *object;
    AFClassDescription  *classDescription;
}
- (void)setObjectReference:(id)ref;
- (id)objectReference;

- (void)setParentCell:(ObjectBrowserCell *)ref;
- (ObjectBrowserCell *)parentCell;

- (void)setIdentifier:(NSString *)aString;
- (NSString *)identifier;

- (void)setObject:(AFObjectDescription *)anObject;
- (AFObjectDescription *)object;

- (void)setClassDescription:(AFClassDescription *)desc;
- (AFClassDescription *)classDescription;
@end

@implementation ObjectBrowserCell
- (void)dealloc
{
    RELEASE(identifier);
    RELEASE(objectReference);
    RELEASE(parentCell);
    RELEASE(object);
    RELEASE(classDescription);
    RELEASE(image);
    [super dealloc];
}
- (void) setImage: (NSImage *) theImage
{
    ASSIGN(image, theImage);
}
- (void) drawWithFrame: (NSRect) theFrame
                inView: (NSView *) theView
{
  if (![theView window]) return;
  if ( image )
    {
      [theView lockFocus];

      NSRect aFrame;
      NSSize aSize;

      aSize = [image size];
      NSDivideRect(theFrame, &aFrame, &theFrame, 3 + aSize.width, NSMinXEdge);

      /*
      if ([self drawsBackground])
        {
          [[self backgroundColor] set];
          NSRectFill(aFrame);
        }
	*/

      aFrame.size = aSize;
/*
      if ( [theView isFlipped] )
        {
          aFrame.origin.y -= ceil((theFrame.size.height + aFrame.size.height) / 2);
        }
      else
        {
          aFrame.origin.y -= ceil((theFrame.size.height - aFrame.size.height) / 2);
        }
	*/

     aFrame.origin.y += 16;

      [image compositeToPoint: aFrame.origin
             operation: NSCompositeSourceOver];
      [theView unlockFocus];
    }

  [super drawWithFrame: theFrame
         inView: theView];
}

- (NSSize) cellSize
{
  NSSize aSize;

  aSize = [super cellSize];
  aSize.width += (image ? [image size].width : 0);// + 3;

  return aSize;
}

- (void)setObjectReference:(id)anObject;
{
    ASSIGN(objectReference, anObject);
}
- (id)objectReference
{
    return objectReference;
}
- (void)setParentCell:(ObjectBrowserCell *)anObject;
{
    ASSIGN(parentCell, anObject);
}
- (ObjectBrowserCell *)parentCell
{
    return parentCell;
}
- (void)setIdentifier:(NSString *)aString
{
    ASSIGN(identifier, aString);
}
- (NSString *)identifier
{
    return identifier;
}

- (void)setObject:(AFObjectDescription *)anObject
{
    ASSIGN(object,anObject);
}

- (AFObjectDescription *)object
{
    return object;
}

- (void)setClassDescription:(AFClassDescription *)desc
{
    ASSIGN(classDescription, desc);
}
- (AFClassDescription *)classDescription
{
    return classDescription;
}
- (BOOL)isLoaded
{
    return (object != nil);
}
@end

@interface ObjectBrowser(AFPrivate)
- (void)objectSelected:(id)sender;
@end

@implementation ObjectBrowser
- (NSString *)windowNibName
{
    return @"ObjectBrowser";
}

- (void)windowDidLoad
{
    NSString *title;
    
    [tableView setAutoresizesAllColumnsToFit:YES];
    [tableView sizeToFit];
    [tableView setNeedsDisplay:YES];
    [tableView autosizeRowHeight];

    [browser setMaxVisibleColumns:4];
    [browser setDelegate:self];
    [browser setCellClass:[ObjectBrowserCell class]];
    
    title = [NSString stringWithFormat:@"Objects - %@", [[self farm] name]];
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
    int selectedColumn = [browser selectedColumn];
    int row = [browser selectedRowInColumn:selectedColumn];
    int i;

    /* FIXME: handle situation when object dies */

    if(selectedColumn == -1)
    {
        [browser loadColumnZero];
        if([self isLaunched])
        {
            [browser selectRow:0 inColumn:0];
        }
    }
    else
    {
        for(i = 0;i <= selectedColumn; i++)
        {
            [browser reloadColumn:i];
        }

        [browser selectRow: row inColumn:selectedColumn];
    }
    
    [tableView reloadData];
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
    ObjectBrowserCell   *selectedCell;
    AFRelationshipDescription *rel;
    AFSimulator         *simulator = [self simulator];

    if(![self isLaunched])
    {
        if(column == 0)
        {
            return 1;
        }
        return 0;
    }

    if(column == 0)
    {
        return [[simulator rootObjectNames] count];
    }
    else
    {
        selectedCell = [browser selectedCellInColumn:column - 1];

        if(![selectedCell isLoaded])
        {
            [self loadCell:selectedCell];
        }

        /* We are going to fill next column according to the selected cell  */

        if([[selectedCell object] isCollection])
        {
            /* FIXME: this is temporary. Use some method for getting collection 
                      size, instead of @"count" */
            return [[[selectedCell object] valueForPropertyKey:@"count"] intValue];
        }
        else
        {
            return [[[selectedCell classDescription] relationshipDescriptions] count];
        }
    }
}

- (void)        browser:(NSBrowser *)sender 
        willDisplayCell:(id)cell
                  atRow:(int)row
                 column:(int)column
{
    ObjectBrowserCell   *selectedCell;
    AFRelationshipDescription *rel;
    NSDictionary        *dict;
    AFSimulator         *simulator = [self simulator];
    NSString            *name;
    NSArray             *array;
    NSArray             *refs;
    id                   ref;

    // NSLog(@"Display ROW %i COL %i", row, column);
    if([self isLaunched])
    {

        if(column == 0)
        {
            array = [simulator rootObjectNames];
            refs = [simulator rootObjectReferences];
            name = [array objectAtIndex:row];

            [cell setTitle:name];
        }
        else
        {
            selectedCell = [browser selectedCellInColumn:column - 1];

            if(![selectedCell isLoaded])
            {
                [self loadCell:selectedCell];
            }
            
            if([[selectedCell object] isCollection])
            {
                [cell setTitle:[NSString stringWithFormat:@"%i", row]];
                [cell setIdentifier:[NSNumber numberWithInt:row]];
            }
            else
            {
                array = [[selectedCell classDescription] relationshipDescriptions];
                rel = [array objectAtIndex:row];

                [cell setTitle:[rel name]];
                [cell setIdentifier:[rel identifier]];
            }
            [cell setParentCell:selectedCell];
            [cell setLeaf:NO];
        }
    }
    else
    {
        if(column == 0)
        {
            [cell setTitle:@"(No objects)"];
            [cell setEnabled:NO];
            [cell setLeaf:YES];
        }
    }
}

- (void)objectSelected:(id)sender
{
    ObjectBrowserCell *cell;

    cell = [browser selectedCell];
    [self loadCell:cell];

    NSLog(@"Selected %@:%@", [cell title], [[cell classDescription] name]);

    [tableView reloadData];
    [tableView setNeedsDisplay:YES];
}

- (void)loadCell:(ObjectBrowserCell *)cell
{
    id object;
    id ref = nil;

    if([cell parentCell])
    {
        AFObjectDescription *object = [[cell parentCell] object];
        if([object isCollection])
        {
            /* FIXME: this is ugly */
            ref = [[self simulator] referenceForObjectAtIndex:[[cell identifier] intValue]
                                        inObjectWithReference:[[cell parentCell] objectReference]];
        }
        else
        {
            ref = [[[cell parentCell] object] referenceForRelationship:[cell identifier]];
        }
        /*
        ref = [[cell parentCell] objectReference];
        ref = [[farm simulator] referenceForRelationship:[cell identifier] 
                                   ofObjectWithReference:ref];
        */
        if(!ref)
        {
            NSLog(@"!! WARNING: No relationship '%@'", [cell title]);
            return;
        }
    }
    else
    {
        /* We are at root */
        ref = [[self simulator] referenceForObjectWithName:[cell title]];
        if(!ref)
        {
            NSLog(@"!! WARNING: No root object '%@'", [cell title]);
            return;
        }
    }

    object = [[self simulator] descriptionForObjectWithReference:ref];        

    [cell setObjectReference:ref];
    [cell setObject:object];
    [cell setClassDescription:[[[self farm] model] descriptionForClassWithName:[object objectClassName]]];
    // NSLog(@"Load %@:%@ (ref %@)", [cell title], object, ref);
}
- (void)collect:(id)sender
{
    AFAttributeDescription *desc;
    AFProbeSpecification   *spec;
    ObjectBrowserCell      *cell;
    NSMutableArray         *probes = [NSMutableArray array];
    NSEnumerator           *enumerator;
    AFSimulator            *simulator = [self simulator];
    NSString               *attrIdentifier;
    NSNumber               *num;
    int                     row = [tableView selectedRow];
        
    cell = [browser selectedCell];
    
    enumerator = [tableView selectedRowEnumerator];
    
    while( (num = [enumerator nextObject]) )
    {
        row = [num intValue];
        desc = [[cell classDescription] attributeAtIndex:row];
        attrIdentifier = [desc identifier];

        NSLog(@"Watch %@:%@", [cell objectReference], attrIdentifier);
        
        spec = [AFProbeSpecification specificationWithObjectReference:[cell objectReference]
                                                   propertyIdentifier:attrIdentifier];
                                                
        [probes addObject:spec];
    }
    
    [simulator addProbesFromTemplates:probes];
}
- (id)selectedObjectReference
{
    return [[browser selectedCell] objectReference];
}
/**************************************************************************
    Table data source
**************************************************************************/
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(![[browser selectedCell] object])
    {
        return 0;
    }
    else
    {
        return [[[browser selectedCell] classDescription] numberOfAttributes];
    }
}

- (id)              tableView:(NSTableView *)view
    objectValueForTableColumn:(NSTableColumn *)column
                          row:(int)row
{
    AFAttributeDescription *desc;
    NSString               *key;
    
    key = [[[[browser selectedCell] classDescription] attributeKeys] objectAtIndex:row];
    desc = [[[browser selectedCell] classDescription] attributeAtIndex:row];

    if(tableView == tableView)
    {
        if( [[column identifier] isEqualToString: @"Attribute"] )
        {
            return [desc name];
        }
        else if( [[column identifier] isEqualToString: @"Value"] )
        {
            return [[[browser selectedCell] object] valueForPropertyKey:key];
        }
    }
    return nil;
}
- (BOOL)tableView: (NSTableView *)view
shouldEditTableColumn: (NSTableColumn *)column
              row: (int)row
{
    AFAttributeDescription *desc;
    NSString               *key;
    
    key = [[[[browser selectedCell] classDescription] attributeKeys] objectAtIndex:row];
    desc = [[[browser selectedCell] classDescription] attributeAtIndex:row];

    if(tableView == view 
        && [[column identifier] isEqualToString: @"Value"]
        && [desc isChangeable])
    {
        return YES;
    }

    return NO;
}
- (void)       tableView:(NSTableView *)view
          setObjectValue:(id) value
          forTableColumn:(NSTableColumn *)column
                     row:(int)row
{
    NSString               *key;
    NSArray                *array;
    AFObjectDescription    *object;
    
    object = [[browser selectedCell] object];
    array = [[[browser selectedCell] classDescription] attributeKeys];
    key = [array objectAtIndex:row];

    if(tableView == view)
    {
        id<AFSimulator> simulator;
        // [object setValue: object forPropertyKey: key];
        [self log:@"Change %@ in %@ from %@ to %@", 
                        key, 
                        [[browser selectedCell] title],
                        [object valueForPropertyKey:key],
                        value];
        simulator = [self simulator];
        [simulator              setValue:value 
                          forPropertyKey:key 
                   inObjectWithReference:[self selectedObjectReference]];
        
        [object setValue:value forPropertyKey:key];
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
- (void)close
{
    NSLog(@"closing object browser");
    [super close];
}

@end
