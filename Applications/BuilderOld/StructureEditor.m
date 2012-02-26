#import "StructureEditor.h"

#import <Foundation/NSException.h>

#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>
#import <AppKit/NSMatrix.h>

#import "AFFarmProject.h"

#import <Foundation/NSNotification.h>

@implementation StructureEditor
- initWithProject:(AFFarmProject *)aProject
{
    self = [super init];
    
    if(![self loadMyNibNamed:@"StructureEditor"])
    {
        [NSException raise:@"FarmBuilderException"
                     format:@"Unable to load Farm Project Window resources"];
        [self dealloc];
        return nil;
    }

    [[self window] setTitle:@"Structure Editor"];
        
    [classBrowser setDoubleAction:@selector(editClassName:)];
    [classBrowser setMaxVisibleColumns:1];
    
    [self _registerForNotifications];

    project = RETAIN(aProject);
    
    return self;
}
- (void)_registerForNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(classesChanged:)
               name:DKProjectClassesChangedNotification
             object:project];
}

- (void)addInstanceVariable:(id)sender
{
    NSLog(@"add ivar");
}

- (void)removeInstanceVariable:(id)sender;
{
    NSLog(@"remove ivar");
}

- (void)classSelected:(id)sender;
{
    NSLog(@"Class selected");
}

- (void)infoEdited:(id)sender;
{
    NSLog(@"info edited");
}

- (void)            browser:(NSBrowser *)browser 
        createRowsForColumn:(int)column 
                   inMatrix:(NSMatrix *)matrix
{
    NSBrowserCell *cell;
    NSEnumerator  *enumerator;
    NSMutableArray *cells = [NSMutableArray array];
    AFClass       *class;
    
    NSLog(@"Matrsssix %@", matrix);
    
    if(browser == classBrowser)
    {

        enumerator = [[project classes] objectEnumerator];
        
        while( (class = [enumerator nextObject]) )
        {
            cell = [[NSBrowserCell alloc] initTextCell:[class name]];
            NSLog(@"Adding class cell %@", [class name]);
            [cell setLeaf:YES];
            [cell setRepresentedObject:class];
            [cells addObject:AUTORELEASE(cell)];
        }
        if([cells count] > 0)
        {
            [matrix addColumnWithCells:cells];
        }
    }
}
- (NSString *)browser:(NSBrowser *)browser titleOfColumn:(int)column
{
    if(browser == classBrowser)
    {
        return @"Classes";
    }
    else
    {
        return @"Unknown Browser";
    }
}

- (DKClass *)selectedClass
{
    return [[classBrowser selectedCell] representedObject];
}

- (void)editClassName:(id)sender
{
    NSBrowserCell *cell = [classBrowser selectedCell];

    NSLog(@"Edit class name %@", [cell title]);

    [cell setEditable:YES];
    
    [[classBrowser matrixInColumn:0] setDelegate:self];
    [[classBrowser matrixInColumn:0] selectText:nil];
}

- (BOOL)control:(id)matrix textShouldEndEditing:(NSText *)text
{
    NSString *newClassName = [[text string] copy];
    AFClass  *class;
    NSCell   *cell = [matrix selectedCell];

    /* FIXME: handle valid class name */
    NSLog(@"Should end editing %@ %p", matrix, [text string]);

    class = [cell representedObject];
    [class setName:AUTORELEASE(newClassName)];
    [project renameClass:class toName:newClassName];
    
    // [self classesChanged:nil];

    return YES;
}
- (void)classesChanged:(NSNotification *)notif
{
    NSLog(@"Classes changed %@", [project classes]);
    [classBrowser loadColumnZero];
    [classBrowser setNeedsDisplay:YES];
}
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 0;
}
- (id)                tableView:(NSTableView *)tableView
      objectValueForTableColumn:(int)column
                            row:(int)row
{
    return @"Dummy";
}
@end
  
