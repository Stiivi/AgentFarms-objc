/* 2003 Jul 6 */

#import "NSTableView+additions.h"

#import <AppKit/NSCell.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSTableColumn.h>

@implementation NSTableView(Additions)
- (void)autosizeRowHeight
{
    NSTableColumn *col = [[self tableColumns] objectAtIndex:0];
    NSFont        *font;
    
    font = [[col dataCell] font];
    
    [self setRowHeight:[font maximumAdvancement].height];
}
@end
