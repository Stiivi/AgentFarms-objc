/* 2003 Jul 3 */

#import "AFButtonRow.h"

#import <Foundation/NSArray.h>

#import <AppKit/NSButtonCell.h>
#import <AppKit/NSCell.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSMatrix.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSWindow.h>

@interface AFButtonRowCell:NSButtonCell
{
    id object;
}
- (id)representedObject;
- (void)setRepresentedObject:(id)anObject;
@end

@implementation AFButtonRowCell
- (void)dealloc
{
    RELEASE(object);
    [super dealloc];
}
- (id)representedObject
{
    return object;
}
- (void)setRepresentedObject:(id)anObject
{
    ASSIGN(object, anObject);
}
@end

@implementation AFButtonRow
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
    [matrix setCellClass:[NSButtonCell class]];

    [matrix setTarget:self];
            
    return self;
}
- (void)addButtonWithTitle:(NSString *)title
                     image:(NSImage *)image
         representedObject:(id)object
{
    NSButtonCell *cell;
    
    cell = [[NSButtonCell alloc] initImageCell:image];

    [cell setTitle:title];
    [cell setImagePosition:NSImageAbove];
    [cell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    [cell setAction:@selector(cellSelected:)];
    [cell setRepresentedObject:object];

    [matrix addColumnWithCells:[NSArray arrayWithObject:cell]];
    [matrix sizeToCells];
    [self setNeedsDisplay:YES];
}
- (void)removeObjectWithIdentifier:(NSString *)identifier
{
    NSLog(@"Not implemented removeObjectWithIdentifier:");
}

- (void)selectedObject
{
    return [[matrix selectedCell] representedObject];
}

- (void)cellSelected:(id)sender
{
    id object;
    
    object = [[matrix selectedCell] representedObject];

    [delegate buttonRow:self selectedObject:object];
}
@end
