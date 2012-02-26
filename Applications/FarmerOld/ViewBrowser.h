/* 2003 Jul 3 */

#import "WindowController.h"

@class NSTableView;
@class NSMutableArray;
@class AFLatticeView;

@interface ViewBrowser:WindowController
{
    NSTableView         *tableView;
    NSMutableArray      *lattices;
    AFLatticeView       *latticeView;
    
    BOOL                 refreshOnFocus;
}
- (void)refresh:(id)sender;
@end
