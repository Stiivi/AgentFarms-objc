/* 2003 Jul 3 */

#import "AFFarmController.h"

@class NSBrowser;
@class NSTableView;
@class AFObjectDescription;
@class AFClassDescription;
@class NSMutableArray;

@interface ObjectBrowser:AFFarmController
{
    NSBrowser           *browser;
    NSTableView         *tableView;

    BOOL                 refreshOnFocus;
}
- (void)refresh:(id)sender;
@end
