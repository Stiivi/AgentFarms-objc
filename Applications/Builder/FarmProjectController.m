/* 2003 Nov 21 */

#import "FarmProjectController.h"
#import "AFFarmProject.h"

#import <AppKit/NSWindow.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSArchiver.h>
#import <Foundation/NSUnarchiver.h>
#import <DevelKit/DKProjectBuilder.h>

#import <FarmingKit/AFButtonRow.h>
#import "StructureEditor.h"
#import "BehaviourBrowserController.h"

@implementation FarmProjectController
+ controllerWithNewProject
{
    return AUTORELEASE([[self alloc] init]);
}

- (id)init
{
    self = [super init];
    NSLog(@"INIT");
    project = [[AFFarmProject alloc] init];

    return self;
}
- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    if([[windowController windowNibName] isEqual:@"FarmProjectWindow"])
    {
        [self _initialiseModules];
    }
}
- (void)dealloc
{
    [super dealloc];
}

- (void)makeWindowControllers
{
    NSWindowController *wc;
    NSLog(@"Make window controlelrs");
    wc = [[NSWindowController alloc] initWithWindowNibName:@"FarmProjectWindow"
                                                     owner:self];
    [self addWindowController:wc];
}

- (void)_initialiseModules
{
    BehaviourBrowserController *behaviourBrowserController;
    StructureEditor            *structureEditor;
    
    [buttonRow addButtonWithTitle:@"Description"
                            image:[NSImage imageNamed:@"Description"]
                representedObject:self];


    structureEditor = [[StructureEditor alloc] initWithProject:project];
    [self addWindowController:structureEditor];

    [buttonRow addButtonWithTitle:@"Structure"
                            image:[NSImage imageNamed:@"Structure"]
                representedObject:structureEditor];


    behaviourBrowserController = [[BehaviourBrowserController alloc] initWithProject:project];
    [self addWindowController:behaviourBrowserController];
    
    [buttonRow addButtonWithTitle:@"Behaviour"
                            image:[NSImage imageNamed:@"Behaviour"]
                representedObject:behaviourBrowserController];

    /* FIXME: remove this */
    [[behaviourBrowserController window] makeKeyAndOrderFront:nil];
                
    [buttonRow addButtonWithTitle:@"Log"
                            image:[NSImage imageNamed:@"Log"]
                representedObject:self];

}

- (void) build: (id)sender
{
    DKProjectBuilder *builder;
    NSFileManager    *manager = [NSFileManager defaultManager];
    NSString         *path;
    

    path = [@"/tmp" stringByAppendingPathComponent:[project name]];
    [manager createDirectoryAtPath:path attributes:nil];
    
    builder = [DKProjectBuilder builderWithProject:project];
    [builder setBuildPath:path];
    [builder createSources];
}

- (void) start: (id)sender
{
    NSLog(@"Start!");
}

- (void)buttonRow:(AFButtonRow *)row selectedObject:(id)object
{
    NSLog(@"Selected object: %@", object);
    
    [[object window] makeKeyAndOrderFront:nil];
}
- (NSWindow *)window
{
    return window;
}

- (BOOL)writeToFile:(NSString *)fileName ofType:(NSString *)docType
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString      *file;
    
    [manager createDirectoryAtPath:fileName attributes:nil];
    
    file = [fileName stringByAppendingPathComponent:@"project.object"];
    /* FIXME: use farm store object, handle for errors  */
    [NSArchiver archiveRootObject:project toFile:file];
    
    return YES;
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)docType
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString      *file;
    
    file = [fileName stringByAppendingPathComponent:@"project.object"];

    NSLog(@"Read from file");
    /* FIXME: use farm store object, handle for errors  */
    project = [NSUnarchiver unarchiveObjectWithFile:file];
    
    /* FIXME: the project is already set in -init */

    return YES;
}
@end
