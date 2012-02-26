#import "BehaviourBrowserController.h"

#import <Foundation/NSException.h>

#import <AppKit/NSBrowser.h>
#import <AppKit/NSBrowserCell.h>
#import <AppKit/NSMatrix.h>

#import "AFFarmProject.h"

#import <Foundation/NSNotification.h>

@implementation BehaviourBrowserController
- initWithProject:(AFFarmProject *)aProject
{
    self = [super init];
    
    if(![self loadMyNibNamed:@"BehaviourBrowserWindow"])
    {
        [NSException raise:@"FarmBuilderException"
                     format:@"Unable to load Farm Project Window resources"];
        [self dealloc];
        return nil;
    }

    [[self window] setTitle:@"Behaviour Browser"];
    
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

- (void)addClass:(id)sender
{
    AFClass *class;
    
    NSLog(@"ADD CLASS");
    class = [[AFClass alloc] initWithName:@"NewClass"];
    
    [class setSuperclassName:@"NSObject"];
    
    [project addClass:AUTORELEASE(class)];
}
- (void)removeClass:(id)sender
{
    NSLog(@"REMOVE CLASS");
}
- (void)addMethod:(id)sender
{
    NSLog(@"ADD METHOD");
}
- (void)removeMethod:(id)sender
{
    NSLog(@"REMOVE METHOD");
}
- (void)methodSelected:(id)sender
{
    NSLog(@"Method selected");
}
- (void)classSelected:(id)sender
{
    NSLog(@"Class selected");
}
- (void)            browser:(NSBrowser *)browser 
        createRowsForColumn:(int)column 
                   inMatrix:(NSMatrix *)matrix
{
    NSBrowserCell *cell;
    NSEnumerator  *enumerator;
    NSMutableArray *cells = [NSMutableArray array];
    AFClass       *class;
    
    NSLog(@"Matrix %@", matrix);
    
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
    else if (browser == methodBrowser)
    {
    }
}
- (NSString *)browser:(NSBrowser *)browser titleOfColumn:(int)column
{
    if(browser == classBrowser)
    {
        return @"Classes";
    }
    else if (browser == methodBrowser)
    {
        return @"Methods";
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

    // cell = [matrix selectedCell];
    /* FIXME: handle valid class name */
    NSLog(@"Should end editing %@ %p", matrix, [text string]);

    class = [cell representedObject];
    [project renameClass:class toName:newClassName];
    //[class setName:AUTORELEASE(newClassName)];
    
    // [self classesChanged:nil];

    return YES;
}

- (void)classesChanged:(NSNotification *)notif
{
    NSLog(@"Classes changed %@", [project classes]);
    [classBrowser loadColumnZero];
    [classBrowser setNeedsDisplay:YES];
}
@end
  
