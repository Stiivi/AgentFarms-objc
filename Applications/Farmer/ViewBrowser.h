/* 2003 Jul 3 */

#import "AFFarmController.h"

@class NSTableView;
@class NSMutableArray;
@class AFLatticeView;

@interface ViewBrowser:AFFarmController
{
    NSTableView         *tableView;
    NSMutableArray      *lattices;
    AFLatticeView       *latticeView;
    
    BOOL                 refreshOnFocus;
}
- (void)refresh:(id)sender;
@end
