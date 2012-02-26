/* 2003 Jul 3 */

#import "ModulesView.h"

#import <Foundation/NSArray.h>

#import <AppKit/NSButtonCell.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSMatrix.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSWindow.h>

#import "AFFarm.h"
#import "AFFarmerModule.h"

@interface ModuleButtonCell:NSButtonCell
{
    AFFarmerModule *module;
}
- (AFFarmerModule *)representedModule;
- (void)setRepresentedModule:(AFFarmerModule *)aModule;
@end

@implementation ModuleButtonCell
- (AFFarmerModule *)representedModule
{
    return module;
}
- (void)setRepresentedModule:(AFFarmerModule *)aModule
{
    ASSIGN(module, aModule);
}
@end

@implementation ModulesView
- initWithFrame:(NSRect)frame
{
    [super initWithFrame:frame];
    
    scrollView = [[NSScrollView alloc] initWithFrame:[self bounds]];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setBorderType:NSBezelBorder];
    [scrollView setAutoresizingMask:NSViewWidthSizable];

    [self addSubview: AUTORELEASE(scrollView)];

    matrix = [[NSMatrix alloc] initWithFrame:NSMakeRect(0,0,0,0)];
    [scrollView setDocumentView:matrix];

    [matrix setCellSize:NSMakeSize(68, 68)];
    [matrix setCellClass:[ModuleButtonCell class]];

    [matrix setTarget:self];
            
    return self;
}

- (void)addModule:(AFFarmerModule *)module
{
    ModuleButtonCell *cell;

    cell = [[ModuleButtonCell alloc] initImageCell:[module icon]];

    [cell setTitle:[module name]];
    [cell setImagePosition:NSImageAbove];
    [cell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [cell setAction:@selector(openModuleWindow:)];
    [cell setRepresentedModule:module];

    [matrix addColumnWithCells:[NSArray arrayWithObject:cell]];
    [matrix sizeToCells];
    [self setNeedsDisplay:YES];
}
- (void)openModuleWindow:(id)sender
{
    AFFarmerModule *module;
    
    module = [[matrix selectedCell] representedModule];
    [[[module controller] window] makeKeyAndOrderFront:nil];
}
@end
